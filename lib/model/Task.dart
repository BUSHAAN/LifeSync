// enum Schedule { mornings, evenings, workinghours, weekends }

// enum Deadline { hardDeadline, softDeadline, noDeadline }

class Task {
  String userId;
  String taskName;
  double? duration; // Assuming hours
  bool allowSplitting;
  double? maxChunkTime; // Assuming hours
  String deadlineType; // Default deadline type
  DateTime? deadline;
  DateTime? startDate;
  String schedule;
  bool isDone;

  Task({
    required this.userId,
    required this.taskName,
    required this.duration, // Assuming hours
    required this.allowSplitting,
    this.maxChunkTime, // Assuming hours
    required this.deadlineType, // Default deadline type
    this.deadline,
    required this.startDate,
    required this.schedule,
    required this.isDone,
  });

  static List<Task> todoList() {
    return [
      Task(
          userId: '01',
          taskName: 'Morning Excercise',
          duration: 1,
          allowSplitting: false,
          deadlineType: "noDeadline",
          startDate: DateTime(2024),
          schedule: "mornings",
          isDone: true),
      // Task(id: '02', taskName: 'Buy Groceries', isDone: true),
    ];
  }
}
