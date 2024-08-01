// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, await_only_futures, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/daily_item.dart';
import 'package:flutter_todo_app/model/daily_item_data_source.dart';
import 'package:flutter_todo_app/services/firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SchedulingSection extends StatefulWidget {
  const SchedulingSection({super.key});

  @override
  State<SchedulingSection> createState() => _SchedulingSectionState();
}

class _SchedulingSectionState extends State<SchedulingSection> {
  final user = FirebaseAuth.instance.currentUser;
  FireStoreService fireStoreService = FireStoreService();

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (_controller.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      _controller.view = CalendarView.day;
    } else if ((_controller.view == CalendarView.week ||
            _controller.view == CalendarView.workWeek) &&
        calendarTapDetails.targetElement == CalendarElement.viewHeader) {
      _controller.view = CalendarView.day;
    }
  }

  final CalendarController _controller = CalendarController();
  Color? _headerColor, _viewHeaderColor, _calendarColor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: fireStoreService.getDailyItemStream(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                final List<Meeting> meetings = [];
            final documents = snapshot.data!.docs;

                for (var element in documents) {
              final Map<String, dynamic> data = element.data() as Map<String, dynamic>;
              final DateTime startTime = data['startDateTime'].toDate();
              final DateTime endTime = startTime.add(Duration(hours: data["duration"]));
              meetings.add(Meeting(
                  data["itemName"], startTime, endTime, data["isEvent"] ? Colors.red : Colors.green, false));
            }
                return SfCalendar(
                  view: CalendarView.month,
                  allowedViews: [
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.month,
                  ],
                  viewHeaderStyle:
                      ViewHeaderStyle(backgroundColor: _viewHeaderColor),
                  backgroundColor: _calendarColor,
                  controller: _controller,
                  initialDisplayDate: DateTime.now(),
                  dataSource: MeetingDataSource(meetings),
                  onTap: calendarTapped,
                  monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.indicator,
                      showAgenda: true,
                      agendaViewHeight: 200,
                      agendaItemHeight: 50,
                      navigationDirection: MonthNavigationDirection.horizontal),
                      showTodayButton: true,
                      minDate: DateTime.now(),
                      firstDayOfWeek:1,
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }

  Future<List<Meeting>> _getDataSource() async {
    final List<Meeting> meetings = <Meeting>[];

    await fireStoreService.getDailyItemStream(user!.uid).listen((event) {
      event.docs.forEach((element) {
        final Map<String, dynamic> data =
            element.data() as Map<String, dynamic>;
        final DateTime startTime = data['startDateTime'].toDate();
        final DateTime endTime = startTime.add(Duration(hours: data["duration"]));
        meetings.add(Meeting(data["itemName"], startTime, endTime,
            data["isEvent"] ? Colors.red : Colors.green,
            false));
      });
    });

    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
