import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importamos el provider de miembros para recargar la lista
import '../../../members/data/providers/members_provider.dart';

part 'create_member_provider.g.dart';

@riverpod
class CreateMemberController extends _$CreateMemberController {
  @override
  FutureOr<void> build() {}

  Future<void> createMember({
    required String nombre,
    required String apellidos,
    required String email,
  }) async {
    state = const AsyncLoading();
    try {
      final supabase = Supabase.instance.client;

      // Insertamos el perfil "en espera"
      await supabase.from('profiles').insert({
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'email': email.trim().toLowerCase(),
        'rol': 'miembro', // Rol provisional
        'tipo_cuota': 'full',
        'auth_id': null, 
      });

      ref.invalidate(allMembersProvider);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}