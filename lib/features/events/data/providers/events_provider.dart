import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/event_model.dart';

part 'events_provider.g.dart';

// 1. Provider base: Descarga TODOS los eventos (Ahora es un Future normal, no un Stream)
@riverpod
Future<List<EventModel>> allEvents(Ref ref) async {
  final response = await Supabase.instance.client
      .from('events')
      .select() // <--- CAMBIAMOS .stream() por .select()
      .order('event_date', ascending: true);
      
  return response.map((json) => EventModel.fromJson(json)).toList();
}

// 2. Provider derivado: Filtra solo los FUTUROS
@riverpod
Future<List<EventModel>> upcomingEvents(Ref ref) async {
  // Como ahora allEvents es un Future, lo vigilamos así:
  final events = await ref.watch(allEventsProvider.future);
  
  final now = DateTime.now();
  return events.where((e) => e.eventDate.isAfter(now.subtract(const Duration(hours: 12)))).toList();
}

// 3. Provider derivado: Filtra los PASADOS
@riverpod
Future<List<EventModel>> pastEvents(Ref ref) async {
  // Igual aquí, vigilamos el future
  final events = await ref.watch(allEventsProvider.future);

  final now = DateTime.now();
  return events.where((e) => e.eventDate.isBefore(now.subtract(const Duration(hours: 12)))).toList();
}

@riverpod
class CreateEventController extends _$CreateEventController {
  @override
  FutureOr<void> build() {}

  Future<void> createEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    String? location,
    required List<String> menuOptions, // <--- NUEVO PARÁMETRO
  }) async {
    state = const AsyncLoading();
    try {
      // Si hay opciones de menú, las guardamos en el mapa JSON
      final optionsJson = menuOptions.isNotEmpty ? {'menu': menuOptions} : null;

      await Supabase.instance.client.from('events').insert({
        'title': title,
        'description': description?.isEmpty ?? true ? null : description,
        'event_date': eventDate.toIso8601String(),
        'location': location?.isEmpty ?? true ? null : location,
        'is_active': true,
        'options': optionsJson, // <--- GUARDAMOS LAS OPCIONES AQUÍ
      });

      ref.invalidate(allEventsProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError('Error al crear l\'esdeveniment: $e', StackTrace.current);
    }
  }
}

// Provider para obtener los asistentes de un evento concreto (Actualizado con perfiles)
@riverpod
Future<List<Map<String, dynamic>>> eventAttendees(Ref ref, String eventId) async {
  final response = await Supabase.instance.client
      .from('event_attendees')
      .select('id, user_id, guest_name, menu_option, created_at, profiles(nombre, apellidos)')
      .eq('event_id', eventId)
      .order('created_at', ascending: true);
  return response;
}

// Controlador para apuntarse a un evento
@riverpod
class AttendEventController extends _$AttendEventController {
  @override
  FutureOr<void> build() {}

  Future<void> attend({
    required String eventId,
    String? guestName,
    String? menuOption,
    String? forUserId, // <--- 1. NUEVO PARÁMETRO
  }) async {
    state = const AsyncLoading();
    try {
      String targetId = forUserId ?? '';

      // Si no nos pasan un ID específico (como el de un hijo), usamos el nuestro
      if (targetId.isEmpty) {
        final authId = Supabase.instance.client.auth.currentUser!.id;
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('id')
            .eq('auth_id', authId)
            .single();
        targetId = profileData['id'];
      }

      // 3. Apuntamos usando el targetId (sea el padre o el hijo)
      await Supabase.instance.client.from('event_attendees').insert({
        'event_id': eventId,
        'user_id': targetId, 
        'guest_name': guestName?.trim().isEmpty ?? true ? null : guestName!.trim(),
        'menu_option': menuOption,
      });

      // Recargamos la lista
      ref.invalidate(eventAttendeesProvider(eventId));
      state = const AsyncData(null);
    } catch (e, stack) {
      print('🚨 ERROR AL APUNTARSE: $e');
      state = AsyncError('Error al apuntar-se: $e', stack);
    }
  }

  Future<void> removeAttendance(String attendeeId, String eventId) async {
    state = const AsyncLoading();
    try {
      await Supabase.instance.client.from('event_attendees').delete().eq('id', attendeeId);
      ref.invalidate(eventAttendeesProvider(eventId));
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError('Error al esborrar: $e', StackTrace.current);
    }
  }
}

// Controlador para borrar un evento
@Riverpod(keepAlive: true)
class DeleteEventController extends _$DeleteEventController {
  @override
  FutureOr<void> build() {}

  Future<void> deleteEvent(String eventId) async {
    state = const AsyncLoading();
    try {
      // 1. TRUCO NINJA: Cambiamos la fecha al año 2000. 
      // Al hacer esto, la app lo quita de "Pròxims" y lo manda a "Passats" al instante.
      await Supabase.instance.client.from('events').update({
        'event_date': DateTime(2000, 1, 1).toIso8601String(),
      }).eq('id', eventId);

      // 2. Lo borramos de verdad en la base de datos. 
      // Cuando el usuario recargue la app en el futuro, ya no existirá ni en pasados.
      await Supabase.instance.client.from('events').delete().eq('id', eventId);

      // Limpiamos los providers por si acaso
      ref.invalidate(allEventsProvider);
      ref.invalidate(upcomingEventsProvider);
      ref.invalidate(pastEventsProvider);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Error al esborrar l\'esdeveniment: $e', stack);
    }
  }
}