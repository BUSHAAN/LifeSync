// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, await_only_futures, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/Task.dart';
import 'package:flutter_todo_app/model/daily_item_data_source.dart';
import 'package:flutter_todo_app/model/event.dart';
import 'package:flutter_todo_app/model/meeting.dart';
import 'package:flutter_todo_app/pages/event_details.dart';
import 'package:flutter_todo_app/pages/task_details.dart';
import 'package:flutter_todo_app/services/firestore.dart';
import 'package:flutter_todo_app/services/rescheduleTasksAtStartup.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SchedulingSection extends StatefulWidget {
  const SchedulingSection({super.key});

  @override
  State<SchedulingSection> createState() => _SchedulingSectionState();

  Future<void> showCompletionOrRescheduleDialog(BuildContext context,
      Map<String, dynamic> dailyItem, String docId,String userId) async {
        Rescheduletasksatstartup rescheduletasksatstartup = Rescheduletasksatstartup();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Task Expired"),
          content: Text(
            "Task '${dailyItem['itemName']}' has expired. Would you like to mark it as completed or reschedule?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                dailyItem['isCompleted'] = true;
                await FireStoreService().updateDailyItem(docId, dailyItem);
                Navigator.pop(context);
              },
              child: Text("Mark as Completed"),
            ),
            TextButton(
              onPressed: () async {
                await rescheduletasksatstartup.rescheduleDailyItem(docId);
                Navigator.pop(context);
              },
              child: Text("Reschedule"),
            ),
          ],
        );
      },
    );
  }
}

class _SchedulingSectionState extends State<SchedulingSection> {
  final user = FirebaseAuth.instance.currentUser;
  FireStoreService fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    fireStoreService.checkAndHandleExpiredTasks(context,user!.uid);
  }


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
  Color? _viewHeaderColor, _calendarColor;
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
                  final Map<String, dynamic> data =
                      element.data() as Map<String, dynamic>;

                  // Check if 'startDateTime' exists and is not null
                  final Timestamp? startTimestamp =
                      data['startDateTime'] as Timestamp?;
                  final Timestamp? endTimestamp =
                      data['endDateTime'] as Timestamp?;

                  if (startTimestamp != null && endTimestamp != null) {
                    final DateTime startTime = startTimestamp.toDate();
                    final DateTime endTime = endTimestamp.toDate();
                    meetings.add(Meeting(
                      data["itemName"],
                      startTime,
                      endTime,
                      data["isEvent"] ? Colors.red : Colors.green,
                      false,
                      data["refId"],
                    ));
                  }
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
                    navigationDirection: MonthNavigationDirection.horizontal,
                  ),
                  showTodayButton: true,
                  minDate: DateTime.parse('2021-07-20 20:18:04Z'),//DateTime.now(),
                  firstDayOfWeek: 1,
                  appointmentBuilder: (context, details) {
                    final Meeting meeting = details.appointments.first;
                    return GestureDetector(
                      onTap: () async {
                        if (meeting.background == Colors.red) {
                          final data =
                              await fireStoreService.getEventData(meeting.id);
                          Event event = Event(
                            userId: data['userId'],
                            eventName: data['eventName'],
                            startTime:
                                (data['startTime'] as Timestamp).toDate(),
                            endTime: (data['endTime'] as Timestamp).toDate(),
                            frequency: data['frequency'],
                            selectedWeekdays: data['selectedWeekdays'] != null
                                ? (data['selectedWeekdays'] as List<dynamic>)
                                    .map((e) => e as int)
                                    .toList()
                                : null,
                            startDate: data['frequency'] == "One-Time"
                                ? (data['startDate'] as Timestamp).toDate()
                                : null,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetails(
                                event: event,
                                documentId: meeting.id,
                              ),
                            ),
                          );
                        } else {
                          final data =
                              await fireStoreService.getTaskData(meeting.id);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetails(
                                taskData: data,
                                documentId: meeting.id,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: details.bounds.width,
                        height: details.bounds.height,
                        color: meeting.background,
                        child: Center(
                          child: Text(
                            meeting.eventName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }
}
