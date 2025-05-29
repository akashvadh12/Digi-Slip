
// login_controller.dart

import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validation
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Login function
  Future<void> login() async {
    if (!_validateForm()) return;

    try {
      isLoading(true);
      
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //   email: emailController.text.trim(),
      //   password: passwordController.text.trim(),
      // );

      Get.snackbar(
        'Success',
        'Login successful!',
        backgroundColor: AppColors.greenColor,
        colorText: Colors.white,
      );

      // Navigate to dashboard
      // Get.offAll(() => DashboardScreen());
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Forgot password
  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address first',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        backgroundColor: AppColors.greenColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset email',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // Navigate to sign up
  void navigateToSignUp() {
    // Navigate to registration screen
    Get.snackbar('Info', 'Navigate to Sign Up screen');
    // Get.to(() => StudentRegistrationScreen());
  }

  bool _validateForm() {
    final emailError = validateEmail(emailController.text);
    final passwordError = validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      Get.snackbar(
        'Validation Error',
        emailError ?? passwordError ?? 'Please check your inputs',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
