import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/profile_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'profile_provider.g.dart';

@riverpod
class CurrentProfile extends _$CurrentProfile {
  @override
  Stream<ProfileModel?> build() {
    // 1. Escuchamos el estado de autenticación
    final authState = ref.watch(authProvider);

    // 2. Si no hay usuario logueado, devolvemos null
    if (authState.value == null) {
      return Stream.value(null);
    }

    final userId = authState.value!.id;

    // 3. Nos suscribimos a cambios en MI perfil en tiempo real
    // (Si un admin te cambia el rol, la app se entera al instante)
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('auth_id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return ProfileModel.fromJson(data.first);
        });
  }
}