part of business_process;

typedef SubProcessBuilder = BusinessProcess Function();

class BusinessProcess<E extends Event, S extends BPState> extends Bloc<E, S> {
  BusinessProcess(S initialState, {String? tag, BusinessProcess? parent})
      : parent = parent,
        super(initialState) {
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
  S? processEvent(E event) {
    final tag = event.tag;
    if (tag != null) {
      try {
        final subProcess = findSubProcess(tag);
        subProcess.add(event);
      } catch (error) {
        print(error);
      }
    } else {
      if (state.isEventAcceptable(event.type)) {
        final nextState = state.onEvent(event, this);
        if (nextState == null) {
          final error = state.error;
          if (error != null) {
            addError(error);
          }
        } else {
          _lastState = state;
          return nextState as S;
        }
      } else {
        for (var spEntry in _subProcess.entries) {
          if (spEntry.value.state.isEventAcceptable(event.type)) {
            spEntry.value.add(event);
          }
        }
      }
    }
    return null;
  }

  /// Called after next state successful calculation, but before the state is
  /// yielded. Does not fire, when next state is null.
  void onNextState(E event, S nextState) {}

  @override
  Stream<S> mapEventToState(E event) async* {
    final nextState = processEvent(event);
    if (nextState != null) {
      onNextState(event, nextState);
      yield nextState;
    }
  }
}
