import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/modules/auth/StudentRegistration/StudentRegistration.dart';
import 'package:digislips/app/shared/widgets/bottomnavigation/bottomnavigation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Login method with form validation
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      _showSnackbar('Validation Error', 'Please correct the errors in the form');
      return;
    }

    isLoading(true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _showSnackbar('Success', 'Login successful!', isSuccess: true);

      // Navigate to dashboard
      Get.offAll(() => BottomNavBarWidget());

    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showSnackbar('Error', 'Unexpected error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // Forgot password logic
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Error', 'Please enter your email address first');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showSnackbar('Error', 'Enter a valid email address');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackbar('Success', 'Password reset email sent!', isSuccess: true);
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showSnackbar('Error', 'Unexpected error: ${e.toString()}');
    }
  }

  // Navigate to registration screen
  void navigateToSignUp() {
    Get.to(() => StudentRegistrationScreen());
  }

  // Error display helper
  void _showSnackbar(String title, String message, {bool isSuccess = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess ? AppColors.greenColor : AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  // FirebaseAuth error mapping
  void _handleFirebaseError(FirebaseAuthException e) {
    final Map<String, String> errorMessages = {
      'user-not-found': 'No user found with this email.',
      'wrong-password': 'Incorrect password. Try again.',
      'invalid-email': 'Invalid email address.',
      'user-disabled': 'This account has been disabled.',
      'too-many-requests': 'Too many attempts. Try again later.',
      'network-request-failed': 'Network error. Check your connection.',
    };

    final errorMessage = errorMessages[e.code] ?? (e.message ?? 'Login failed. Try again.');

    _showSnackbar('Error', errorMessage);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
