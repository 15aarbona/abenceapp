// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateMemberController)
final createMemberControllerProvider = CreateMemberControllerProvider._();

final class CreateMemberControllerProvider
    extends $AsyncNotifierProvider<CreateMemberController, void> {
  CreateMemberControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createMemberControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createMemberControllerHash();

  @$internal
  @override
  CreateMemberController create() => CreateMemberController();
}

String _$createMemberControllerHash() =>
    r'c4da01bcff41aeb0c7e70db5e76f4bea4843879c';

abstract class _$CreateMemberController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
