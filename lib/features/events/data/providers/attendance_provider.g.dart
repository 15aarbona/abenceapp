// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventParticipants)
final eventParticipantsProvider = EventParticipantsFamily._();

final class EventParticipantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileModel>>,
          List<ProfileModel>,
          Stream<List<ProfileModel>>
        >
    with
        $FutureModifier<List<ProfileModel>>,
        $StreamProvider<List<ProfileModel>> {
  EventParticipantsProvider._({
    required EventParticipantsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventParticipantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventParticipantsHash();

  @override
  String toString() {
    return r'eventParticipantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ProfileModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProfileModel>> create(Ref ref) {
    final argument = this.argument as String;
    return eventParticipants(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventParticipantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventParticipantsHash() => r'fbfbffb68306efa9d7f34b62941ac26b9a0adb7d';

final class EventParticipantsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ProfileModel>>, String> {
  EventParticipantsFamily._()
    : super(
        retry: null,
        name: r'eventParticipantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventParticipantsProvider call(String eventId) =>
      EventParticipantsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventParticipantsProvider';
}

@ProviderFor(AttendanceController)
final attendanceControllerProvider = AttendanceControllerProvider._();

final class AttendanceControllerProvider
    extends $AsyncNotifierProvider<AttendanceController, void> {
  AttendanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceControllerHash();

  @$internal
  @override
  AttendanceController create() => AttendanceController();
}

String _$attendanceControllerHash() =>
    r'a28f201f1c780750555ca917497628000a26f9ce';

abstract class _$AttendanceController extends $AsyncNotifier<void> {
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
