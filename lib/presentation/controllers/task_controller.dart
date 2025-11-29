import 'package:field_task_app/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_routes.dart';
import '../../data/local/hive_service.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import 'location_controller.dart';

class TaskController extends GetxController {
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  final RxBool isLoading = RxBool(false);
  final RxBool isSyncing = RxBool(false);
  final RxList<Task> tasks = RxList<Task>([]);
  final RxString errorMessage = RxString('');
  final logger = Logger();
  bool isEditing = false;

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
  var completedTasks = <dynamic>[].obs;
  var pendingTasks = <dynamic>[].obs;
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

  late LocationController _locationController;

  // Dispose controllers
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();

    super.onClose();
  }

  @override
  void onInit() {
    _locationController = Get.find<LocationController>();
    _loadLocalTasks();
    _syncTasks();
    super.onInit();
  }

  void _loadLocalTasks() {
    try {
      final localTasks = _taskRepository.getAllTasksLocally();
      tasks.assignAll(localTasks);
      logger.i('Loaded ${localTasks.length} tasks from local storage');
    } catch (e) {
      errorMessage.value = 'Failed to load tasks: $e';
      logger.e('Load local tasks error: $e');
    }
  }

  var address = ''.obs;

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      address.value =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
    } catch (e) {
      address.value = "Unknown Location";
    }
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
      isLoading.value = true;
      final taskId = const Uuid().v4();

      final newTask = Task(
        id: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        status: 'pending',
        latitude: latitude,
        longitude: longitude,
        agentId: 'agentId',
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

      // Get.back();
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

  Future<void> _syncTasks() async {
    try {
      isSyncing.value = true;

      _loadLocalTasks();
      logger.i('Tasks synced successfully');
    } catch (e) {
      logger.e('Sync tasks error: $e');
      // Don't show error to user if offline
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> checkInTask(String taskId) async {
    print('1');
    try {
      final task = tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) {
        errorMessage.value = 'Task not found';
        return;
      }
      print('2');

      // Check proximity
      isLoading.value = true;
      final isNearby = await _locationController.isWithinProximity(
        task.latitude,
        task.longitude,
      );

      if (!isNearby) {
        errorMessage.value =
            'You are not within the required proximity (100m) of the task location';
        isLoading.value = false;
        return;
      }
      print('3');

      // Update task status
      final updatedTask = task.copyWith(
        status: 'checked_in',
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);

      Get.offAllNamed(AppRoutes.home);

      logger.i('Checked in to task: $taskId');
    } catch (e) {
      errorMessage.value = 'Failed to check in: $e';
      logger.e('Check in error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      final task = tasks.firstWhereOrNull((t) => t.id == taskId);
      if (task == null) {
        errorMessage.value = 'Task not found';
        return;
      }

      // Check if task is checked in
      if (task.status != 'checked_in') {
        errorMessage.value = 'You must check in before completing the task';
        return;
      }

      // Check proximity again
      isLoading.value = true;
      final isNearby = await _locationController.isWithinProximity(
        task.latitude,
        task.longitude,
      );

      if (!isNearby) {
        errorMessage.value =
            'You must be within the task location to complete it';
        isLoading.value = false;
        return;
      }

      // Update task status
      final updatedTask = task.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);

      Get.offAllNamed(AppRoutes.home);

      logger.i('Completed task: $taskId');
    } catch (e) {
      errorMessage.value = 'Failed to complete task: $e';
      logger.e('Complete task error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      isLoading.value = true;
      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      // Save locally first
      await _taskRepository.saveTaskLocally(updatedTask);
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }

      // Try to sync with Firebase
      try {
        await _taskRepository.updateTaskInFirebase(updatedTask);
        logger.i('Task updated and synced: ${task.id}');
      } catch (e) {
        // Add to sync queue if offline
        await HiveService.addToSyncQueue(task.id, 'update');
        logger.w('Task updated locally, will sync when online: $e');
      }

      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to update task: $e';
      logger.e('Update task error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;

      // Delete locally first
      await _taskRepository.deleteTaskLocally(taskId);
      tasks.removeWhere((t) => t.id == taskId);

      // Try to sync with Firebase
      try {
        await _taskRepository.deleteTaskInFirebase(taskId);
        logger.i('Task deleted and synced: $taskId');
      } catch (e) {
        // Add to sync queue if offline
        await HiveService.addToSyncQueue(taskId, 'delete');
        logger.w('Task deleted locally, will sync when online: $e');
      }

      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete task: $e';
      logger.e('Delete task error: $e');
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
      _loadLocalTasks();
    } finally {
      isLoading.value = false;
    }
  }
}

extension on Task {
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    double? latitude,
    double? longitude,
    String? agentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      agentId: agentId ?? this.agentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
