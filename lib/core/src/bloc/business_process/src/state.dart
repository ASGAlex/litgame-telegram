part of business_process;

abstract class BPState<Event> {
  List<Event> get acceptedEvents;

  bool isEventAcceptable(Event event) => acceptedEvents.contains(event);

  BPState? getNextState(Process bp);
}
