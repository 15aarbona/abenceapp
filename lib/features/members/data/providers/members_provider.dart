import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../profile/domain/models/profile_model.dart';

part 'members_provider.g.dart';

@riverpod
// 👇 VOLVEMOS A PONER AllMembersRef
Future<List<ProfileModel>> allMembers(Ref ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('profiles')
      .select()
      .order('nombre', ascending: true);

  return (response as List)
      .map((json) => ProfileModel.fromJson(json))
      .toList();
}