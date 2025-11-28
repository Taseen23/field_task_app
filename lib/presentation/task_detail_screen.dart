import 'package:field_task_app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../domain/entities/task.dart';

import 'controllers/task_controller.dart';

class TaskDetailScreen extends StatelessWidget {
  TaskDetailScreen({Key? key}) : super(key: key);

  final taskController = Get.put(TaskController());
  // final LocationController locationController = Get.find<LocationController>();

  @override
  Widget build(BuildContext context) {
    // Select the task passed via arguments
    final Task task = Get.arguments as Task;
    // taskController.selectTask(task);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () {
                  Get.toNamed(AppRoutes.createTask, arguments: task);
                  // Implement edit functionality
                },
              ),
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () {
                  _showDeleteConfirmation(task);
                },
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final selectedTask = taskController.selectedTask.value;
        if (selectedTask == null)
          return const Center(child: Text('Task not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              _statusBadge(selectedTask.status),
              const SizedBox(height: 16),
              // Title
              Text(
                selectedTask.title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                selectedTask.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Due Date
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Due Date',
                value: DateFormat(
                  'MMM dd, yyyy • hh:mm a',
                ).format(selectedTask.dueDate),
              ),
              const SizedBox(height: 16),
              // Location Info
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value:
                    '${selectedTask.latitude.toStringAsFixed(4)}, ${selectedTask.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 16),
              // Distance
              _buildInfoRow(
                icon: Icons.directions,
                label: 'Distance',
                value: 'test distance',
                // TODO
                //  locationController.formatDistance(locationController
                //     .getDistanceToLocation(selectedTask.latitude, selectedTask.longitude)),
              ),
              const SizedBox(height: 32),
              // Action Buttons
              if (taskController.isLoading.value)
                const Center(child: CircularProgressIndicator())
              else
                _actionButtons(selectedTask),
              const SizedBox(height: 24),
              // Error Message
              if (taskController.errorMessage.isNotEmpty)
                _errorMessage(taskController.errorMessage.value),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionButtons(Task task) {
    if (task.status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showCheckInConfirmation(task),
          icon: const Icon(Icons.location_on),
          label: const Text('Check In'),
        ),
      );
    } else if (task.status == 'checked_in') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCompleteConfirmation(task),
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete Task'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Task'),
            ),
          ),
        ],
      );
    } else if (task.status == 'completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.secondaryColor),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.secondaryColor),
            SizedBox(width: 12),
            Text(
              'Task completed successfully',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(Get.context!).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(Get.context!).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.accentColor;
      case 'checked_in':
        return Colors.blue;
      case 'completed':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'checked_in':
        return 'Checked In';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  void _showCheckInConfirmation(Task task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Check In'),
        content: const Text(
          'Are you sure you want to check in to this task? You must be within 100 meters of the location.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // taskController.checkInTask(task.id);
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(Task task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Task'),
        content: const Text(
          'Are you sure you want to mark this task as completed? You must be within 100 meters of the location.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // taskController.completeTask(task.id);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // taskController.deleteTask(task.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
