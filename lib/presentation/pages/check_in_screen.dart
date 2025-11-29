import 'package:field_task_app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../controllers/location_controller.dart';

class CheckInScreen extends StatelessWidget {
  final LocationController locationController = Get.find<LocationController>();
  bool isSelectingLocation = false;
  final arguments = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingLocation ? 'Select Location' : 'Check In'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              // color: AppTheme.backgroundColor,
              child: Obx(() {
                if (locationController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      locationController.address.value,

                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Accuracy: ${locationController.currentPosition.value!.accuracy.toStringAsFixed(1)}m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }),
            ),
          ),

          // Bottom Buttons & Error Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() {
                  if (locationController.errorMessage.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Text(
                      locationController.errorMessage.value,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print(locationController.currentPosition.value);
                      print(isSelectingLocation);
                      

                      if (locationController.currentPosition.value != null) {
                        print('get location');
                        // Get.back();

                        if (arguments != null &&
                            arguments['onLocationSelected'] != null) {
                          arguments['onLocationSelected'](
                            locationController.currentPosition.value!.latitude,
                            locationController.currentPosition.value!.longitude,
                          );
                        }

                        // Get.toNamed(AppRoutes.createTask);
                        Get.back();
                      } else {
                        print('no location');
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: Text(
                      isSelectingLocation
                          ? 'Confirm Location'
                          : 'Check In Here',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      locationController.getCurrentLocation();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
