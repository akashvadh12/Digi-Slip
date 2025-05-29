// app/modules/home/controllers/home_controller.dart
import 'package:digislips/app/modules/leave/leave_form/leave_form_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaveApplication {
  final String type;
  final String date;
  final String status;
  final Color statusColor;

  LeaveApplication({
    required this.type,
    required this.date,
    required this.status,
    required this.statusColor,
  });
}

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  final employee = {
    'name': 'Alex Johnson',
    'department': 'Computer Science',
    'id': '#CS2023045',
    'avatar': 'assets/images/profile.jpg',
  };

  final recentLeaveApplications = <LeaveApplication>[
    LeaveApplication(
      type: 'Sick Leave',
      date: 'Oct 15, 2023',
      status: 'Approved',
      statusColor: const Color(0xFF4CAF50),
    ),
    LeaveApplication(
      type: 'Casual Leave',
      date: 'Oct 10, 2023',
      status: 'Pending',
      statusColor: Colors.orange,
    ),
    LeaveApplication(
      type: 'Medical Leave',
      date: 'Sep 28, 2023',
      status: 'Rejected',
      statusColor: const Color(0xFFD32F2F),
    ),
  ];

  void changeBottomNavIndex(int index) {
    selectedIndex.value = index;
  }

  void onApplyForLeave() {
    Get.to(ApplyLeaveView()); // Assuming ApplyLeaveView is defined in your app
    Get.snackbar(
      'Apply for Leave',
      'Navigate to leave application form',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onViewLeaveStatus() {
    Get.snackbar(
      'Leave Status',
      'Navigate to leave status page',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onMyProfile() {
    Get.snackbar(
      'My Profile',
      'Navigate to profile page',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onLogout() {
    Get.snackbar(
      'Logout',
      'Logging out...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
