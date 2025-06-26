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
            // Compact Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply for Leave',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Request time off with ease',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Compact Body
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Type Dropdown
                      _buildCompactSectionHeader(
                        'Leave Type',
                        Icons.category_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildLeaveTypeDropdown(),

                      const SizedBox(height: 20),

                      // Compact Travel Dates
                      _buildCompactSectionHeader(
                        'Travel Dates',
                        Icons.date_range_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildCompactDateSelectors(),

                      const SizedBox(height: 20),

                      // Compact Reason Field
                      _buildCompactSectionHeader(
                        'Reason for Leave',
                        Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildCompactReasonField(),

                      const SizedBox(height: 20),

                      // Travel Information in Row
                      _buildCompactSectionHeader(
                        'Travel Information',
                        Icons.flight_takeoff_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildCompactTravelFields(),
                      // uncomment to add documents
                      // const SizedBox(height: 20),

                      // Compact Document Upload
                      // _buildCompactSectionHeader(
                      //   'Supporting Documents',
                      //   Icons.cloud_upload_rounded,
                      // ),
                      // const SizedBox(height: 8),
                      // _buildCompactDocumentUpload(),
                      const SizedBox(height: 24),

                      // Submit Button
                      _buildCompactSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedLeaveType.value.isEmpty
                ? null
                : controller.selectedLeaveType.value,
            hint: Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: AppColors.greyColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select leave type',
                  style: TextStyle(color: AppColors.greyColor, fontSize: 14),
                ),
              ],
            ),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            items: controller.leaveTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    Icon(
                      _getLeaveTypeIcon(type),
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        // Text(
                        //   _getLeaveTypeDescription(type),
                        //   style: TextStyle(
                        //     color: AppColors.greyColor,
                        //     fontSize: 11,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.selectedLeaveType(newValue);
              }
            },
          ),
        ),
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
        return '';
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

  Widget _buildCompactDateSelectors() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildCompactDateField(
              'From Date',
              controller.fromDate.value,
              () => controller.selectFromDate(Get.context!),
              Icons.calendar_today_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCompactDateField(
              'To Date',
              controller.toDate.value,
              () => controller.selectToDate(Get.context!),
              Icons.event_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDateField(
    String hint,
    DateTime? date,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppColors.primary.withOpacity(0.3)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: date != null ? AppColors.primary : AppColors.greyColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? controller.formatDate(date) : 'Select date',
              style: TextStyle(
                fontSize: 13,
                color: date != null
                    ? AppColors.blackColor
                    : AppColors.greyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Describe the reason for your leave...',
          hintStyle: TextStyle(
            color: AppColors.greyColor.withOpacity(0.7),
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        ),
      ),
    );
  }

  Widget _buildCompactTravelFields() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactTextField(
            controller: controller.destinationController,
            hint: 'Destination',
            icon: Icons.location_on_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactTextField(
            controller: controller.travelModeController,
            hint: 'Travel mode',
            icon: Icons.directions_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.greyColor.withOpacity(0.7),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCompactDocumentUpload() {
    return Obx(
      () => Column(
        children: [
          GestureDetector(
            onTap: controller.pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Documents',
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Click to browse files',
                    style: TextStyle(color: AppColors.greyColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          if (controller.uploadedFileNames.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: controller.uploadedFileNames.asMap().entries.map((
                  entry,
                ) {
                  int index = entry.key;
                  String fileName = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.removeFile(index),
                          child: Icon(Icons.close, color: Colors.red, size: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactSubmitButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
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
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Submitting...', style: TextStyle(fontSize: 14)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Submit Application',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
