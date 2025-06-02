// controllers/leave_controller.dart
import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';
import 'package:digislips/app/modules/leave/leave_service/leave_service.dart';
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
      } else {
        loadSampleData(); // Fallback to sample data if no user ID
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize user: $e');
      loadSampleData(); // Fallback to sample data
    }
  }

  void _listenToLeaveRequests() {
    if (currentUserId.value.isEmpty) return;

    _leaveService.getUserLeaveApplications(currentUserId.value).listen(
      (leaves) {
        leaveRequests.value = leaves;
      },
      onError: (error) {
        Get.snackbar('Error', 'Failed to fetch leave requests: $error');
        loadSampleData(); // Fallback to sample data on error
      },
    );
  }

  void loadSampleData() {
    // Sample data for UI testing
    leaveRequests.value = [
      LeaveModel(
        id: '1',
        leaveType: 'Sick Leave',
        fromDate: DateTime(2023, 10, 15),
        toDate: DateTime(2023, 10, 16),
        totalDays: 2,
        reason: 'Medical appointment and recovery',
        status: 'Pending',
        submittedAt: DateTime(2023, 10, 14),
        submittedBy: 'current_user',
      ),
      LeaveModel(
        id: '2',
        leaveType: 'Vacation Leave',
        fromDate: DateTime(2023, 12, 24),
        toDate: DateTime(2023, 12, 31),
        totalDays: 8,
        reason: 'Year-end family vacation',
        status: 'Approved',
        submittedAt: DateTime(2023, 11, 15),
        submittedBy: 'current_user',
        reviewedBy: 'admin',
        reviewedAt: DateTime(2023, 11, 16),
      ),
      LeaveModel(
        id: '3',
        leaveType: 'Family Emergency',
        fromDate: DateTime(2023, 10, 25),
        toDate: DateTime(2023, 10, 25),
        totalDays: 1,
        reason: 'Urgent family matter requiring immediate attention',
        status: 'Rejected',
        submittedAt: DateTime(2023, 10, 25),
        submittedBy: 'current_user',
        reviewedBy: 'admin',
        reviewedAt: DateTime(2023, 10, 26),
        reviewComments: 'Please submit additional documentation supporting your request.',
      ),
      LeaveModel(
        id: '4',
        leaveType: 'Personal Leave',
        fromDate: DateTime(2024, 1, 15),
        toDate: DateTime(2024, 1, 17),
        totalDays: 3,
        reason: 'Personal matters and mental health break',
        status: 'Approved',
        submittedAt: DateTime(2023, 12, 20),
        submittedBy: 'current_user',
        reviewedBy: 'admin',
        reviewedAt: DateTime(2023, 12, 21),
      ),
      LeaveModel(
        id: '5',
        leaveType: 'Medical Leave',
        fromDate: DateTime(2024, 2, 1),
        toDate: DateTime(2024, 2, 5),
        totalDays: 5,
        reason: 'Surgery and post-operative recovery',
        status: 'Pending',
        submittedAt: DateTime(2024, 1, 10),
        submittedBy: 'current_user',
      ),
    ];
  }

  List<LeaveModel> get filteredRequests {
    if (selectedFilter.value == 'All') {
      return leaveRequests;
    }
    return leaveRequests
        .where((request) => request.status.toLowerCase() == selectedFilter.value.toLowerCase())
        .toList();
  }

  Future<void> addLeaveRequest(LeaveModel request) async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;
      await _leaveService.createLeaveApplication(currentUserId.value, request);
      Get.snackbar('Success', 'Leave request submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLeaveStatus(String leaveId, String status, {String? reviewComments}) async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;
      await _leaveService.updateLeaveStatus(
        userId: currentUserId.value,
        leaveId: leaveId,
        status: status,
        reviewedBy: 'current_user', // You might want to get this from user session
        reviewComments: reviewComments,
      );
      Get.snackbar('Success', 'Leave request updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update leave request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLeaveRequest(String leaveId) async {
    if (currentUserId.value.isEmpty) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;
      await _leaveService.deleteLeaveApplication(currentUserId.value, leaveId);
      Get.snackbar('Success', 'Leave request deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete leave request: $e');
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
      Get.snackbar('Error', 'Failed to get leave statistics: $e');
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
      Get.snackbar('Error', 'Failed to check overlapping leave: $e');
      return false;
    }
  }

  Future<void> refreshLeaveRequests() async {
    if (currentUserId.value.isNotEmpty) {
      // The stream will automatically update the list
      // This method can be used for manual refresh if needed
    } else {
      loadSampleData();
    }
  }
}