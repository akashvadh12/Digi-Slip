// controllers/leave_controller.dart
import 'dart:ui';

import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';
import 'package:digislips/app/modules/leave/leave_service/leave_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveController extends GetxController {
  final LeaveService _leaveService = LeaveService();
  final RxList<LeaveModel> leaveRequests = <LeaveModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid != null && uid.isNotEmpty) {
        currentUserId.value = uid;
        _listenToLeaveRequests();
      } else {}
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize user: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _listenToLeaveRequests() {
    if (currentUserId.value.isEmpty) return;

    _leaveService
        .getUserLeaveApplications(currentUserId.value)
        .listen(
          (leaves) {
            leaveRequests.value = leaves;
          },
          onError: (error) {
            Get.snackbar(
              'Error',
              'Failed to fetch leave requests: $error',
              snackPosition: SnackPosition.TOP,
              backgroundColor: const Color(0xFFD32F2F),
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          },
        );
  }

  List<LeaveModel> get filteredRequests {
    if (selectedFilter.value == 'All') {
      return leaveRequests;
    }
    return leaveRequests
        .where(
          (request) =>
              request.status.toLowerCase() ==
              selectedFilter.value.toLowerCase(),
        )
        .toList();
  }

  Future<void> updateLeaveStatus(
    String leaveId,
    String status, {
    String? reviewComments,
  }) async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );

      return;
    }

    try {
      isLoading.value = true;
      await _leaveService.updateLeaveStatus(
        userId: currentUserId.value,
        leaveId: leaveId,
        status: status,
        reviewedBy:
            'current_user', // You might want to get this from user session
        reviewComments: reviewComments,
      );
      Get.snackbar(
        'Success',
        'Leave request updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update leave request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLeaveRequest(String leaveId) async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );

      return;
    }

    try {
      isLoading.value = true;
      await _leaveService.deleteLeaveApplication(currentUserId.value, leaveId);
      Get.snackbar(
        'Success',
        'Leave request deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete leave request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, int>> getLeaveStatistics() async {
    if (currentUserId.value.isEmpty) {
      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'totalDays': 0,
        'approvedDays': 0,
      };
    }

    try {
      return await _leaveService.getLeaveStatistics(currentUserId.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get leave statistics: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );

      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'totalDays': 0,
        'approvedDays': 0,
      };
    }
  }

  Future<bool> checkOverlappingLeave({
    required DateTime fromDate,
    required DateTime toDate,
    String? excludeLeaveId,
  }) async {
    if (currentUserId.value.isEmpty) {
      return false;
    }

    try {
      return await _leaveService.hasOverlappingLeave(
        userId: currentUserId.value,
        fromDate: fromDate,
        toDate: toDate,
        excludeLeaveId: excludeLeaveId,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check overlapping leave: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> refreshLeaveRequests() async {
    if (currentUserId.value.isNotEmpty) {
      // The stream will automatically update the list
      // This method can be used for manual refresh if needed
    } else {}
  }
}
