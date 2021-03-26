part of business_process;

abstract class Event {
  Event([this.tag]);

  final String? tag;

  dynamic get type;
}
