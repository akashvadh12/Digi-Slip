
import 'package:digislips/app/modules/auth/controllers/auth_controller.dart';
import 'package:digislips/app/modules/auth/login/login_page.dart';
import 'package:digislips/app/modules/dashboard/dashboard.dart';
import 'package:digislips/app/routes/app_rout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get.dart';


// Define your route names in a class for easy reuse
class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      // You can add middlewares here if needed
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
  ];
}

// Routes names as constants
class Routes {
  static const HOME = '/home';
  static const LOGIN = '/login';
}
