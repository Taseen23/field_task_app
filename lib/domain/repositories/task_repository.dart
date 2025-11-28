import '../entities/task.dart';

abstract class TaskRepository {
  // Remote operations
  Future<List<Task>> fetchTasksFromFirebase(String agentId);
  Future<void> createTaskInFirebase(Task task);
  Future<void> updateTaskInFirebase(Task task);
  Future<void> deleteTaskInFirebase(String taskId);

  // Local operations
  Future<void> saveTaskLocally(Task task);
  Future<void> saveTasksLocally(List<Task> tasks);
  Task? getTaskLocally(String taskId);
  List<Task> getAllTasksLocally();
  Future<void> deleteTaskLocally(String taskId);
  Future<void> clearAllTasksLocally();

  // Sync operations
  Future<void> syncTasksWithFirebase(String agentId);
  Future<List<Task>> getUnsyncedTasks();
}
