import 'package:flutter/material.dart';
import '../config/theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool isSelectingLocation = false;

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
              color: AppTheme.backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.1),
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
                    '00.0000, 00.0000',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

           
                  Text(
                    'Accuracy: 0.0m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

        
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
              
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  child: const Text(
                    'Error message placeholder',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

          
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
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
                    onPressed: () {},
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
