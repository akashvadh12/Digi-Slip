import 'dart:ui';

import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/leave/leave_form/leave_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ApplyLeaveView extends GetView<ApplyLeaveController> {
  const ApplyLeaveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ApplyLeaveController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with gradient and glassmorphic back button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Glassmorphic back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply for Leave',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Request time off with ease',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Enhanced Body with better curved design
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).padding.top + 180),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        _buildProgressIndicator(),

                        const SizedBox(height: 32),

                        // Leave Type Section with enhanced cards
                        _buildSectionHeader(
                          'Leave Type',
                          'Select your leave category',
                          Icons.category_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedLeaveTypeSelector(),

                        const SizedBox(height: 32),

                        // Travel Dates Section with calendar design
                        _buildSectionHeader(
                          'Travel Dates',
                          'Choose your leave duration',
                          Icons.date_range_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedDateSelectors(),

                        const SizedBox(height: 32),
                        // No "Casual" leave type to remove, so nothing needed here.
                        // Reason Section with enhanced text field
                        _buildSectionHeader(
                          'Reason for Leave',
                          'Provide details about your leave',
                          Icons.edit_note_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedReasonField(),

                        const SizedBox(height: 32),

                        // Destination & Travel Mode with icon integration
                        _buildSectionHeader(
                          'Travel Information',
                          'Destination and mode of transport',
                          Icons.flight_takeoff_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedDestinationFields(),

                        const SizedBox(height: 32),

                        // Supporting Documents with drag-drop style
                        _buildSectionHeader(
                          'Supporting Documents',
                          'Upload relevant files (optional)',
                          Icons.cloud_upload_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildEnhancedDocumentUpload(),

                        const SizedBox(height: 48),

                        // Enhanced Submit Button with animation
                        _buildEnhancedSubmitButton(),

                        const SizedBox(height: 24),
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Application Form',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in all required information below',
                  style: TextStyle(fontSize: 12, color: AppColors.greyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLeaveTypeSelector() {
    return Obx(() {
      // Directly use Rx variables inside the Obx builder
      final leaveTypes = controller.leaveTypes;
      final selectedType = controller.selectedLeaveType.value;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: leaveTypes.length,
        itemBuilder: (context, index) {
          String type = leaveTypes[index];
          bool isSelected = selectedType == type;

          return GestureDetector(
            onTap: () => controller.selectLeaveType(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.25)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isSelected ? 15 : 10,
                    offset: Offset(0, isSelected ? 6 : 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getLeaveTypeIcon(type),
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLeaveTypeDescription(type),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.greyColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String _getLeaveTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return 'Medical leave';

      case 'vacation':
        return 'Holiday leave';
      case 'personal':
        return 'Personal matters';
      case 'emergency':
        return 'Urgent situations';
      case 'maternity':
        return 'Maternity leave';
      case 'paternity':
        return 'Paternity leave';
      case 'study':
        return 'Educational leave';
      default:
        return 'General leave';
    }
  }

  IconData _getLeaveTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return Icons.healing_rounded;

      case 'vacation':
        return Icons.beach_access_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'emergency':
        return Icons.warning_rounded;
      case 'maternity':
        return Icons.child_friendly_rounded;
      case 'paternity':
        return Icons.family_restroom_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  Widget _buildEnhancedDateSelectors() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedDateField(
                    'From Date',
                    controller.fromDate.value,
                    () => controller.selectFromDate(Get.context!),
                    Icons.calendar_today_rounded,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 2,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Expanded(
                  child: _buildEnhancedDateField(
                    'To Date',
                    controller.toDate.value,
                    () => controller.selectToDate(Get.context!),
                    Icons.event_rounded,
                  ),
                ),
              ],
            ),
            if (controller.fromDate.value != null &&
                controller.toDate.value != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${controller.toDate.value!.difference(controller.fromDate.value!).inDays + 1} day(s)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDateField(
    String hint,
    DateTime? date,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: date != null
                    ? AppColors.primary.withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: date != null ? AppColors.primary : AppColors.greyColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? controller.formatDate(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.reasonController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Please describe the reason for your leave request...',
          hintStyle: TextStyle(
            color: AppColors.greyColor.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        ),
      ),
    );
  }

  Widget _buildEnhancedDestinationFields() {
    return Column(
      children: [
        _buildEnhancedTextField(
          controller: controller.destinationController,
          hint: 'Enter destination',
          label: 'Destination',
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 20),
        _buildEnhancedTextField(
          controller: controller.travelModeController,
          hint: 'e.g., Flight, Train, Car',
          label: 'Mode of Travel',
          icon: Icons.directions_rounded,
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.greyColor.withOpacity(0.7),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDocumentUpload() {
    return Obx(
      () => Column(
        children: [
          // Enhanced Upload Area
          GestureDetector(
            onTap: controller.pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Supporting Documents',
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drag and drop files here or click to browse',
                    style: TextStyle(color: AppColors.greyColor, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Choose Files',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Enhanced Uploaded Files List
          if (controller.uploadedFileNames.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uploaded Files',
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...controller.uploadedFileNames.asMap().entries.map((entry) {
                    int index = entry.key;
                    String fileName = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.removeFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedSubmitButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Submitting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Submit Application',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
