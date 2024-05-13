import 'dart:ui';

class DailyItem {
  DailyItem(this.itemName, this.from, this.to, this.background, this.isAllDay,
      this.isEvent,this.userId);

  String itemName;
  String userId;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  bool isEvent;
}
