// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FamilyLinks)
final familyLinksProvider = FamilyLinksProvider._();

final class FamilyLinksProvider
    extends $AsyncNotifierProvider<FamilyLinks, List<Map<String, dynamic>>> {
  FamilyLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyLinksHash();

  @$internal
  @override
  FamilyLinks create() => FamilyLinks();
}

String _$familyLinksHash() => r'445d820eafac5972103cb557917288849845708b';

abstract class _$FamilyLinks
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
