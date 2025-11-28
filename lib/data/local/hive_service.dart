import 'package:hive/hive.dart';
import '../model/task_model.dart';

class HiveService {
  static const String tasksBoxName = 'tasks';
  static const String userBoxName = 'user';
  static const String syncBoxName = 'sync_queue';

  static late Box<TaskModel> _tasksBox;
  static late Box<dynamic> _userBox;
  static late Box<dynamic> _syncBox;

  static Future<void> init() async {
    // Register adapters
    // Hive.registerAdapter(TaskModelAdapter());

    // Open boxes
    _tasksBox = await Hive.openBox<TaskModel>(tasksBoxName);
    _userBox = await Hive.openBox(userBoxName);
    _syncBox = await Hive.openBox(syncBoxName);
  }

  // Task operations
  static Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  static Future<void> saveTasks(List<TaskModel> tasks) async {
    for (var task in tasks) {
      await _tasksBox.put(task.id, task);
    }
  }

  static TaskModel? getTask(String id) {
    return _tasksBox.get(id);
  }

  static List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }

  static Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  static Future<void> clearAllTasks() async {
    await _tasksBox.clear();
  }

  // User operations
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _userBox.put('current_user', user);
  }

  static Map<String, dynamic>? getUser() {
    return _userBox.get('current_user');
  }

  static Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  // Sync queue operations
  static Future<void> addToSyncQueue(String taskId, String operation) async {
    final queue = _syncBox.get('sync_queue') ?? [];
    queue.add({
      'taskId': taskId,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _syncBox.put('sync_queue', queue);
  }

  static List<dynamic> getSyncQueue() {
    return _syncBox.get('sync_queue') ?? [];
  }

  static Future<void> clearSyncQueue() async {
    await _syncBox.delete('sync_queue');
  }

  static Future<void> removeFromSyncQueue(int index) async {
    final queue = _syncBox.get('sync_queue') ?? [];
    if (index < queue.length) {
      queue.removeAt(index);
      await _syncBox.put('sync_queue', queue);
    }
  }
}
