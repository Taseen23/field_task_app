import 'package:get/get.dart';
import '../presentation/check_in_screen.dart';
import '../presentation/create_task_screen.dart';
import '../presentation/home_screen.dart';
import '../presentation/task_detail_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String taskDetail = '/task-detail';
  static const String createTask = '/create-task';
  static const String checkIn = '/check-in';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: createTask,
      page: () => CreateTaskScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: checkIn,
      page: () => CheckInScreen(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: taskDetail,
      page: () => TaskDetailScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
