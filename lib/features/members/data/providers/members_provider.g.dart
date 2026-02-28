// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allMembers)
final allMembersProvider = AllMembersProvider._();

final class AllMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileModel>>,
          List<ProfileModel>,
          FutureOr<List<ProfileModel>>
        >
    with
        $FutureModifier<List<ProfileModel>>,
        $FutureProvider<List<ProfileModel>> {
  AllMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<ProfileModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileModel>> create(Ref ref) {
    return allMembers(ref);
  }
}

String _$allMembersHash() => r'4b68805026ae685af4dc6211ac40040782955074';
