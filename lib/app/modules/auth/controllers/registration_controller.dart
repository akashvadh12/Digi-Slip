
import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationController extends GetxController {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  
  var selectedDepartment = 'CS'.obs;
  var isLoading = false.obs;
  
  final List<String> departments = [
    'CS', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL', 'CHEM', 'BIO'
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Validation
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }
    
    // Check if it's an email
    if (value.contains('@')) {
      if (!GetUtils.isEmail(value)) {
        return 'Enter a valid email address';
      }
    } else {
      // Check if it's a phone number
      if (!GetUtils.isPhoneNumber(value)) {
        return 'Enter a valid phone number';
      }
    }
    return null;
  }

  String? validateRollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    if (value.trim().length < 3) {
      return 'Roll number must be at least 3 characters';
    }
    return null;
  }

  Future<void> registerStudent() async {
    if (!_validateForm()) return;

    try {
      isLoading(true);
      
      // Create user account (if email provided)
      String emailOrPhone = emailPhoneController.text.trim();
      UserCredential? userCredential;
      
      if (emailOrPhone.contains('@')) {
        // Register with email - you'll need to handle password
        // For demo purposes, using a default password
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailOrPhone,
          password: 'defaultPassword123!', // In real app, get this from user
        );
      }

      // Save student data to Firestore
      await _firestore.collection('students').add({
        'fullName': fullNameController.text.trim(),
        'emailOrPhone': emailOrPhone,
        'department': selectedDepartment.value,
        'rollNumber': rollNumberController.text.trim(),
        'uid': userCredential?.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Student registered successfully!',
        backgroundColor: AppColors.greenColor,
        colorText: Colors.white,
      );

      // Navigate to dashboard or login
      // Get.offAll(() => DashboardScreen());
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  bool _validateForm() {
    final fullNameError = validateFullName(fullNameController.text);
    final emailError = validateEmailOrPhone(emailPhoneController.text);
    final rollError = validateRollNumber(rollNumberController.text);

    if (fullNameError != null || emailError != null || rollError != null) {
      Get.snackbar(
        'Validation Error',
        fullNameError ?? emailError ?? rollError ?? 'Please check your inputs',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailPhoneController.dispose();
    rollNumberController.dispose();
    super.onClose();
  }
}
