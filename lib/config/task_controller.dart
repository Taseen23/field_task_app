import 'package:field_task_app/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/hive_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';

class TaskController extends GetxController {
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  final RxBool isLoading = RxBool(false);
  final RxList<Task> tasks = RxList<Task>([]);
  final RxString errorMessage = RxString('');
  final logger = Logger();

  // Currently selected task for details
  var selectedTask = Rxn<Task>();

  // Select a task for details
  void selectTask(Task task) {
    selectedTask.value = task;
  }

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observables
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();
  var selectedLatitude = RxnDouble();
  var selectedLongitude = RxnDouble();

  //  var tasks = <dynamic>[].obs;

  var completedTasks = <dynamic>[].obs;
  var pendingTasks = <dynamic>[].obs;

  // var isLoading = false.obs;
  var selectedTabIndex = 0.obs;

  // Stats
  int get totalTasks => tasks.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;
  double get completionPercentage =>
      totalTasks == 0 ? 0 : (completedCount / totalTasks) * 100;

  void setSelectedTab(int index) {
    selectedTabIndex.value = index;
  }

  // Dispose controllers
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
  }

  /// Select Date
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  /// Select Time
  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  /// Select Location (example)
  void selectLocation() {
    selectedLatitude.value = 0.0000;
    selectedLongitude.value = 0.0000;
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // if (!_authController.isAuthenticated) {
      //   errorMessage.value = 'User not authenticated';
      //   return;
      // }

      isLoading.value = true;
      final taskId = const Uuid().v4();

      final newTask = Task(
        id: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        status: 'pending',
        latitude: 0,
        longitude: 0,
        agentId: 'agentId', // Replace with actual agent ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first
      await _taskRepository.saveTaskLocally(newTask);
      tasks.add(newTask);

      // Try to sync with Firebase
      try {
        await _taskRepository.createTaskInFirebase(newTask);
        logger.i('Task created and synced: $taskId');
      } catch (e) {
        // Add to sync queue if offline
        await HiveService.addToSyncQueue(taskId, 'create');
        logger.w('Task created locally, will sync when online: $e');
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to create task: $e';
      logger.e('Create task error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTasks() async {
    try {
      // if (!_authController.isAuthenticated) return;

      isLoading.value = true;
      final remoteTasks = await _taskRepository
          .fetchTasksFromFirebase(); // Replace with actual agent ID
      await _taskRepository.saveTasksLocally(remoteTasks);
      tasks.assignAll(remoteTasks);

      completedTasks.assignAll(
        remoteTasks.where((task) => task.isCompleted).toList(),
      );
      pendingTasks.assignAll(
        remoteTasks.where((task) => task.isPending).toList(),
      );
      logger.i('Fetched ${remoteTasks.length} tasks from Firebase');
    } catch (e) {
      errorMessage.value = 'Failed to fetch tasks: $e';
      logger.e('Fetch tasks error: $e');
      // Load from local storage as fallback
      // _loadLocalTasks();
    } finally {
      isLoading.value = false;
    }
  }
}
