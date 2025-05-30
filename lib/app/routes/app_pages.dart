import 'package:digislips/app/modules/auth/StudentRegistration/StudentRegistration.dart';
import 'package:digislips/app/modules/auth/controllers/auth_controller.dart';
import 'package:digislips/app/modules/auth/controllers/registration_controller.dart';
import 'package:digislips/app/modules/auth/login/login_page.dart';
import 'package:digislips/app/modules/dashboard/dashboard.dart';
import 'package:digislips/app/modules/leave/leave_form/leave_controller.dart';
import 'package:digislips/app/modules/leave/leave_form/leave_form_page.dart';
import 'package:digislips/app/routes/app_rout.dart';
import 'package:digislips/app/shared/widgets/bottomnavigation/bottomnavigation.dart';
import 'package:digislips/app/shared/widgets/bottomnavigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get.dart';

// Define your route names in a class for easy reuse
class AppPages {
  static const INITIAL = Routes.STUDENT_REGISTRATION;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      // You can add middlewares here if needed
    ),
    GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
    GetPage(
      name: Routes.APPLY_LEAVE,
      page: () => ApplyLeaveView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ApplyLeaveController>(() => ApplyLeaveController());
      }),
    ),
    GetPage(
      name: Routes.STUDENT_REGISTRATION,
      page: () => StudentRegistrationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegistrationController>(() => RegistrationController());
      }),
    ),
    GetPage(
      name: Routes.BOTTOM_NAVIGATION,
      page: () => BottomNavBarWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BottomNavController>(() => BottomNavController());
      }),
    ),
  ];
}
