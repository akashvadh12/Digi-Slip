// controllers/leave_controller.dart
import 'package:digislips/app/modules/leave/leave_status/leave_model/leave_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveController extends GetxController {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleData(); // Load sample data for UI testing
    // fetchLeaveRequests(); // Uncomment for Firebase integration
  }

  void loadSampleData() {
    // Sample data for UI testing
    leaveRequests.value = [
      LeaveRequest(
        id: '1',
        type: 'Sick Leave',
        startDate: DateTime(2023, 10, 15),
        endDate: DateTime(2023, 10, 16),
        reason: 'Medical appointment and recovery',
        status: 'pending',
        submissionDate: DateTime(2023, 10, 14),
        duration: 2,
      ),
      LeaveRequest(
        id: '2',
        type: 'Vacation Leave',
        startDate: DateTime(2023, 12, 24),
        endDate: DateTime(2023, 12, 31),
        reason: 'Year-end family vacation',
        status: 'approved',
        submissionDate: DateTime(2023, 11, 15),
        duration: 8,
      ),
      LeaveRequest(
        id: '3',
        type: 'Family Emergency',
        startDate: DateTime(2023, 10, 25),
        endDate: DateTime(2023, 10, 25),
        reason: 'Urgent family matter requiring immediate attention',
        status: 'rejected',
        submissionDate: DateTime(2023, 10, 25),
        duration: 1,
        rejectionReason: 'Please submit additional documentation supporting your request.',
      ),
      LeaveRequest(
        id: '4',
        type: 'Personal Leave',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 17),
        reason: 'Personal matters and mental health break',
        status: 'approved',
        submissionDate: DateTime(2023, 12, 20),
        duration: 3,
      ),
      LeaveRequest(
        id: '5',
        type: 'Medical Leave',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 5),
        reason: 'Surgery and post-operative recovery',
        status: 'pending',
        submissionDate: DateTime(2024, 1, 10),
        duration: 5,
      ),
    ];
  }

  List<LeaveRequest> get filteredRequests {
    if (selectedFilter.value == 'All') {
      return leaveRequests;
    }
    return leaveRequests
        .where((request) => request.status.toLowerCase() == selectedFilter.value.toLowerCase())
        .toList();
  }

  Future<void> fetchLeaveRequests() async {
    try {
      isLoading.value = true;
      // final snapshot = await _firestore
      //     .collection('leave_requests')
      //     .orderBy('submissionDate', descending: true)
      //     .get();

      // leaveRequests.value = snapshot.docs
      //     .map((doc) => LeaveRequest.fromMap(doc.data(), doc.id))
      //     .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch leave requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addLeaveRequest(LeaveRequest request) async {
    try {
      // await _firestore.collection('leave_requests').add(request.toMap());
      await fetchLeaveRequests();
      Get.snackbar('Success', 'Leave request submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit leave request: $e');
    }
  }

  Future<void> updateLeaveStatus(String id, String status, {String? rejectionReason}) async {
    try {
      final updateData = {'status': status};
      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }
      
      // await _firestore.collection('leave_requests').doc(id).update(updateData);
      await fetchLeaveRequests();
      Get.snackbar('Success', 'Leave request updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update leave request: $e');
    }
  }
}
