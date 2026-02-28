import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'family_provider.g.dart';

@riverpod
class FamilyLinks extends _$FamilyLinks {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final supabase = Supabase.instance.client;
    // Leemos todos los vínculos creados
    final response = await supabase.from('vinculos_familiares').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addLink(String padreId, String hijoId) async {
    if (padreId == hijoId) {
      throw Exception('Una persona no pot ser el seu propi pare/fill.');
    }
    
    final supabase = Supabase.instance.client;
    await supabase.from('vinculos_familiares').insert({
      'padre_id': padreId,
      'hijo_id': hijoId,
    });
    
    // Recargamos la lista automáticamente
    ref.invalidateSelf();
  }

  Future<void> removeLink(String id) async {
    final supabase = Supabase.instance.client;
    await supabase.from('vinculos_familiares').delete().eq('id', id);
    ref.invalidateSelf();
  }
}