import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Profile data
  final String fullName = "John Anderson";
  final String role = "Student";
  final String department = "Computer Science";
  final String studentId = "CS2023045";
  final String email = "john.anderson@digislips.edu";
  final String phone = "+1 (555) 123-4567";
  final String semester = "4th Semester";
  
  // Loading states
  var isLoading = false.obs;
  var isEditingProfile = false.obs;
  
  void editProfile() {
    isEditingProfile.value = true;
    // Navigate to edit profile screen
    Get.snackbar(
      'Edit Profile', 
      'Navigating to edit profile...',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 2),
    );
  }
  
  void changePassword() {
    Get.snackbar(
      'Change Password', 
      'Navigating to change password...',
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      colorText: AppColors.secondary,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 2),
    );
  }
  
  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.all(24),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error, size: 24),
            SizedBox(width: 12),
            Text('Logout', style: AppTextStyles.title),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.linkText),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Logged Out', 
                  'You have been successfully logged out',
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  colorText: AppColors.error,
                  snackPosition: SnackPosition.TOP,
                  margin: EdgeInsets.all(16),
                  borderRadius: 12,
                );
              },
              child: Text(
                'Logout', 
                style: AppTextStyles.buttonText.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
