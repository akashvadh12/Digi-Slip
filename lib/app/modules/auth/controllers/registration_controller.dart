import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/modules/auth/login/login_page.dart';
import 'package:digislips/app/shared/widgets/bottomnavigation/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationController extends GetxController {
  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Observable variables
  var selectedDepartment = 'CS'.obs;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  // Password validation observables
  var hasMinLength = false.obs;
  var hasUppercase = false.obs;
  var hasLowercase = false.obs;
  var hasNumber = false.obs;
  var hasSpecialChar = false.obs;

  final List<String> departments = [
    'CS',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'CHEM',
    'BIO',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    // Listen to password changes for real-time validation
    passwordController.addListener(_validatePasswordRequirements);
  }

  // ------------------- Password Visibility -------------------

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // ------------------- Password Validation -------------------

  void _validatePasswordRequirements() {
    String password = passwordController.text;

    hasMinLength.value = password.length >= 8;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool get isPasswordStrong {
    return hasMinLength.value &&
        hasUppercase.value &&
        hasLowercase.value &&
        hasNumber.value &&
        hasSpecialChar.value;
  }

  // ------------------- Field Validation -------------------

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number';
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isPasswordStrong) {
      return 'Password does not meet requirements';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ------------------- Check if Roll Number Exists -------------------

  Future<bool> _isRollNumberExists(String rollNumber, String department) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumber.trim())
          .where('department', isEqualTo: department)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking roll number: $e');
      return false;
    }
  }

  // ------------------- Check if Email Exists -------------------

  Future<bool> _isEmailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('email', isEqualTo: email.trim())
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // ------------------- Registration -------------------

  Future<void> registerStudent() async {
    if (!_validateForm()) return;

    try {
      isLoading(true);

      String email = emailController.text.trim();
      String rollNumber = rollNumberController.text.trim();

      // Check if roll number already exists in the same department
      bool rollExists = await _isRollNumberExists(
        rollNumber,
        selectedDepartment.value,
      );
      if (rollExists) {
        Get.snackbar(
          'Registration Failed',
          'Roll number already exists in ${selectedDepartment.value} department',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Check if email already exists
      bool emailExists = await _isEmailExists(email);
      if (emailExists) {
        Get.snackbar(
          'Registration Failed',
          'An account with this email already exists',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Create user with Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text,
          );

      // Update user profile
      await userCredential.user?.updateDisplayName(
        fullNameController.text.trim(),
      );

      // Save student info to Firestore
      await _firestore
          .collection('students')
          .doc(userCredential.user?.uid)
          .set({
            'uid': userCredential.user?.uid,
            'fullName': fullNameController.text.trim(),
            'email': email,
            'phone': phoneController.text.trim(),
            'department': selectedDepartment.value,
            'rollNumber': rollNumber,
            'isEmailVerified': false,
            'profileComplete': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      Get.snackbar(
        'Registration Successful!',
        'Please login to verify your account',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        duration: Duration(seconds: 5),
      );

      // Clear form
      _clearForm();

      // Navigate to login or dashboard
      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email registration not enabled';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }

      Get.snackbar(
        'Registration Failed',
        errorMessage,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading(false);
    }
  }

  // ------------------- Form Validation -------------------

  bool _validateForm() {
    List<String> errors = [];

    final fullNameError = validateFullName(fullNameController.text);
    final emailError = validateEmail(emailController.text);
    final phoneError = validatePhone(phoneController.text);
    final rollError = validateRollNumber(rollNumberController.text);
    final passwordError = validatePassword(passwordController.text);
    final confirmPasswordError = validateConfirmPassword(
      confirmPasswordController.text,
    );

    if (fullNameError != null) errors.add(fullNameError);
    if (emailError != null) errors.add(emailError);
    if (phoneError != null) errors.add(phoneError);
    if (rollError != null) errors.add(rollError);
    if (passwordError != null) errors.add(passwordError);
    if (confirmPasswordError != null) errors.add(confirmPasswordError);

    if (errors.isNotEmpty) {
      Get.snackbar(
        'Validation Error',
        errors.first,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    return true;
  }

  // ------------------- Helper Methods -------------------

  void _clearForm() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    rollNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedDepartment.value = 'CS';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    rollNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
