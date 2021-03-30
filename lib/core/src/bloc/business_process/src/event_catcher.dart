part of business_process;

abstract class EventCatcher<S extends _State, E extends Event> extends _State {
  /// List of events this state working with.
  /// Use [runtimeType] or enum or anything else to distinct
  /// one event from another
  List<dynamic> get acceptedEvents;

  /// Checks if event should be processed by this state
  bool isEventAcceptable(dynamic eventType) =>
      acceptedEvents.contains(eventType);

  /// Add error during processing event in [processEvent]. Error will be dispatched
  /// by [BlocBase.addError] only if [processEvent] return null
  void addError(Object error);

  /// See [addError]
  Object? get error;

  /// Process new state. Return null, if no state changes needed. Use
  /// [addError] for additional information if null returned
  S? processEvent(E event);
}

abstract class _State {}
