import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../config/theme.dart';
import 'controllers/task_controller.dart';
import 'widgets/task_card.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  // final TaskController taskController = Get.find<TaskController>();


  final taskController = Get.put(TaskController());
  // final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // Fetch tasks initially
    taskController.fetchTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskController.fetchTasks(),
          ),
       
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => taskController.fetchTasks(),
        child: Column(
          children: [
            // Stats Section
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                            'Total', taskController.totalTasks.toString(), Colors.white),
                        _buildStatCard('Completed',
                            taskController.completedCount.toString(), Colors.white),
                        _buildStatCard(
                            'Pending', taskController.pendingCount.toString(), Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: taskController.completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${taskController.completionPercentage.toStringAsFixed(0)}% Complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Tab Bar
            Obx(() {
              return Container(
                color: AppTheme.surfaceColor,
                child: Row(
                  children: List.generate(3, (index) {
                    String label;
                    if (index == 0) label = 'All';
                    else if (index == 1) label = 'Pending';
                    else label = 'Completed';
                    return _buildTab(label, index);
                  }),
                ),
              );
            }),

            // Tasks List
            Expanded(
              child: Obx(() {
                List<dynamic> displayTasks;
                if (taskController.selectedTabIndex.value == 0) {
                  displayTasks = taskController.tasks;
                } else if (taskController.selectedTabIndex.value == 1) {
                  displayTasks = taskController.pendingTasks;
                } else {
                  displayTasks = taskController.completedTasks;
                }

                if (taskController.isLoading.value && displayTasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (displayTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: AppTheme.textSecondaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayTasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: displayTasks[index],
                      onTap: () {
                        taskController.selectTask(displayTasks[index]);
                        Get.toNamed(
                          AppRoutes.taskDetail,
                          arguments: displayTasks[index],
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.createTask),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color textColor) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );

  Widget _buildTab(String label, int index) {
    final isSelected = taskController.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => taskController.setSelectedTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
