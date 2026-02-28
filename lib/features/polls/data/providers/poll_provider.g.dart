// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(polls)
final pollsProvider = PollsProvider._();

final class PollsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PollModel>>,
          List<PollModel>,
          Stream<List<PollModel>>
        >
    with $FutureModifier<List<PollModel>>, $StreamProvider<List<PollModel>> {
  PollsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pollsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pollsHash();

  @$internal
  @override
  $StreamProviderElement<List<PollModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PollModel>> create(Ref ref) {
    return polls(ref);
  }
}

String _$pollsHash() => r'3ae8b9bfd5845c3641f51038c225b66a2c8dc342';

@ProviderFor(pollOptions)
final pollOptionsProvider = PollOptionsFamily._();

final class PollOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PollOptionModel>>,
          List<PollOptionModel>,
          Stream<List<PollOptionModel>>
        >
    with
        $FutureModifier<List<PollOptionModel>>,
        $StreamProvider<List<PollOptionModel>> {
  PollOptionsProvider._({
    required PollOptionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pollOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pollOptionsHash();

  @override
  String toString() {
    return r'pollOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PollOptionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PollOptionModel>> create(Ref ref) {
    final argument = this.argument as String;
    return pollOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PollOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pollOptionsHash() => r'e22359e3c9e6abca764dcfb14b8bbf503945ab44';

final class PollOptionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PollOptionModel>>, String> {
  PollOptionsFamily._()
    : super(
        retry: null,
        name: r'pollOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PollOptionsProvider call(String pollId) =>
      PollOptionsProvider._(argument: pollId, from: this);

  @override
  String toString() => r'pollOptionsProvider';
}

@ProviderFor(pollVotes)
final pollVotesProvider = PollVotesFamily._();

final class PollVotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PollVoteModel>>,
          List<PollVoteModel>,
          Stream<List<PollVoteModel>>
        >
    with
        $FutureModifier<List<PollVoteModel>>,
        $StreamProvider<List<PollVoteModel>> {
  PollVotesProvider._({
    required PollVotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pollVotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pollVotesHash();

  @override
  String toString() {
    return r'pollVotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PollVoteModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PollVoteModel>> create(Ref ref) {
    final argument = this.argument as String;
    return pollVotes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PollVotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pollVotesHash() => r'f489a462bdbb52439daeed6fbbdaa94567d8c8a2';

final class PollVotesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PollVoteModel>>, String> {
  PollVotesFamily._()
    : super(
        retry: null,
        name: r'pollVotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PollVotesProvider call(String pollId) =>
      PollVotesProvider._(argument: pollId, from: this);

  @override
  String toString() => r'pollVotesProvider';
}

@ProviderFor(VoteController)
final voteControllerProvider = VoteControllerProvider._();

final class VoteControllerProvider
    extends $AsyncNotifierProvider<VoteController, void> {
  VoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voteControllerHash();

  @$internal
  @override
  VoteController create() => VoteController();
}

String _$voteControllerHash() => r'94ccc50b10a1ab0bf51d2d88d26b48925e488ccc';

abstract class _$VoteController extends $AsyncNotifier<void> {
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

@ProviderFor(CreatePollController)
final createPollControllerProvider = CreatePollControllerProvider._();

final class CreatePollControllerProvider
    extends $AsyncNotifierProvider<CreatePollController, void> {
  CreatePollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPollControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPollControllerHash();

  @$internal
  @override
  CreatePollController create() => CreatePollController();
}

String _$createPollControllerHash() =>
    r'4a606b16518d5ff6aa07c8cd110deb9addf04338';

abstract class _$CreatePollController extends $AsyncNotifier<void> {
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
