import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final _fmt = DateFormat('EEE, d MMM y • h:mm a');
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await _db.getAll();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _openForm([Task? task]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (changed == true) _load();
  }

  Future<void> _toggle(Task task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _db.update(updated);
    await NotificationService.instance.schedule(updated);
    _load();
  }

  Future<void> _delete(Task task) async {
    await _db.delete(task.id!);
    await NotificationService.instance.cancel(task.id!);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('Deleted "${task.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final id = await _db.insert(task);
            await NotificationService.instance.schedule(
              Task(
                id: id,
                title: task.title,
                description: task.description,
                dueDate: task.dueDate,
                isDone: task.isDone,
              ),
            );
            _load();
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: _tasks.length,
                  itemBuilder: (context, i) {
                    final t = _tasks[i];
                    final overdue = !t.isDone &&
                        t.dueDate != null &&
                        t.dueDate!.isBefore(DateTime.now());
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: scheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: scheme.onErrorContainer),
                      ),
                      onDismissed: (_) => _delete(t),
                      child: ListTile(
                        leading: Checkbox(
                          value: t.isDone,
                          onChanged: (_) => _toggle(t),
                        ),
                        title: Text(
                          t.title,
                          style: t.isDone
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        subtitle: Text([
                          if (t.description.isNotEmpty) t.description,
                          if (t.dueDate != null) _fmt.format(t.dueDate!),
                        ].join('\n')),
                        isThreeLine:
                            t.description.isNotEmpty && t.dueDate != null,
                        trailing: overdue
                            ? Icon(Icons.warning_amber, color: scheme.error)
                            : null,
                        onTap: () => _openForm(t),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
