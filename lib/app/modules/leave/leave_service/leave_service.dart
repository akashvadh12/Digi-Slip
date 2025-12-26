// app/services/leave_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new leave application in user's subcollection
  Future<String> createLeaveApplication(String userId, LeaveModel leave) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .add(leave.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create leave application: $e');
    }
  }

  // Get leave application by ID for specific user
  Future<LeaveModel?> getLeaveApplicationById(
    String userId,
    String leaveId,
  ) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .doc(leaveId)
          .get();

      if (doc.exists) {
        return LeaveModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get leave application: $e');
    }
  }

  // Get all leave applications for a user
  Stream<List<LeaveModel>> getUserLeaveApplications(String userId) {
    return _firestore
        .collection('students')
        .doc(userId)
        .collection('leave')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get all pending leave applications (for admin/HR) - searches across all users
  Stream<List<Map<String, dynamic>>> getPendingLeaveApplications() {
    return _firestore
        .collectionGroup(
          'leave',
        ) // Use collectionGroup to search across all user subcollections
        .where('status', isEqualTo: 'Pending')
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final leave = LeaveModel.fromFirestore(doc);
            return {
              'leave': leave,
              'userId': doc
                  .reference
                  .parent
                  .parent!
                  .id, // Get the user ID from parent document
              'leaveId': doc.id,
            };
          }).toList(),
        );
  }

  // Get all leave applications (for admin/HR) - searches across all users
  Stream<List<Map<String, dynamic>>> getAllLeaveApplications() {
    return _firestore
        .collectionGroup('leave')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final leave = LeaveModel.fromFirestore(doc);
            return {
              'leave': leave,
              'userId': doc.reference.parent.parent!.id,
              'leaveId': doc.id,
            };
          }).toList(),
        );
  }

  // Update leave application status
  Future<void> updateLeaveStatus({
    required String userId,
    required String leaveId,
    required String status,
    required String reviewedBy,
    String? reviewComments,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
        'reviewedBy': reviewedBy,
        'reviewedAt': Timestamp.now(),
      };

      if (reviewComments != null && reviewComments.isNotEmpty) {
        updateData['reviewComments'] = reviewComments;
      }

      await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .doc(leaveId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }

  // Delete leave application
  Future<void> deleteLeaveApplication(String userId, String leaveId) async {
    try {
      await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .doc(leaveId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete leave application: $e');
    }
  }

  // Get leave applications by date range for specific user
  Stream<List<LeaveModel>> getLeaveApplicationsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection('students')
        .doc(userId)
        .collection('leave')
        .where(
          'fromDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('fromDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('fromDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get leave applications by status for specific user
  Stream<List<LeaveModel>> getLeaveApplicationsByStatus({
    required String userId,
    required String status,
  }) {
    return _firestore
        .collection('students')
        .doc(userId)
        .collection('leave')
        .where('status', isEqualTo: status)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get leave statistics for a user
  Future<Map<String, int>> getLeaveStatistics(String userId) async {
    try {
      final currentYear = DateTime.now().year;
      final startOfYear = DateTime(currentYear, 1, 1);
      final endOfYear = DateTime(currentYear, 12, 31);

      final querySnapshot = await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .where(
            'fromDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear),
          )
          .where('fromDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();

      Map<String, int> stats = {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'totalDays': 0,
        'approvedDays': 0,
      };

      for (var doc in querySnapshot.docs) {
        final leave = LeaveModel.fromFirestore(doc);
        stats['total'] = stats['total']! + 1;
        stats['totalDays'] = stats['totalDays']! + leave.totalDays;

        switch (leave.status.toLowerCase()) {
          case 'approved':
            stats['approved'] = stats['approved']! + 1;
            stats['approvedDays'] = stats['approvedDays']! + leave.totalDays;
            break;
          case 'pending':
            stats['pending'] = stats['pending']! + 1;
            break;
          case 'rejected':
            stats['rejected'] = stats['rejected']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get leave statistics: $e');
    }
  }

  // Check for overlapping leave applications
  Future<bool> hasOverlappingLeave({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    String? excludeLeaveId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .doc(userId)
          .collection('leave')
          .where('status', whereIn: ['Pending', 'Approved'])
          .get();

      for (var doc in querySnapshot.docs) {
        // Skip the current leave application if updating
        if (excludeLeaveId != null && doc.id == excludeLeaveId) {
          continue;
        }

        final leave = LeaveModel.fromFirestore(doc);

        // Check for overlap
        if (fromDate.isBefore(leave.toDate.add(const Duration(days: 1))) &&
            toDate.isAfter(leave.fromDate.subtract(const Duration(days: 1)))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Failed to check overlapping leave: $e');
    }
  }

  // Get leave applications for a specific month
  Stream<List<LeaveModel>> getMonthlyLeaveApplications({
    required String userId,
    required int year,
    required int month,
  }) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);

    return _firestore
        .collection('students')
        .doc(userId)
        .collection('leave')
        .where(
          'fromDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('fromDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('fromDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveModel.fromFirestore(doc))
              .toList(),
        );
  }
}
