// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(announcements)
final announcementsProvider = AnnouncementsProvider._();

final class AnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnnouncementModel>>,
          List<AnnouncementModel>,
          Stream<List<AnnouncementModel>>
        >
    with
        $FutureModifier<List<AnnouncementModel>>,
        $StreamProvider<List<AnnouncementModel>> {
  AnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsHash();

  @$internal
  @override
  $StreamProviderElement<List<AnnouncementModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AnnouncementModel>> create(Ref ref) {
    return announcements(ref);
  }
}

String _$announcementsHash() => r'47882ce1a463a2e2484880e6659114ab8255f03a';

@ProviderFor(CreateAnnouncementController)
final createAnnouncementControllerProvider =
    CreateAnnouncementControllerProvider._();

final class CreateAnnouncementControllerProvider
    extends $AsyncNotifierProvider<CreateAnnouncementController, void> {
  CreateAnnouncementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createAnnouncementControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createAnnouncementControllerHash();

  @$internal
  @override
  CreateAnnouncementController create() => CreateAnnouncementController();
}

String _$createAnnouncementControllerHash() =>
    r'aed9fc6c21c1cc3ef61ca75541eed796d93fb533';

abstract class _$CreateAnnouncementController extends $AsyncNotifier<void> {
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

@ProviderFor(DeleteAnnouncementController)
final deleteAnnouncementControllerProvider =
    DeleteAnnouncementControllerProvider._();

final class DeleteAnnouncementControllerProvider
    extends $AsyncNotifierProvider<DeleteAnnouncementController, void> {
  DeleteAnnouncementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAnnouncementControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAnnouncementControllerHash();

  @$internal
  @override
  DeleteAnnouncementController create() => DeleteAnnouncementController();
}

String _$deleteAnnouncementControllerHash() =>
    r'c785525a6f3ea8cdc5292680381ee6e859af4c70';

abstract class _$DeleteAnnouncementController extends $AsyncNotifier<void> {
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
