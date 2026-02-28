// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentProfile)
final currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends $StreamNotifierProvider<CurrentProfile, ProfileModel?> {
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  CurrentProfile create() => CurrentProfile();
}

String _$currentProfileHash() => r'c716299f051283394c9a4f17b8c670675440ee37';

abstract class _$CurrentProfile extends $StreamNotifier<ProfileModel?> {
  Stream<ProfileModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ProfileModel?>, ProfileModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfileModel?>, ProfileModel?>,
              AsyncValue<ProfileModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
