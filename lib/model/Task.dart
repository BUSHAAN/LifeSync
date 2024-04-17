// enum Schedule { mornings, evenings, workinghours, weekends }

// enum Deadline { hardDeadline, softDeadline, noDeadline }

// enum Priority { high, medium, low }

class Task {
  String userId;
  String taskName;
  double? duration; // Assuming hours
  bool allowSplitting;
  double? maxChunkTime; // Assuming hours
  String priority; // Default priority
  String deadlineType; // Default deadline type
  DateTime? deadline;
  DateTime startDate;
  String schedule;
  bool isDone;

  Task({
    required this.userId,
    required this.taskName,
    required this.duration, // Assuming hours
    required this.allowSplitting,
    this.maxChunkTime, // Assuming hours
    required this.priority, // Default priority
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
          priority: "medium",
          deadlineType: "noDeadline",
          startDate: DateTime(2024),
          schedule: "mornings",
          isDone: true),
      // Task(id: '02', taskName: 'Buy Groceries', isDone: true),
    ];
  }
}
