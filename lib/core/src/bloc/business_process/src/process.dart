part of business_process;

class Process<Event> extends Bloc<Event, BPState> {
  Process(BPState initialState) : super(initialState);

  @override
  Stream<BPState> mapEventToState(Event event) async* {
    if (!state.isEventAcceptable(event)) return;
    final nextState = state.getNextState(this);
    if (nextState != null) {
      yield nextState;
    }
  }
}
