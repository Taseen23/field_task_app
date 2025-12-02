import 'package:field_task_app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../controllers/task_controller.dart';
import '../widgets/custom_text_field.dart';

class CreateTaskScreen extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());

  CreateTaskScreen({Key? key}) : super(key: key) {
    // final args = Get.arguments;
    // if (args != null) {
    //   controller.isEditing = true;
    //   final task = args;
    //   controller.titleController.text = task.title;
    //   controller.descriptionController.text = task.description;
    //   controller.selectedDate.value = task.dueDate;
    //   controller.selectedTime.value = TimeOfDay.fromDateTime(task.dueDate);
    //   controller.selectedLatitude.value = task.latitude;
    //   controller.selectedLongitude.value = task.longitude;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Task'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: controller.titleController,
              label: 'Task Title',
              hint: 'Enter task title',
              prefixIcon: Icons.title,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: controller.descriptionController,
              label: 'Description',
              hint: 'Enter task description',
              prefixIcon: Icons.description,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            Text('Due Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            Obx(
              () => GestureDetector(
                onTap: () => controller.selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.backgroundColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.selectedDate.value != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(controller.selectedDate.value!)
                              : 'Select date',
                          style: TextStyle(
                            color: controller.selectedDate.value != null
                                ? AppTheme.textPrimaryColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text('Due Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            Obx(
              () => GestureDetector(
                onTap: () => controller.selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.backgroundColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.selectedTime.value != null
                              ? controller.selectedTime.value!.format(context)
                              : 'Select time',
                          style: TextStyle(
                            color: controller.selectedTime.value != null
                                ? AppTheme.textPrimaryColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Task Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Obx(
              () => GestureDetector(
                onTap: controller.selectLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.backgroundColor,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        '/check-in',
                        arguments: {
                          'isSelectingLocation': true,
                          'onLocationSelected': (double lat, double lng) {
                            controller.selectedLatitude.value = lat;
                            controller.selectedLongitude.value = lng;
                          },
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.selectedLatitude.value != null
                                ? '${controller.selectedLatitude.value!.toStringAsFixed(4)}, ${controller.selectedLongitude.value!.toStringAsFixed(4)}'
                                : 'Select location',
                            style: TextStyle(
                              color: controller.selectedLatitude.value != null
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  // controller.descriptionController.text = '';
                  // controller.titleController.text = '';
                  // controller.selectedDate.value = null;
                  // controller.selectedTime.value = null;
                  // controller.selectedLatitude.value = null;
                  // controller.selectedLongitude.value = null;

                  controller.isLoading.value
                      ? null
                      :
                    
                        controller.createTask(
                          description: controller.descriptionController.text,
                          dueDate: controller.selectedDate.value!,
                          latitude: controller.selectedLatitude.value!,
                          title: controller.titleController.text,
                          longitude: controller.selectedLongitude.value!,
                        );
                },

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.primaryColor,
                  ),

                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Create Task'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
