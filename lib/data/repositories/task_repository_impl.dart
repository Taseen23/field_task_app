import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/hive_service.dart';
import '../model/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Task>> fetchTasksFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      // .where('id', isEqualTo: agentId)
      // .orderBy('dueDate', descending: false)
      // .get();

      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .map((model) => model.toDomain())
          .toList();

      return tasks;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createTaskInFirebase(Task task) async {
    try {
      final taskModel = TaskModel.fromDomain(task);
      await _firestore.collection('tasks').doc(task.id).set(taskModel.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTaskInFirebase(Task task) async {
    try {
      final taskModel = TaskModel.fromDomain(task);
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(taskModel.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTaskInFirebase(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveTaskLocally(Task task) async {
    try {
      final taskModel = TaskModel.fromDomain(task);
      await HiveService.saveTask(taskModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveTasksLocally(List<Task> tasks) async {
    try {
      final taskModels = tasks
          .map((task) => TaskModel.fromDomain(task))
          .toList();
      print(taskModels);
      await HiveService.saveTasks(taskModels);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Task? getTaskLocally(String taskId) {
    try {
      final taskModel = HiveService.getTask(taskId);
      return taskModel?.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<Task> getAllTasksLocally() {
    try {
      final taskModels = HiveService.getAllTasks();
      return taskModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTaskLocally(String taskId) async {
    try {
      await HiveService.deleteTask(taskId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAllTasksLocally() async {
    try {
      await HiveService.clearAllTasks();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncTasksWithFirebase(String agentId) async {
    try {
      // Fetch tasks from Firebase
      final remoteTasks = await fetchTasksFromFirebase();

      // Save to local storage
      await saveTasksLocally(remoteTasks);

      // Process sync queue
      final syncQueue = HiveService.getSyncQueue();
      for (int i = syncQueue.length - 1; i >= 0; i--) {
        final item = syncQueue[i];
        try {
          if (item['operation'] == 'create' || item['operation'] == 'update') {
            final localTask = getTaskLocally(item['taskId']);
            if (localTask != null) {
              if (item['operation'] == 'create') {
                await createTaskInFirebase(localTask);
              } else {
                await updateTaskInFirebase(localTask);
              }
            }
          } else if (item['operation'] == 'delete') {
            await deleteTaskInFirebase(item['taskId']);
          }
          await HiveService.removeFromSyncQueue(i);
        } catch (e) {
          // Continue with next item if one fails
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Task>> getUnsyncedTasks() async {
    try {
      final allTasks = getAllTasksLocally();
      return allTasks.where((task) {
        final localModel = HiveService.getTask(task.id);
        return localModel != null && !localModel.isSynced;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
