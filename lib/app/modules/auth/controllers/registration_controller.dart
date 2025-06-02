import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/modules/auth/login/login_page.dart';
import 'package:digislips/app/modules/auth/models/user_model.dart';
import 'package:digislips/app/modules/splash_screen/splash_screen.dart';
import 'package:digislips/app/shared/widgets/bottomnavigation/bottomnavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    passwordController.addListener(_validatePasswordRequirements);
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Password validation
  void _validatePasswordRequirements() {
    String password = passwordController.text;

    hasMinLength.value = password.length >= 8;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = password.contains(RegExp(r'[a-z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool get isPasswordStrong =>
      hasMinLength.value &&
      hasUppercase.value &&
      hasLowercase.value &&
      hasNumber.value &&
      hasSpecialChar.value;

  // Field validations
  String? validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Full name cannot be empty';
    }
    if (fullName.length < 3) {
      return 'Full name must be at least 3 characters long';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Future<bool> _isRollNumberExists(String rollNumber, String department) async {
    try {
      final querySnapshot =
          await _firestore
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

  String? validateRollNumber(String rollNumber) {
    if (rollNumber.isEmpty) {
      return 'Roll number cannot be empty';
    }
    if (rollNumber.length < 5) {
      return 'Roll number must be at least 5 characters long';
    }
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  Future<bool> _isEmailExists(String email) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email.trim())
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Registration
  Future<void> registerStudent() async {
    if (!_validateForm()) return;

    isLoading(true);

    try {
      String email = emailController.text.trim();
      String rollNumber = rollNumberController.text.trim();

      // Check if roll number exists
      if (await _isRollNumberExists(rollNumber, selectedDepartment.value)) {
        isLoading(false);
        Get.snackbar(
          'Registration Failed',
          'Roll number already exists in ${selectedDepartment.value} department',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Check if email exists
      if (await _isEmailExists(email)) {
        isLoading(false);
        Get.snackbar(
          'Registration Failed',
          'An account with this email already exists',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text,
          );

      if (userCredential.user == null) {
        isLoading(false);
        Get.snackbar(
          'Registration Failed',
          'Failed to create user',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      // Update display name
      try {
        await userCredential.user?.updateDisplayName(
          fullNameController.text.trim(),
        );
      } catch (e) {
        print('Failed to update display name: $e');
      }

      // Prepare student model
      final student = Student(
        uid: userCredential.user!.uid,
        fullName: fullNameController.text.trim(),
        email: email,
        phone: phoneController.text.trim(),
        department: selectedDepartment.value,
        rollNumber: rollNumber,
        isEmailVerified: false,
        profileComplete: true,
      );

      // Save to Firestore
      await _firestore
          .collection('students')
          .doc(student.uid)
          .set(student.toMap());

      // Send email verification
      try {
        await userCredential.user?.sendEmailVerification();
      } catch (e) {
        print('Failed to send email verification: $e');
      }

      // Save UID in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', student.uid);

      Get.snackbar(
        'Registration Successful!',
        'Please login to verify your account',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
      );

      _clearForm();

      // Navigate to login screen
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => SplashScreen());
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
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading(false);
    }
  }

  bool _validateForm() {
    final validators = {
      'Full Name': validateFullName(fullNameController.text),
      'Email': validateEmail(emailController.text),
      'Phone': validatePhone(phoneController.text),
      'Roll Number': validateRollNumber(rollNumberController.text),
      'Password': validatePassword(passwordController.text),
      'Confirm Password': validateConfirmPassword(
        confirmPasswordController.text,
      ),
    };

    final firstError = validators.values.firstWhere(
      (v) => v != null,
      orElse: () => null,
    );

    if (firstError != null) {
      Get.snackbar(
        'Validation Error',
        firstError,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    return true;
  }

  String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Phone number cannot be empty';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  String? validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty';
    }
    if (confirmPassword != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

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
