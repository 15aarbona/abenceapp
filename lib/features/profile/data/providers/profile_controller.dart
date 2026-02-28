import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_provider.dart';

part 'profile_controller.g.dart';

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

// 1. Función general para actualizar datos de texto/fecha
  Future<void> updateProfile({
    String? nombre,
    String? apellidos,
    String? mote,
    String? email,
    String? avatarUrl,
    DateTime? fechaNacimiento,
  }) async {
    state = const AsyncLoading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No hi ha cap usuari autenticat');

      // ⚠️ LA CLAVE ESTÁ AQUÍ: Obtenemos el perfil actual para saber su ID real en la tabla
      final currentProfile = ref.read(currentProfileProvider).value;
      if (currentProfile == null) throw Exception('No s\'ha pogut carregar el perfil');

      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (apellidos != null) updates['apellidos'] = apellidos;
      // Permite borrar el mote si se envía vacío
      if (mote != null) updates['mote'] = mote.isEmpty ? null : mote;
      if (email != null) updates['email'] = email;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (fechaNacimiento != null) updates['fecha_nacimiento'] = fechaNacimiento.toIso8601String();

      // Si cambia el correo, avisamos a la Autenticación
      if (email != null && email != user.email) {
        await Supabase.instance.client.auth.updateUser(UserAttributes(email: email));
      }

      // ⚠️ AHORA USAMOS currentProfile.id EN LUGAR DE user.id
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', currentProfile.id);

      // Obligamos a recargar el perfil
      ref.invalidate(currentProfileProvider);
      
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Error al actualitzar: $e', stack);
      throw e;
    }
  }

  // 2. NUEVA FUNCIÓN: Subir foto de perfil a Supabase Storage
  Future<void> uploadAvatar(XFile imageFile) async {
    state = const AsyncLoading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No hi ha cap usuari autenticat');

      // Leemos el archivo y preparamos la ruta
      final bytes = await imageFile.readAsBytes();
      final fileExtension = imageFile.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = '${user.id}/$fileName'; // Lo guardamos en una carpeta con la ID del usuario

      // Subimos a Storage
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExtension'),
      );

      // Obtenemos el link público de la foto
      final imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);

      // Guardamos la URL en el perfil
      await updateProfile(avatarUrl: imageUrl);
    } catch (e, stack) {
      state = AsyncError('Error al pujar la foto: $e', stack);
      throw e;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}