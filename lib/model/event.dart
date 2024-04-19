class Event {
  String userId;
  String eventName;
  String frequency;
  List<int>? selectedWeekdays;
  DateTime? startTime;
  DateTime? endTime;

  Event(
      {required this.userId,
      required this.eventName,
      this.selectedWeekdays,
      required this.startTime,
      required this.endTime,
      required this.frequency});
}
