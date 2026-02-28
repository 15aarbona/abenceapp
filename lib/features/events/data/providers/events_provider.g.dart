// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allEvents)
final allEventsProvider = AllEventsProvider._();

final class AllEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          FutureOr<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $FutureProvider<List<EventModel>> {
  AllEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventModel>> create(Ref ref) {
    return allEvents(ref);
  }
}

String _$allEventsHash() => r'36aa41e170e2a4b22afbc87d14796ee984b63eb6';

@ProviderFor(upcomingEvents)
final upcomingEventsProvider = UpcomingEventsProvider._();

final class UpcomingEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          FutureOr<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $FutureProvider<List<EventModel>> {
  UpcomingEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventModel>> create(Ref ref) {
    return upcomingEvents(ref);
  }
}

String _$upcomingEventsHash() => r'0d53c5f42a714b59a2c55af47b1cb6fabb5dac1e';

@ProviderFor(pastEvents)
final pastEventsProvider = PastEventsProvider._();

final class PastEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          FutureOr<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $FutureProvider<List<EventModel>> {
  PastEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EventModel>> create(Ref ref) {
    return pastEvents(ref);
  }
}

String _$pastEventsHash() => r'6f5241783a1324b2d499c8a7b8020c6824d52678';

@ProviderFor(CreateEventController)
final createEventControllerProvider = CreateEventControllerProvider._();

final class CreateEventControllerProvider
    extends $AsyncNotifierProvider<CreateEventController, void> {
  CreateEventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createEventControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createEventControllerHash();

  @$internal
  @override
  CreateEventController create() => CreateEventController();
}

String _$createEventControllerHash() =>
    r'972d93f0278ac7c01f34f25cc5103ac8cafbaba9';

abstract class _$CreateEventController extends $AsyncNotifier<void> {
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

@ProviderFor(eventAttendees)
final eventAttendeesProvider = EventAttendeesFamily._();

final class EventAttendeesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  EventAttendeesProvider._({
    required EventAttendeesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventAttendeesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAttendeesHash();

  @override
  String toString() {
    return r'eventAttendeesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return eventAttendees(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventAttendeesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAttendeesHash() => r'614cfb8414020f3151c4d2b561903d14879200a6';

final class EventAttendeesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          String
        > {
  EventAttendeesFamily._()
    : super(
        retry: null,
        name: r'eventAttendeesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAttendeesProvider call(String eventId) =>
      EventAttendeesProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventAttendeesProvider';
}

@ProviderFor(AttendEventController)
final attendEventControllerProvider = AttendEventControllerProvider._();

final class AttendEventControllerProvider
    extends $AsyncNotifierProvider<AttendEventController, void> {
  AttendEventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendEventControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendEventControllerHash();

  @$internal
  @override
  AttendEventController create() => AttendEventController();
}

String _$attendEventControllerHash() =>
    r'36f3474c08b6e211f395f21cfe05cc1f302d0a99';

abstract class _$AttendEventController extends $AsyncNotifier<void> {
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

@ProviderFor(DeleteEventController)
final deleteEventControllerProvider = DeleteEventControllerProvider._();

final class DeleteEventControllerProvider
    extends $AsyncNotifierProvider<DeleteEventController, void> {
  DeleteEventControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteEventControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteEventControllerHash();

  @$internal
  @override
  DeleteEventController create() => DeleteEventController();
}

String _$deleteEventControllerHash() =>
    r'18aee5e528dce2a8f1d31906a993429d5f04ef65';

abstract class _$DeleteEventController extends $AsyncNotifier<void> {
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
