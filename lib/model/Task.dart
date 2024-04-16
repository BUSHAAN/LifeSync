enum Schedule { mornings, evenings, workinghours, weekends }

enum Deadline { hardDeadline, softDeadline, noDeadline }

enum Priority { high, medium, low }

class Task {
  String id;
  String taskName;
  double duration; // Assuming hours
  bool allowSplitting;
  double? maxChunkTime; // Assuming hours
  Priority priority; // Default priority
  Deadline deadlineType; // Default deadline type
  DateTime? deadline;
  DateTime startDate;
  Schedule schedule;
  bool isDone;

  Task({
    required this.id,
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
          id: '01',
          taskName: 'Morning Excercise',
          duration: 1,
          allowSplitting: false,
          priority: Priority.medium,
          deadlineType: Deadline.noDeadline,
          startDate: DateTime(2024),
          schedule: Schedule.mornings,
          isDone: true),
      // Task(id: '02', taskName: 'Buy Groceries', isDone: true),
    ];
  }
}
