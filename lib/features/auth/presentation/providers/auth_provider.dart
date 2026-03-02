import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart'; // Esto generará error hasta que ejecutemos el build_runner

@riverpod
class Auth extends _$Auth {
  @override
  Stream<User?> build() {
    // Escucha cambios en tiempo real (login/logout)
    return Supabase.instance.client.auth.onAuthStateChange.map((event) {
      return event.session?.user;
    });
  }

  // Método para Iniciar Sesión
  Future<void> signIn(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    ref.invalidateSelf(); 
  }

  // Método para Registrarse
  Future<void> signUp({
    required String email, 
    required String password, 
    required String nombre, 
    required String apellidos,
    required String dni,
    required DateTime fechaNacimiento,
  }) async {
    // 1. Registro en Supabase Auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      final supabase = Supabase.instance.client;

      // 2. Cálculo del Rol según la edad
      final int currentYear = DateTime.now().year;
      final int ageThisYear = currentYear - fechaNacimiento.year;
      String rolCalculado = 'miembro';
      if (ageThisYear < 16) rolCalculado = 'nino';
      else if (ageThisYear <= 21) rolCalculado = 'joven';

      // 3. Buscamos si el admin ya le había creado un hueco por email
      final existingPreProfile = await supabase
          .from('profiles')
          .select()
          .eq('email', email.toLowerCase().trim())
          .isFilter('auth_id', null)
          .maybeSingle();

      if (existingPreProfile != null) {
        // ACTUALIZAMOS el perfil que creó el admin
        await supabase.from('profiles').update({
          'auth_id': user.id,
          'nombre': nombre,
          'apellidos': apellidos,
          'dni': dni,
          'fecha_nacimiento': fechaNacimiento.toIso8601String(),
          'rol': rolCalculado,
        }).eq('id', existingPreProfile['id']);

        // Borramos el perfil duplicado que el Trigger de la BD suele crear solo
        await supabase.from('profiles').delete()
            .eq('auth_id', user.id)
            .neq('id', existingPreProfile['id']);
      } else {
        // Si no existía previa alta, actualizamos el perfil que creó el trigger
        await supabase.from('profiles').update({
          'nombre': nombre,
          'apellidos': apellidos,
          'dni': dni,
          'fecha_nacimiento': fechaNacimiento.toIso8601String(),
          'rol': rolCalculado,
        }).eq('auth_id', user.id);
      }
    }

    ref.invalidateSelf();
  }
  // Método para Cerrar Sesión
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}