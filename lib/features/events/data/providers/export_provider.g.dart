// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportEventController)
final exportEventControllerProvider = ExportEventControllerProvider._();

final class ExportEventControllerProvider
    extends $AsyncNotifierProvider<ExportEventController, void> {
  ExportEventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportEventControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportEventControllerHash();

  @$internal
  @override
  ExportEventController create() => ExportEventController();
}

String _$exportEventControllerHash() =>
    r'c41b47aa6578dac271c6fdb9ae63ba6080f98a36';

abstract class _$ExportEventController extends $AsyncNotifier<void> {
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
