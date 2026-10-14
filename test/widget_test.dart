import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';

void main() {
  test('Task survives a map round trip', () {
    final due = DateTime(2030, 1, 2, 3, 4);
    final t = Task.fromMap(Task(id: 1, title: 'a', dueDate: due, isDone: true).toMap());
    expect(t.dueDate, due);
    expect(t.isDone, true);
  });
}
