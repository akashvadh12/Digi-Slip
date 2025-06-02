// profile_screen.dart
import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.student.value == null) {
                  return _buildLoadingState();
                }
                
                if (controller.hasError.value && controller.student.value == null) {
                  return _buildErrorState();
                }
                
                return RefreshIndicator(
                  onRefresh: controller.refreshProfile,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        SizedBox(height: 24),
                        if (controller.isEditingProfile.value)
                          _buildEditForm()
                        else ...[
                          _buildPersonalDetailsCard(),
                          SizedBox(height: 24),
                          _buildAcademicDetailsCard(),
                        ],
                        SizedBox(height: 24),
                        _buildActionButtons(),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: AppTextStyles.title.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Obx(() => Row(
          children: [
            GestureDetector(
              onTap: () {
                if (controller.isEditingProfile.value) {
                  controller.cancelEditing();
                } else {
                  Get.back();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.isEditingProfile.value 
                    ? Icons.close 
                    : Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Text(
                controller.isEditingProfile.value ? 'Edit Profile' : 'My Profile',
                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            if (controller.isEditingProfile.value)
              GestureDetector(
                onTap: controller.isLoading.value ? null : controller.saveProfileChanges,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(controller.isLoading.value ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                ),
              )
            else
              GestureDetector(
                onTap: controller.student.value != null ? controller.startEditingProfile : null,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(controller.student.value != null ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withOpacity(controller.student.value != null ? 1.0 : 0.5),
                    size: 20,
                  ),
                ),
              ),
          ],
        )),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  controller.fullName,
                  style: AppTextStyles.profileName.copyWith(fontSize: 24),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.role,
                    style: AppTextStyles.buttonText.copyWith(fontSize: 14),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  controller.department,
                  style: AppTextStyles.profileSubtitle.copyWith(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${controller.studentId}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (controller.student.value?.isEmailVerified == false) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Email not verified',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildProfileImage(),
        ],
      ),
    ));
  }

  Widget _buildProfileImage() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: controller.isEditingProfile.value ? controller.showImageSourceDialog : null,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Obx(() => CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: controller.isUploadingImage.value
                      ? CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        )
                      : CircleAvatar(
                          radius: 32,
                          backgroundImage: controller.profileImageUrl != null
                            ? NetworkImage(controller.profileImageUrl!)
                            : null,
                          backgroundColor: AppColors.lightGrey,
                          child: controller.profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.greyColor,
                              )
                            : null,
                        ),
                  )),
                ),
                if (controller.isEditingProfile.value && !controller.isUploadingImage.value)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 24),
          
          // Full Name Field
          _buildEditField(
            label: 'Full Name',
            controller: controller.fullNameController,
            icon: Icons.person_outline,
            iconColor: AppColors.primary,
          ),
          SizedBox(height: 20),
          
          // Phone Field
          _buildEditField(
            label: 'Phone Number',
            controller: controller.phoneController,
            icon: Icons.phone_outlined,
            iconColor: AppColors.success,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20),
          
          // Department Field
          _buildEditField(
            label: 'Department',
            controller: controller.departmentController,
            icon: Icons.school_outlined,
            iconColor: AppColors.primary,
          ),
          SizedBox(height: 20),
          
          // Semester Dropdown
          _buildSemesterDropdown(),
          SizedBox(height: 24),
          
          // Email (Read-only)
          _buildReadOnlyField(
            label: 'Email Address',
            value: controller.email,
            icon: Icons.email_outlined,
            iconColor: AppColors.secondary,
            subtitle: 'Email cannot be changed',
          ),
          SizedBox(height: 20),
          
          // Roll Number (Read-only)
          _buildReadOnlyField(
            label: 'Roll Number',
            value: controller.studentId,
            icon: Icons.badge_outlined,
            iconColor: AppColors.warning,
            subtitle: 'Roll number cannot be changed',
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Enter $label',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semester',
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:  Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: DropdownButtonFormField<String>(
            value: controller.selectedSemester.value,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pendingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today_outlined, color: AppColors.pendingColor, size: 18),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: controller.availableSemesters.map((semester) {
              return DropdownMenuItem<String>(
                value: semester,
                child: Text(semester, style: AppTextStyles.body),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedSemester.value = value;
              }
            },
          ),
        )),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:  Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: controller.fullName,
            iconColor: AppColors.primary,
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: controller.email,
            iconColor: AppColors.secondary,
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: controller.phone,
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Details',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.school_outlined,
            label: 'Department',
            value: controller.department,
            iconColor: AppColors.primary,
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.badge_outlined,
            label: 'Roll Number',
            value: controller.studentId,
            iconColor: AppColors.warning,
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Semester',
            value: controller.semester,
            iconColor: AppColors.pendingColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.profileSubtitleBold.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (controller.isEditingProfile.value) ...[
            _buildActionButton(
              icon: Icons.save_outlined,
              label: controller.isLoading.value ? 'Saving...' : 'Save Changes',
              onTap: controller.isLoading.value ? () {} : controller.saveProfileChanges,
              gradient: controller.isLoading.value ? null : AppColors.primaryGradient,
              color: controller.isLoading.value ? AppColors.lightGrey : null,
              textColor: controller.isLoading.value ? AppColors.textGrey : null,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.cancel_outlined,
              label: 'Cancel',
              onTap: controller.cancelEditing,
              color: AppColors.cardBackground,
              textColor: AppColors.textGrey,
              borderColor: AppColors.lightGrey,
            ),
          ] else ...[
            _buildActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: controller.student.value != null ? controller.startEditingProfile : () {},
              gradient: controller.student.value != null ? AppColors.primaryGradient : null,
              color: controller.student.value != null ? null : AppColors.lightGrey,
              textColor: controller.student.value != null ? null : AppColors.textGrey,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: controller.changePassword,
              color: AppColors.cardBackground,
              textColor: AppColors.secondary,
              borderColor: AppColors.secondary,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.logout_outlined,
              label: 'Logout',
              onTap: controller.logout,
              color: AppColors.error.withOpacity(0.1),
              textColor: AppColors.error,
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    LinearGradient? gradient,
    Color? color,
    Color? textColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null 
            ? Border.all(color: borderColor, width: 1.5)
            : null,
          boxShadow: gradient != null ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textColor ?? Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                color: textColor ?? Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}