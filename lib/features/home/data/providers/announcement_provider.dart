import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT CORREGIDO (Subimos 2 niveles con ../../) ---
import '../../domain/models/announcement_model.dart';
import '../../../profile/data/providers/profile_provider.dart';

part 'announcement_provider.g.dart';

// 1. Obtener la lista de anuncios ordenados por los más recientes
@riverpod
Stream<List<AnnouncementModel>> announcements(Ref ref) async* {
  final client = Supabase.instance.client;

  // Escuchamos los anuncios reales de Supabase
  final stream = client
      .from('announcements')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  // Cada vez que hay un cambio, combinamos la lista
  await for (final data in stream) {
    final normalAnnouncements = data.map((json) => AnnouncementModel.fromJson(json)).toList();
    final List<AnnouncementModel> birthdayAnnouncements = [];

    try {
      // ⚠️ OJO: Ajusta 'fecha_nacimiento', 'nombre', 'apellidos' a los nombres de tus columnas reales
      final profiles = await client.from('profiles').select('id, nombre, apellidos, fecha_nacimiento');
      final today = DateTime.now();

      for (var p in profiles) {
        if (p['fecha_nacimiento'] != null) {
          final birthDate = DateTime.parse(p['fecha_nacimiento'].toString());
          
          // Si el mes y el día coinciden con HOY
          if (birthDate.month == today.month && birthDate.day == today.day) {
            final nombreCompleto = '${p['nombre']} ${p['apellidos'] ?? ''}'.trim();
            
            // Creamos un anuncio VIRTUAL
            birthdayAnnouncements.add(
              AnnouncementModel(
                id: 'cumple_${p['id']}', // ID especial para identificarlo
                title: '🎂 Feliç Aniversari!',
                description: 'Avui és l\'aniversari de $nombreCompleto. No t\'oblidis de felicitar-lo!',
                createdAt: DateTime(today.year, today.month, today.day),
              )
            );
          }
        }
      }
    } catch (e) {
      print('🔴 Error al buscar cumples: $e');
    }

    // Devolvemos la lista con los cumpleaños PRIMERO, y luego los normales
    yield [...birthdayAnnouncements, ...normalAnnouncements];
  }
}

// 2. Controlador para crear un nuevo anuncio
@Riverpod(keepAlive: true)
class CreateAnnouncementController extends _$CreateAnnouncementController {
  @override
  FutureOr<void> build() {}

  Future<void> createAnnouncement(String title, String description) async {
    state = const AsyncLoading();
    try {
      final profileAsync = ref.read(currentProfileProvider);
      final profile = profileAsync.value;
      
      if (profile == null) throw Exception('No s\'ha trobat el perfil');
      if (!profile.isAdmin) throw Exception('No tens permisos d\'administrador');

      // 1. Guardamos en la base de datos
      await Supabase.instance.client.from('announcements').insert({
        'title': title,
        'description': description,
        'created_by': profile.id,
      });

      // 2. ¡LA LÍNEA MÁGICA! Le decimos a la app que recargue los anuncios
      ref.invalidate(announcementsProvider);

      state = const AsyncData(null);
    } catch (e, stack) {
      print('🔴 Error en Supabase al crear anuncio: $e'); 
      state = AsyncError('Error al crear l\'anunci: $e', stack);
      throw e; 
    }
  }
}

// 3. Controlador para borrar un anuncio
@Riverpod(keepAlive: true)
class DeleteAnnouncementController extends _$DeleteAnnouncementController {
  @override
  FutureOr<void> build() {}

  Future<void> deleteAnnouncement(String announcementId) async {
    state = const AsyncLoading();
    try {
      final profileAsync = ref.read(currentProfileProvider);
      final profile = profileAsync.value;
      
      if (profile == null) throw Exception('No s\'ha trobat el perfil');
      if (!profile.isAdmin) throw Exception('No tens permisos d\'administrador');

      // Borramos de Supabase
      await Supabase.instance.client
          .from('announcements')
          .delete()
          .eq('id', announcementId);

      // Recargamos la lista
      ref.invalidate(announcementsProvider);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Error al esborrar l\'anunci: $e', stack);
      throw e;
    }
  }
}