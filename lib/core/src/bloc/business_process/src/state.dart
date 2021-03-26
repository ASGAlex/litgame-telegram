part of business_process;

abstract class BPState<S extends _State, E extends Event, P extends Bloc>
    extends _State {
  /// List of events this state working with.
  /// Use [runtimeType] or enum or anything else to distinct
  /// one event from another
  List<dynamic> get acceptedEvents;

  /// Checks if event should be processed by this state
  bool isEventAcceptable(dynamic eventType) =>
      acceptedEvents.contains(eventType);

  /// Process new state. Return null, if no state changes needed. Use
  /// [addError] for additional information if null returned
  S? onEvent(E event, P bp);

  Object? _error;

  /// Add error during processing event in [onEvent]. Error will be dispatched
  /// by [BlocBase.addError] only if [onEvent] return null
  void addError(Object error) {
    _error = error;
  }

  /// See [addError]
  Object? get error => _error;

  /// Every state should be able to be (de)serialized
  @mustCallSuper
  Map<String, dynamic> toJson() => {'type': runtimeType};
}

abstract class _State {}
