import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'presentation/controllers/location_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   Get.put(LocationController(), permanent: true);

  runApp(const FieldTaskApp());
}

class FieldTaskApp extends StatelessWidget {
  const FieldTaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Field Task App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      getPages: AppRoutes.pages,
      initialRoute: AppRoutes.home,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
