import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';
import 'package:digislips/app/modules/leave/leave_status/leave_status_page.dart';
import 'package:file_picker/file_picker.dart';
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
  var isCheckingLeave = false.obs;
  var uploadedFiles = <File>[].obs;
  var uploadedFileNames = <String>[].obs;
  var currentUserId = ''.obs;
  var hasOverlappingLeave = false.obs;

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

  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId.value = prefs.getString('uid') ?? '';
      if (currentUserId.isEmpty) {
        throw Exception('User not logged in');
      }
    } catch (e) {
      _showErrorSnackbar('Error getting user ID', e.toString());
    }
  }

  // Date Selection Methods
  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await _showDatePicker(context);
    if (picked != null) {
      fromDate.value = picked;
      // Reset validation when dates change
      hasOverlappingLeave.value = false;
      // If toDate is before new fromDate, reset it
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
      // Check for overlapping leaves if both dates are set
      if (toDate.value != null) {
        await _checkOverlappingLeaves();
      }
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    if (fromDate.value == null) {
      _showErrorSnackbar('Error', 'Please select from date first');
      return;
    }

    final DateTime? picked = await _showDatePicker(
      context,
      initialDate: fromDate.value!,
      firstDate: fromDate.value!,
    );
    if (picked != null) {
      toDate.value = picked;
      await _checkOverlappingLeaves();
    }
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
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
  }

  // File Handling Methods
  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        _validateAndAddFiles(result.files);
      }
    } catch (e) {
      _showErrorSnackbar('File Pick Error', e.toString());
    }
  }

  void _validateAndAddFiles(List<PlatformFile> files) {
    // Limit to 5 files maximum
    if (uploadedFiles.length + files.length > 5) {
      _showErrorSnackbar('Limit Exceeded', 'You can upload maximum 5 files');
      return;
    }

    for (var file in files) {
      if (file.path != null) {
        // Check file size (limit to 5MB per file)
        final fileSize = File(file.path!).lengthSync();
        if (fileSize > 5 * 1024 * 1024) {
          _showErrorSnackbar(
            'File Too Large',
            '${file.name} exceeds 5MB limit',
          );
          continue;
        }

        uploadedFiles.add(File(file.path!));
        uploadedFileNames.add(file.name);
      }
    }

    if (files.isNotEmpty) {
      _showSuccessSnackbar('Files Selected', '${files.length} file(s) added');
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
      uploadedFileNames.removeAt(index);
    }
  }

  // Leave Submission Methods
  Future<void> submitApplication() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // Check for overlapping leaves again right before submission
      await _checkOverlappingLeaves();
      if (hasOverlappingLeave.value) {
        _showErrorSnackbar(
          'Overlapping Leave',
          'You already have a leave for these dates',
        );
        return;
      }

      // Upload files and submit application
      List<String> documentUrls = await uploadFilesToFirebase();
      await _createLeaveApplication(documentUrls);

      _showSuccessSnackbar('Success', 'Leave application submitted!');
      clearForm();
      Get.off(() => LeaveRequestsScreen());
    } catch (e) {
      _showErrorSnackbar('Submission Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (currentUserId.value.isEmpty) {
      _showErrorSnackbar('Error', 'User not logged in');
      return false;
    }

    if (fromDate.value == null || toDate.value == null) {
      _showErrorSnackbar('Error', 'Please select travel dates');
      return false;
    }

    if (toDate.value!.isBefore(fromDate.value!)) {
      _showErrorSnackbar('Error', 'To date cannot be before from date');
      return false;
    }

    if (reasonController.text.trim().isEmpty) {
      _showErrorSnackbar('Error', 'Please enter a reason');
      return false;
    }

    return true;
  }

  Future<List<String>> uploadFilesToFirebase() async {
    List<String> downloadUrls = [];

    for (int i = 0; i < uploadedFiles.length; i++) {
      try {
        String fileName =
            'students/${currentUserId.value}/leave/${DateTime.now().millisecondsSinceEpoch}_${uploadedFileNames[i]}';

        TaskSnapshot snapshot = await _storage
            .ref(fileName)
            .putFile(uploadedFiles[i])
            .whenComplete(() {});

        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading ${uploadedFileNames[i]}: $e');
        _showErrorSnackbar(
          'Upload Error',
          'Failed to upload ${uploadedFileNames[i]}',
        );
      }
    }

    return downloadUrls;
  }

  Future<void> _createLeaveApplication(List<String> documentUrls) async {
    int totalDays = toDate.value!.difference(fromDate.value!).inDays + 1;

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

    await _firestore
        .collection('students')
        .doc(currentUserId.value)
        .collection('leave')
        .add(leaveApplication.toFirestore());
  }

  // Overlapping Leave Validation
  Future<void> _checkOverlappingLeaves() async {
    if (fromDate.value == null || toDate.value == null) return;

    try {
      isCheckingLeave.value = true;
      final overlaps = await _hasOverlappingLeaves(
        fromDate.value!,
        toDate.value!,
      );
      hasOverlappingLeave.value = overlaps;
    } catch (e) {
      print('Error checking overlapping leaves: $e');
    } finally {
      isCheckingLeave.value = false;
    }
  }

  Future<bool> _hasOverlappingLeaves(DateTime from, DateTime to) async {
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
        if (_datesOverlap(from, to, leave.fromDate, leave.toDate)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking overlaps: $e');
      return false;
    }
  }

  bool _datesOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2.add(const Duration(days: 1))) &&
        end1.isAfter(start2.subtract(const Duration(days: 1)));
  }

  // Utility Methods
  void clearForm() {
    selectedLeaveType.value = 'Sick Leave';
    fromDate.value = null;
    toDate.value = null;
    reasonController.clear();
    destinationController.clear();
    travelModeController.clear();
    uploadedFiles.clear();
    uploadedFileNames.clear();
    hasOverlappingLeave.value = false;
  }

  String formatDate(DateTime? date) {
    return date?.toString().split(' ')[0] ?? '';
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 1),
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }
}
