class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isDone;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isDone = false,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isDone,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        isDone: isDone ?? this.isDone,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate?.millisecondsSinceEpoch,
        'is_done': isDone ? 1 : 0,
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        dueDate: m['due_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['due_date'] as int),
        isDone: (m['is_done'] as int) == 1,
      );
}
