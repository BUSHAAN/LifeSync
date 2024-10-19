import 'dart:ui';

class DailyItem {
  DailyItem(
      {required this.itemName,
      required this.from,
      required this.to,
      required this.background,
      required this.isAllDay,
      required this.isEvent,
      required this.userId,
      this.isCompleted});

  String itemName;
  String userId;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  bool isEvent;
  bool? isCompleted;
}
