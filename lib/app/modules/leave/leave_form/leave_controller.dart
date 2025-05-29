// app/modules/apply_leave/controllers/apply_leave_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class ApplyLeaveController extends GetxController {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  
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
  
  // Leave Types
  final List<String> leaveTypes = [
    'Sick Leave',
    'Personal Leave',
    'Academic Leave'
  ];

  @override
  void onClose() {
    reasonController.dispose();
    destinationController.dispose();
    travelModeController.dispose();
    super.onClose();
  }

  void selectLeaveType(String type) {
    selectedLeaveType.value = type;
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
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
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: fromDate.value ?? DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
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
        for (var file in result.files) {
          if (file.path != null) {
            uploadedFiles.add(File(file.path!));
            uploadedFileNames.add(file.name);
          }
        }
        Get.snackbar(
          'Success',
          '${result.files.length} file(s) selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
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
    uploadedFiles.removeAt(index);
    uploadedFileNames.removeAt(index);
  }

  Future<List<String>> uploadFilesToFirebase() async {
    List<String> downloadUrls = [];
    
    for (int i = 0; i < uploadedFiles.length; i++) {
      try {
        String fileName = 'leave_documents/${DateTime.now().millisecondsSinceEpoch}_${uploadedFileNames[i]}';
        // UploadTask uploadTask = _storage.ref().child(fileName).putFile(uploadedFiles[i]);
        // TaskSnapshot snapshot = await uploadTask;
        // String downloadUrl = await snapshot.ref.getDownloadURL();
        // downloadUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading file ${uploadedFileNames[i]}: $e');
      }
    }
    
    return downloadUrls;
  }

  Future<void> submitApplication() async {
    // Validation
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

    try {
      isLoading.value = true;
      
      // Upload files to Firebase Storage
      List<String> documentUrls = await uploadFilesToFirebase();
      
      // Calculate total days
      int totalDays = toDate.value!.difference(fromDate.value!).inDays + 1;
      
      // Create leave application document
      Map<String, dynamic> leaveData = {
        'leaveType': selectedLeaveType.value,
        'fromDate': Timestamp.fromDate(fromDate.value!),
        'toDate': Timestamp.fromDate(toDate.value!),
        'totalDays': totalDays,
        'reason': reasonController.text.trim(),
        'destination': destinationController.text.trim(),
        'travelMode': travelModeController.text.trim(),
        'documentUrls': documentUrls,
        'status': 'Pending',
        'submittedAt': Timestamp.now(),
        'submittedBy': 'user_id_here', // Replace with actual user ID
      };
      
      // // Submit to Firestore
      // await _firestore.collection('leave_applications').add(leaveData);
      
      Get.snackbar(
        'Success',
        'Leave application submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
      
      // Clear form
      clearForm();
      
      // Navigate back
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit application: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
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
    return '${date.day}/${date.month}/${date.year}';
  }
}

