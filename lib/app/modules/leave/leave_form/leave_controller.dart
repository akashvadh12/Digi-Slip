// app/modules/apply_leave/controllers/apply_leave_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';
import 'package:digislips/app/modules/leave/leave_status/leave_status_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApplyLeaveController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Form Controllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController travelModeController = TextEditingController();

  // Observable Variables
  var selectedLeaveType = 'Sick Leave'.obs;
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var isLoading = false.obs;
  var uploadedFiles = <File>[].obs;
  var uploadedFileNames = <String>[].obs;
  var currentUserId = ''.obs;

  // Leave Types
  final List<String> leaveTypes = [
    'Sick Leave',
    'Personal Leave',
    'Academic Leave',

    'Emergency Leave',
  ];

  @override
  void onInit() {
    super.onInit();
    _getCurrentUserId();
  }

  @override
  void onClose() {
    reasonController.dispose();
    destinationController.dispose();
    travelModeController.dispose();
    super.onClose();
  }

  // Get current user ID from SharedPreferences
  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid != null && uid.isNotEmpty) {
        currentUserId.value = uid;
      } else {
        // Handle case where user is not logged in
        Get.snackbar(
          'Error',
          'User not logged in. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
        );
        // Optionally navigate to login page
        // Get.offAll(() => LoginPage());
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }

  void selectLeaveType(String type) {
    selectedLeaveType.value = type;
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      fromDate.value = picked;
      // Reset toDate if it's before the new fromDate
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    if (fromDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select from date first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value!,
      firstDate: fromDate.value!,
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      toDate.value = picked;
    }
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        // Limit to 5 files maximum
        if (uploadedFiles.length + result.files.length > 5) {
          Get.snackbar(
            'Error',
            'You can upload maximum 5 files',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
          );
          return;
        }

        for (var file in result.files) {
          if (file.path != null) {
            // Check file size (limit to 5MB per file)
            final fileSize = File(file.path!).lengthSync();
            if (fileSize > 5 * 1024 * 1024) {
              Get.snackbar(
                'Error',
                'File ${file.name} is too large. Maximum size is 5MB.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFFD32F2F),
                colorText: Colors.white,
              );
              continue;
            }

            uploadedFiles.add(File(file.path!));
            uploadedFileNames.add(file.name);
          }
        }

        if (result.files.isNotEmpty) {
          Get.snackbar(
            'Success',
            '${result.files.length} file(s) selected',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
      uploadedFileNames.removeAt(index);
    }
  }

  Future<List<String>> uploadFilesToFirebase() async {
    List<String> downloadUrls = [];

    if (currentUserId.value.isEmpty) {
      throw Exception('User not logged in');
    }

    for (int i = 0; i < uploadedFiles.length; i++) {
      try {
        // Create path: users/{uid}/leave/{timestamp}_{filename}
        String fileName =
            'students/${currentUserId.value}/leave/${DateTime.now().millisecondsSinceEpoch}_${uploadedFileNames[i]}';

        UploadTask uploadTask = _storage
            .ref()
            .child(fileName)
            .putFile(uploadedFiles[i]);

        // Show upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print(
            'Upload progress for ${uploadedFileNames[i]}: ${(progress * 100).toStringAsFixed(0)}%',
          );
        });

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        print('Successfully uploaded: ${uploadedFileNames[i]}');
      } catch (e) {
        print('Error uploading file ${uploadedFileNames[i]}: $e');
        Get.snackbar(
          'Upload Error',
          'Failed to upload ${uploadedFileNames[i]}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: Colors.white,
        );
      }
    }

    return downloadUrls;
  }

  Future<void> submitApplication() async {
    // Validation
    if (currentUserId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'User not logged in. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return;
    }

    if (fromDate.value == null || toDate.value == null) {
      Get.snackbar(
        'Error',
        'Please select both from and to dates',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return;
    }

    if (reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter reason for leave',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return;
    }

    // Check if to date is after from date
    if (toDate.value!.isBefore(fromDate.value!)) {
      Get.snackbar(
        'Error',
        'To date cannot be before from date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Upload files to Firebase Storage
      List<String> documentUrls = await uploadFilesToFirebase();

      // Calculate total days
      int totalDays = toDate.value!.difference(fromDate.value!).inDays + 1;

      // Create leave model instance
      LeaveModel leaveApplication = LeaveModel(
        userid: currentUserId.value,
        leaveType: selectedLeaveType.value,
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        totalDays: totalDays,
        reason: reasonController.text.trim(),
        destination: destinationController.text.trim(),
        travelMode: travelModeController.text.trim(),
        documentUrls: documentUrls,
        status: 'Pending',
        submittedAt: DateTime.now(),
        submittedBy: currentUserId.value,
      );

      // Submit to Firestore in user's subcollection: users/{uid}/leave/{docId}
      DocumentReference docRef = await _firestore
          .collection('students')
          .doc(currentUserId.value)
          .collection('leave')
          .add(leaveApplication.toFirestore());

      print('Leave application submitted with ID: ${docRef.id}');

      Get.snackbar(
        'Success',
        'Leave application submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear form
      clearForm();

      // Navigate to leave status page
      Get.off(() => LeaveRequestsScreen());
    } catch (e) {
      print('Error submitting leave application: $e');
      Get.snackbar(
        'Error',
        'Failed to submit application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    selectedLeaveType.value = 'Sick Leave';
    fromDate.value = null;
    toDate.value = null;
    reasonController.clear();
    destinationController.clear();
    travelModeController.clear();
    uploadedFiles.clear();
    uploadedFileNames.clear();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Get user's leave applications
  Stream<List<LeaveModel>> getUserLeaveApplications() {
    if (currentUserId.value.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('students')
        .doc(currentUserId.value)
        .collection('leave')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get total leave days for current year
  Future<int> getTotalLeaveDaysThisYear() async {
    if (currentUserId.value.isEmpty) return 0;

    try {
      final startOfYear = DateTime(DateTime.now().year, 1, 1);
      final endOfYear = DateTime(DateTime.now().year, 12, 31);

      final querySnapshot = await _firestore
          .collection('students')
          .doc(currentUserId.value)
          .collection('leave')
          .where('status', isEqualTo: 'Approved')
          .where(
            'fromDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear),
          )
          .where('fromDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();

      int totalDays = 0;
      for (var doc in querySnapshot.docs) {
        final leave = LeaveModel.fromFirestore(doc);
        totalDays += leave.totalDays;
      }

      return totalDays;
    } catch (e) {
      print('Error calculating total leave days: $e');
      return 0;
    }
  }

  // Check if user has overlapping leave applications
  Future<bool> hasOverlappingLeave(DateTime fromDate, DateTime toDate) async {
    if (currentUserId.value.isEmpty) return false;

    try {
      final querySnapshot = await _firestore
          .collection('students')
          .doc(currentUserId.value)
          .collection('leave')
          .where('status', whereIn: ['Pending', 'Approved'])
          .get();

      for (var doc in querySnapshot.docs) {
        final leave = LeaveModel.fromFirestore(doc);

        // Check for overlap
        if (fromDate.isBefore(leave.toDate.add(const Duration(days: 1))) &&
            toDate.isAfter(leave.fromDate.subtract(const Duration(days: 1)))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking overlapping leave: $e');
      return false;
    }
  }
}
