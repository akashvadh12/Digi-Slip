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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileCard(),
            SizedBox(height: 24),
            _buildPersonalDetailsCard(),
            SizedBox(height: 24),
            _buildAcademicDetailsCard(),
            SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      title: Text(
        'My Profile',
        style: AppTextStyles.welcomeTitle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          onPressed: controller.editProfile,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Center(
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
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/images/profile_avatar.png'),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lightGrey,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      ),
                    ),
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
        ],
      ),
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
            label: 'Student ID',
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: controller.editProfile,
            gradient: AppColors.primaryGradient,
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
      ),
    );
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