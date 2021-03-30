part of business_process;

abstract class BPState<S extends _State, E extends Event, P extends Bloc>
    extends _State implements EventCatcher<S, E> {
  /// List of events this state working with.
  /// Use [runtimeType] or enum or anything else to distinct
  /// one event from another
  @override
  List<dynamic> get acceptedEvents;

  /// Checks if event should be processed by this state
  @override
  bool isEventAcceptable(dynamic eventType) =>
      acceptedEvents.contains(eventType);

  Object? _error;

  /// Add error during processing event in [processEvent]. Error will be dispatched
  /// by [BlocBase.addError] only if [processEvent] return null
  @override
  void addError(Object error) {
    _error = error;
  }

  /// See [addError]
  @override
  Object? get error => _error;

  late P _bp;

  P get bp => _bp;

  void init(P process) {
    _bp = process;
  }

  /// Every state should be able to be (de)serialized
  @mustCallSuper
  Map<String, dynamic> toJson() => {'type': runtimeType};

  @override
  S? processEvent(E event);
}
