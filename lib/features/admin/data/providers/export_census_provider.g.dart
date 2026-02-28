// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_census_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportCensusController)
final exportCensusControllerProvider = ExportCensusControllerProvider._();

final class ExportCensusControllerProvider
    extends $AsyncNotifierProvider<ExportCensusController, void> {
  ExportCensusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportCensusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportCensusControllerHash();

  @$internal
  @override
  ExportCensusController create() => ExportCensusController();
}

String _$exportCensusControllerHash() =>
    r'be52e91b89516eba259779c453443d2ec76ccd19';

abstract class _$ExportCensusController extends $AsyncNotifier<void> {
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
