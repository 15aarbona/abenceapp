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
  }

  // Método para Registrarse
  Future<void> signUp(String email, String password, String nombre, String apellidos) async {
    // 1. Crear usuario en Auth
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nombre': nombre, // Metadata extra si la necesitamos luego
        'apellidos': apellidos,
      },
    );

    // 2. El trigger de SQL que creamos antes ('handle_new_user') 
    // se encargará de crear la fila en la tabla 'profiles' automáticamente.
    // Pero actualizaremos los datos justo después para asegurar nombre y apellidos
    if (response.user != null) {
      await Supabase.instance.client.from('profiles').update({
        'nombre': nombre,
        'apellidos': apellidos,
      }).eq('auth_id', response.user!.id);
    }
  }

  // Método para Cerrar Sesión
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}