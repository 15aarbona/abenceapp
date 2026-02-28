import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/data/providers/profile_provider.dart';
import '../../../profile/domain/models/profile_model.dart'; // Importamos el modelo de perfil

part 'attendance_provider.g.dart';

// 1. AHORA devuelve una lista de PERFILES (ProfileModel), no solo Strings
@riverpod
Stream<List<ProfileModel>> eventParticipants(Ref ref, String eventId) {
  return Supabase.instance.client
      .from('event_participants')
      .stream(primaryKey: ['id'])
      .eq('event_id', eventId)
      // Truco: Al usar stream, Supabase nos da el registro de 'event_participants'.
      // Para obtener el perfil completo, necesitamos hacer un 'select' relacional, 
      // pero los Streams de Supabase tienen limitaciones con los Joins complejos.
      
      // ESTRATEGIA MÁS ROBUSTA PARA STREAMS:
      // 1. Escuchamos cambios en la tabla puente.
      // 2. Cuando cambie, pedimos los perfiles completos.
      .asyncMap((data) async {
        if (data.isEmpty) return [];

        // Sacamos todos los user_ids de la lista
        final userIds = data.map((e) => e['user_id'] as String).toList();

        // Pedimos los perfiles de esos usuarios
        final profilesData = await Supabase.instance.client
            .from('profiles')
            .select()
            .inFilter('id', userIds);

        // Convertimos a modelos
        return profilesData.map((json) => ProfileModel.fromJson(json)).toList();
      });
}

// 2. Controller (Se queda casi igual, solo forzamos el refresco)
@riverpod
class AttendanceController extends _$AttendanceController {
  @override
  FutureOr<void> build() {
    ref.keepAlive();
  }

  Future<void> toggleAttendance(String eventId, bool isCurrentlyAttending) async {
    final profileAsync = ref.read(currentProfileProvider);
    final profile = profileAsync.value;

    if (profile == null) {
      state = AsyncError('No se ha encontrado tu perfil', StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    try {
      if (isCurrentlyAttending) {
        await Supabase.instance.client
            .from('event_participants')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', profile.id);
      } else {
        await Supabase.instance.client
            .from('event_participants')
            .insert({
              'event_id': eventId,
              'user_id': profile.id,
            });
      }
      
      // Recargamos la lista
      ref.invalidate(eventParticipantsProvider(eventId));
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}