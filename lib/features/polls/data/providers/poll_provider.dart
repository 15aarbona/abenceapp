import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importamos los modelos
import '../../domain/models/poll_model.dart';
// Importamos el perfil para saber quién vota
import '../../../profile/data/providers/profile_provider.dart';

part 'poll_provider.g.dart';

// 1. Obtener la lista de Votaciones (Ordenadas por fecha de creación)
@riverpod
Stream<List<PollModel>> polls(Ref ref) {
  return Supabase.instance.client
      .from('polls')
      .stream(primaryKey: ['id'])
      .order('end_date', ascending: true)
      .map((data) => data.map((json) => PollModel.fromJson(json)).toList());
}

// 2. Obtener las Opciones de una votación concreta
@riverpod
Stream<List<PollOptionModel>> pollOptions(Ref ref, String pollId) {
  return Supabase.instance.client
      .from('poll_options')
      .stream(primaryKey: ['id'])
      .eq('poll_id', pollId)
      .map((data) => data.map((json) => PollOptionModel.fromJson(json)).toList());
}

// 3. Obtener los Votos de una votación (para contar y saber si ya he votado)
@riverpod
Stream<List<PollVoteModel>> pollVotes(Ref ref, String pollId) {
  return Supabase.instance.client
      .from('poll_votes')
      .stream(primaryKey: ['id'])
      .eq('poll_id', pollId)
      .map((data) => data.map((json) => PollVoteModel.fromJson(json)).toList());
}

// 4. Controlador para emitir un voto
// ... (resto de imports y providers de arriba igual)

@riverpod
class VoteController extends _$VoteController {
  @override
  FutureOr<void> build() {
    ref.keepAlive(); 
  }

  Future<void> submitVote(String pollId, String optionId, bool isMultipleChoice) async {
    final profileAsync = ref.read(currentProfileProvider);
    final profile = profileAsync.value;

    if (profile == null) {
      state = AsyncError('No s\'ha trobat el teu perfil', StackTrace.current);
      return;
    }
    state = const AsyncLoading();

    try {
      if (isMultipleChoice) {
        // LÓGICA MÚLTIPLE: Buscamos si ya votó ESTA opción concreta
        final existingVote = await Supabase.instance.client
            .from('poll_votes').select('id')
            .eq('poll_id', pollId).eq('user_id', profile.id).eq('option_id', optionId)
            .maybeSingle();

        if (existingVote != null) {
          await Supabase.instance.client.from('poll_votes').delete().eq('id', existingVote['id']); // Desmarcar
        } else {
          await Supabase.instance.client.from('poll_votes').insert({'poll_id': pollId, 'option_id': optionId, 'user_id': profile.id}); // Marcar
        }
      } else {
        // LÓGICA ÚNICA (La que ya tenías)
        final existingVote = await Supabase.instance.client
            .from('poll_votes').select('id')
            .eq('poll_id', pollId).eq('user_id', profile.id)
            .maybeSingle();

        if (existingVote != null) {
          await Supabase.instance.client.from('poll_votes').update({'option_id': optionId}).eq('id', existingVote['id']);
        } else {
          await Supabase.instance.client.from('poll_votes').insert({'poll_id': pollId, 'option_id': optionId, 'user_id': profile.id});
        }
      }
      
      ref.invalidate(pollVotesProvider(pollId));
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError('Error al votar: $e', StackTrace.current);
    }
  }
}

@riverpod
  class CreatePollController extends _$CreatePollController {
    @override
    FutureOr<void> build() {}

    Future<void> createPoll({
      required String title,
      String? description,
      required DateTime endDate,
      required List<String> options,
      required bool isMultipleChoice,
    }) async {
      state = const AsyncLoading();
      try {
        final profileAsync = ref.read(currentProfileProvider);
        final profile = profileAsync.value;
        
        if (profile == null) throw Exception('No s\'ha trobat el perfil');

        // 1. Insertamos la votación y recuperamos su ID generado
        final pollResponse = await Supabase.instance.client
            .from('polls')
            .insert({
              'title': title,
              'description': description?.isEmpty ?? true ? null : description,
              'end_date': endDate.toIso8601String(),
              'created_by': profile.id,
              'is_multiple_choice': isMultipleChoice, // <--- AÑADIR ESTA LÍNEA
            })
            .select('id')
            .single();

        final newPollId = pollResponse['id'];

        // 2. Preparamos las opciones y las insertamos de golpe
        final optionsToInsert = options.map((text) => {
          'poll_id': newPollId,
          'text': text.trim(),
        }).toList();

        await Supabase.instance.client.from('poll_options').insert(optionsToInsert);

        ref.invalidate(pollsProvider);
        state = const AsyncData(null);
      } catch (e) {
        state = AsyncError('Error al crear la votació: $e', StackTrace.current);
      }
    }
  }