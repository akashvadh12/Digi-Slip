
// import 'package:digislips/app/core/theme/app_colors.dart';
// import 'package:digislips/app/modules/dashboard/dashboard.dart';
// import 'package:digislips/app/modules/profile/Profile_screen.dart';
// import 'package:digislips/app/shared/widgets/bottomnavigation/navigation_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

// class BottomNavBarWidget extends StatelessWidget {
//   BottomNavBarWidget({super.key});

//   final BottomNavController controller = Get.put(BottomNavController());

//   final List<Widget> screens = [
//     HomeView(),
//     ProfileScreen(),
//   ];

//   final List<BottomNavigationBarItem> items = const [
//     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//     BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Attendance'),
//     BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Patrol'),
//     BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Report'),
//     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Scaffold(
//           body: screens[controller.currentIndex.value],
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: controller.currentIndex.value,
//             onTap: controller.changeTab,
//             selectedItemColor: AppColors.primary,
//             unselectedItemColor: Colors.grey,
//             items: items,
//             type: BottomNavigationBarType.fixed,
//           ),
//         ));
//   }
// }
