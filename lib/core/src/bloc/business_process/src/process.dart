part of business_process;

typedef SubProcessBuilder = BusinessProcess Function();

abstract class BusinessProcess<E extends Event, S extends BPState>
    extends Bloc<E, S> implements EventCatcher<S, E> {
  BusinessProcess(S initialState, {String? tag, BusinessProcess? parent})
      : parent = parent,
        super(initialState) {
    initialState.init(this);
    tag ??= hashCode.toString();
    this.tag = tag;
  }

  final BusinessProcess? parent;

  S? _lastState;

  /// Getting previous state is useful when we don't know exact state, but only
  /// need to restore previous.
  S? get lastState => _lastState;

  final Map<String, BusinessProcess> _subProcess = {};

  late final String tag;

  /// Run business process inside of current process.
  /// Sub-process should have it's own state and does not affect to parent's
  /// state directly.
  /// Builder function should contain a constructor of new business process.
  /// Specify [BusinessProcess.tag] in constructor to find process instance
  /// later. See [findSubProcess]
  BusinessProcess runSubProcess(SubProcessBuilder builder) {
    final subProcess = builder();
    if (_subProcess.containsKey(subProcess.tag)) {
      throw Exception('Process with tag "$tag" already exists');
    }
    _subProcess[subProcess.tag] = subProcess;
    return subProcess;
  }

  BusinessProcess findSubProcess(String tag) {
    final process = _subProcess[tag];
    if (process == null) throw Exception('Process with tag "$tag" not found.');
    return process;
  }

  void stopSubProcess(String tag) {
    try {
      final process = findSubProcess(tag);
      process.close();
      _subProcess.remove(tag);
    } catch (error) {
      print(error);
    }
  }

  @override
  @mustCallSuper
  Future<void> close() {
    for (var processEntry in _subProcess.entries) {
      processEntry.value.close();
      // _subProcess.remove(processEntry.key);
    }
    return super.close();
  }

  /// Do [mapEventToState] job, but more friendly for reimplementing in
  /// child classes.
  /// Main functions:
  ///  - Dispatches events to sub-processes,
  ///  - Run state operations
  ///  - Collect errors
  ///
  /// Reimplement this, if you need a global event handler, not related to
  /// any state.
  @override
  S? processEvent(E event);

  bool runSubProcessByTag(E event) {
    final tag = event.tag;
    if (tag != null) {
      try {
        final subProcess = findSubProcess(tag);
        subProcess.add(event);
      } catch (error) {
        print(error);
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  Stream<S> mapEventToState(E event) async* {
    if (!runSubProcessByTag(event)) {
      S? nextState;
      Object? err;
      if (isEventAcceptable(event.type)) {
        nextState = processEvent(event);
      }
      if (state.isEventAcceptable(event.type)) {
        nextState = state.processEvent(event) as S?;
        err = state.error;
      } else {
        for (var spEntry in _subProcess.entries) {
          if (spEntry.value.state.isEventAcceptable(event.type)) {
            spEntry.value.add(event);
          }
        }
      }

      if (nextState != null) {
        nextState.init(this);
        _lastState = state;
        yield nextState;
      } else {
        if (err != null) {
          addError(err);
        }
      }
    }
  }

  @override
  // ignore: must_call_super
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onError(this, error, stackTrace);
  }

  @override
  List get acceptedEvents => [];

  Object? _error;

  @override
  Object? get error => _error;

  @override
  bool isEventAcceptable(eventType) => acceptedEvents.contains(eventType);
}
