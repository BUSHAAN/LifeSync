// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

class SchedulingSection extends StatefulWidget {
  const SchedulingSection({super.key});

  @override
  State<SchedulingSection> createState() => _SchedulingSectionState();
}

class _SchedulingSectionState extends State<SchedulingSection> {
  List<TimePlannerTask> tasks = [
    TimePlannerTask(
        // background color for task
        color: Colors.green,
        // day: Index of header, hour: Task will be begin at this hour
        // minutes: Task will be begin at this minutes
        dateTime: TimePlannerDateTime(day: 0, hour: 7, minutes: 30),
        // Minutes duration of task
        minutesDuration: 120,
        // Days duration of task (use for multi days task)
        daysDuration: 1,
        onTap: () {},
        child: 'Sports Practise'),
    TimePlannerTask(
        // background color for task
        color: Colors.blue.shade600,
        // day: Index of header, hour: Task will be begin at this hour
        // minutes: Task will be begin at this minutes
        dateTime: TimePlannerDateTime(day: 1, hour: 8, minutes: 00),
        // Minutes duration of task
        minutesDuration: 180,
        // Days duration of task (use for multi days task)
        daysDuration: 1,
        onTap: () {},
        child: 'CS lecture'),
    TimePlannerTask(
      // background color for task
      color: Colors.green,
      // day: Index of header, hour: Task will be begin at this hour
      // minutes: Task will be begin at this minutes
      dateTime: TimePlannerDateTime(day: 1, hour: 12, minutes: 30),
      // Minutes duration of task
      minutesDuration: 100,
      // Days duration of task (use for multi days task)
      daysDuration: 1,
      onTap: () {},
      child: 'Go to the market',
    ),
    TimePlannerTask(
      // background color for task
      color: Colors.green,
      // day: Index of header, hour: Task will be begin at this hour
      // minutes: Task will be begin at this minutes
      dateTime: TimePlannerDateTime(day: 2, hour: 10, minutes: 30),
      // Minutes duration of task
      minutesDuration: 100,
      // Days duration of task (use for multi days task)
      daysDuration: 1,
      onTap: () {},
      child: 'Fix the wifi',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimePlanner(
        // time will be start at this hour on table
        startHour: 6,
        // time will be end at this hour on table
        endHour: 23,
        use24HourFormat: true,
        // each header is a column and a day
        headers: [
          TimePlannerTitle(
            date: "21/4/2024",
            title: "Sunday",
          ),
          TimePlannerTitle(
            date: "22/4/2024",
            title: "Monday",
          ),
          TimePlannerTitle(
            date: "23/4/2024",
            title: "Tuesday",
          ),
          TimePlannerTitle(
            date: "24/4/2024",
            title: "Wednesday",
          ),
          TimePlannerTitle(
            date: "25/4/2024",
            title: "Thursday",
          ),
          TimePlannerTitle(
            date: "26/4/2024",
            title: "Friday",
          ),
          TimePlannerTitle(
            date: "27/4/2024",
            title: "Saturday",
          ),
        ],
        // List of task will be show on the time planner
        tasks: tasks,
        style: TimePlannerStyle(
            //backgroundColor: Colors.white70,
            // default value for height is 80
            //cellHeight: 60,
            // default value for width is 90
            //cellWidth: 60,
            //dividerColor: Colors.white,
            //showScrollBar: true,
            //horizontalTaskPadding: 5,
            //borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
      ),
    );
  }
}
  