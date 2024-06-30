import 'package:hive/hive.dart';
import 'package:task_manager/features/task/domain/todo_model.dart';

class TaskRepository {
  static const String _taskBoxName = 'tasks';
  static const String _revisionBoxName = 'revisions';
  static const String _offlineChangesBoxName = 'offline_changes';

  Future<void> init() async {
    await Hive.openBox<TodoModel>(_taskBoxName);
    await Hive.openBox<int>(_revisionBoxName);
    await Hive.openBox<List>(_offlineChangesBoxName);
  }

  Future<void> addTask(TodoModel task) async {
    final box = Hive.box<TodoModel>(_taskBoxName);
    await box.put(task.id, task);
  }

  Future<void> updateTask(TodoModel task) async {
    final box = Hive.box<TodoModel>(_taskBoxName);
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    final box = Hive.box<TodoModel>(_taskBoxName);
    await box.delete(id);
  }

  Future<List<TodoModel>> getTasks() async {
    final box = Hive.box<TodoModel>(_taskBoxName);
    return box.values.toList();
  }

  Future<int> getRevision() async {
    final box = Hive.box<int>(_revisionBoxName);
    return box.get('revision', defaultValue: 0) ?? 0;
  }

  Future<void> updateRevision(int newRevision) async {
    final box = Hive.box<int>(_revisionBoxName);
    await box.put('revision', newRevision);
  }

  Future<void> replaceLocalData(List<TodoModel> tasks) async {
    final box = Hive.box<TodoModel>(_taskBoxName);
    await box.clear();
    for (var task in tasks) {
      await box.put(task.id, task);
    }
  }

  Future<void> addOfflineChange(String type, dynamic data) async {
    final box = Hive.box<List>(_offlineChangesBoxName);
    final changes = box.get('changes', defaultValue: []);
    changes?.add({'type': type, 'data': data});
    await box.put('changes', changes ?? []);
  }

  List<Map<String, dynamic>> getOfflineChanges() {
    final box = Hive.box<List>(_offlineChangesBoxName);
    return (box.get('changes', defaultValue: []) ?? [])
        .cast<Map<String, dynamic>>();
  }

  Future<void> clearOfflineChanges() async {
    final box = Hive.box<List>(_offlineChangesBoxName);
    await box.put('changes', []);
  }
}
