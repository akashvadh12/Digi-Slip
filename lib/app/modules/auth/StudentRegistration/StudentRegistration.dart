import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/auth/controllers/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class StudentRegistrationScreen extends StatelessWidget {
  final RegistrationController controller = Get.put(RegistrationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar Color
            Container(height: 0, color: AppColors.primary),

            // Header Section
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                children: [
                  Text(
                    'Student Registration',
                    style: AppTextStyles.welcomeTitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join our academic community',
                    style: AppTextStyles.welcomeTitle,
                  ),
                ],
              ),
            ),

            // White Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(height: 16),

                        // Logo Container
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),

                        SizedBox(height: 20),

                        // DigiSlips Brand
                        Text('DigiSlips', style: AppTextStyles.brandName),

                        SizedBox(height: 40),

                        // Form Fields
                        _buildInputField(
                          label: 'Full Name',
                          controller: controller.fullNameController,
                          hintText: 'Enter your full name',
                        ),

                        SizedBox(height: 20),

                        _buildInputField(
                          label: 'Email',
                          controller: controller.emailController,
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: 20),

                        _buildInputField(
                          label: 'Phone Number',
                          controller: controller.phoneController,
                          hintText: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: 20),

                        // Department Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Department',
                              style: AppTextStyles.label,
                            ),
                            SizedBox(height: 8),
                            Obx(
                              () => Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.selectedDepartment.value,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    items: controller.departments.map((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        controller.selectedDepartment.value =
                                            newValue;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        _buildInputField(
                          label: 'Roll Number',
                          controller: controller.rollNumberController,
                          hintText: 'Enter your roll number',
                        ),

                        SizedBox(height: 20),

                        // Password Field
                        Obx(
                          () => _buildPasswordField(
                            label: 'Password',
                            controller: controller.passwordController,
                            hintText: 'Create a strong password',
                            isObscured: controller.isPasswordHidden.value,
                            onToggleVisibility: controller.togglePasswordVisibility,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Confirm Password Field
                        Obx(
                          () => _buildPasswordField(
                            label: 'Confirm Password',
                            controller: controller.confirmPasswordController,
                            hintText: 'Re-enter your password',
                            isObscured: controller.isConfirmPasswordHidden.value,
                            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Password Requirements
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Requirements:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Obx(() => _buildPasswordRequirement(
                                'At least 8 characters',
                                controller.hasMinLength.value,
                              )),
                              Obx(() => _buildPasswordRequirement(
                                'At least one uppercase letter',
                                controller.hasUppercase.value,
                              )),
                              Obx(() => _buildPasswordRequirement(
                                'At least one lowercase letter',
                                controller.hasLowercase.value,
                              )),
                              Obx(() => _buildPasswordRequirement(
                                'At least one number',
                                controller.hasNumber.value,
                              )),
                              Obx(() => _buildPasswordRequirement(
                                'At least one special character',
                                controller.hasSpecialChar.value,
                              )),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // Register Button
                        Obx(
                          () => Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.registerStudent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Register Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Sign In Link
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/login');
                          },
                          child: Text(
                            'Already registered? Sign in',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // Bottom Indicator
                        Container(
                          width: 134,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),

                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: onToggleVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}