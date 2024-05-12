class DailyItem {
  String itemName;
  String userId;
  double duration;
  bool isEvent;
  DateTime? dateTime;

  DailyItem(
      {required this.itemName,
      required this.userId,
      required this.isEvent,
      required this.duration,
      required this.dateTime});
}
