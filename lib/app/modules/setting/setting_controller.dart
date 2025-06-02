import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings Controller using GetX
class SettingsController extends GetxController {
  var notificationsEnabled = true.obs;
  var userName = 'John Anderson'.obs;
  var userRole = 'Student'.obs;
  var userDepartment = 'Computer Science'.obs;
  var isLoading = false.obs;

  // Form controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize form controllers with current data
    nameController.text = userName.value;
    emailController.text = 'john.anderson@example.com';
    phoneController.text = '+1 234 567 8900';
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    Get.snackbar(
      'Notifications',
      notificationsEnabled.value
          ? 'Notifications enabled'
          : 'Notifications disabled',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: AppTextStyles.title),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: AppColors.greyColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close the dialog first

              // 1. Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // 2. Clear UID from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('uid');

              // 3. Navigate to login screen (clear all previous routes)
              Get.offAllNamed(Routes.LOGIN);

              // 4. Show logout success snackbar
              Get.snackbar(
                'Success',
                'Logged out successfully',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showEditProfileDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: AppTextStyles.title),
              SizedBox(height: 20),

              _buildTextField(
                'Full Name',
                nameController,
                Icons.person_outline,
              ),
              SizedBox(height: 16),
              _buildTextField('Email', emailController, Icons.email_outlined),
              SizedBox(height: 16),
              _buildTextField('Phone', phoneController, Icons.phone_outlined),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.greyColor),
                    ),
                  ),
                  SizedBox(width: 12),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          isLoading.value ? null : () => _updateProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isLoading.value
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showChangePasswordDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: AppTextStyles.title),
              SizedBox(height: 20),

              _buildPasswordField(
                'Current Password',
                currentPasswordController,
              ),
              SizedBox(height: 16),
              _buildPasswordField('New Password', newPasswordController),
              SizedBox(height: 16),
              _buildPasswordField(
                'Confirm New Password',
                confirmPasswordController,
              ),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _clearPasswordFields();
                      Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.greyColor),
                    ),
                  ),
                  SizedBox(width: 12),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          isLoading.value ? null : () => _changePassword(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isLoading.value
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Change',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPrivacyPolicyDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          height: Get.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: AppTextStyles.title),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''We are committed to protecting your privacy and ensuring the security of your personal information.

Information We Collect:
• Personal identification information (Name, email, phone)
• Usage data and preferences
• Device information

How We Use Your Information:
• To provide and maintain our services
• To notify you about changes to our services
• To provide customer support
• To gather analysis or valuable information

Data Security:
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

Your Rights:
• Access your personal data
• Correct inaccurate data
• Request deletion of your data
• Object to processing of your data

Contact Us:
If you have any questions about this Privacy Policy, please contact us at privacy@example.com

Last updated: January 2024''',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showHelpSupportDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help & Support', style: AppTextStyles.title),
              SizedBox(height: 20),

              _buildSupportOption(
                Icons.email_outlined,
                'Email Support',
                'support@example.com',
                () => _contactSupport('email'),
              ),
              SizedBox(height: 16),
              _buildSupportOption(
                Icons.phone_outlined,
                'Phone Support',
                '+1 (800) 123-4567',
                () => _contactSupport('phone'),
              ),
              SizedBox(height: 16),
              _buildSupportOption(
                Icons.chat_outlined,
                'Live Chat',
                'Available 24/7',
                () => _contactSupport('chat'),
              ),
              SizedBox(height: 16),
              _buildSupportOption(
                Icons.help_outline,
                'FAQ',
                'Frequently Asked Questions',
                () => _contactSupport('faq'),
              ),

              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.greyColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _updateProfile() async {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Name cannot be empty',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    userName.value = nameController.text;
    isLoading.value = false;
    Get.back();

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _changePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'New passwords do not match',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    isLoading.value = false;
    _clearPasswordFields();
    Get.back();

    Get.snackbar(
      'Success',
      'Password changed successfully',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void _contactSupport(String type) {
    Get.back();
    String message = '';
    switch (type) {
      case 'email':
        message = 'Opening email client...';
        break;
      case 'phone':
        message = 'Calling support...';
        break;
      case 'chat':
        message = 'Starting live chat...';
        break;
      case 'faq':
        message = 'Opening FAQ page...';
        break;
    }

    Get.snackbar(
      'Support',
      message,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
