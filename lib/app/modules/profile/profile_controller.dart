import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/auth/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/splash_screen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var student = Rxn<Student>();

  var isLoading = false.obs;
  var isEditingProfile = false.obs;
  var isUploadingImage = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Edit form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final parentEmailController = TextEditingController();
  // Removed departmentController as we're using dropdown
  var selectedSemester = '1st Semester'.obs;
  var selectedDepartment = 'CS'.obs;

  // Available semesters
  final List<String> availableSemesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  // Available departments
  final List<String> availableDepartments = [
    'CS',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
    'CHEM',
    'BIO',
  ];

  // Keep all existing getters
  String get fullName => student.value?.fullName ?? 'Loading...';
  String get role => 'Student';
  String get department => student.value?.department ?? 'Loading...';
  String get studentId => student.value?.rollNumber ?? 'Loading...';
  String get email => student.value?.email ?? 'Loading...';
  String get phone => student.value?.phone ?? 'Loading...';
  String get parentPhone => student.value?.parentPhone ?? 'Not provided';
  String get parentEmail => student.value?.parentEmail ?? 'Not provided';
  String get semester => student.value?.semester ?? '1st Semester';
  String? get profileImageUrl => student.value?.profileImageUrl;

  @override
  void onInit() {
    super.onInit();
    fetchStudentData();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    parentPhoneController.dispose();
    parentEmailController.dispose();
    // Removed departmentController.dispose()
    super.onClose();
  }

  Future<void> fetchStudentData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      if (uid == null || uid.isEmpty) {
        throw Exception('No user ID found. Please login again.');
      }

      final doc = await _firestore.collection('students').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Student firestoreStudent = Student.fromMap(doc.data()!);

        final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
          'profile_images/$uid',
        );
        final DataSnapshot snapshot = await dbRef.get();

        String? imageUrl;
        if (snapshot.exists && snapshot.value != null) {
          imageUrl = snapshot.value.toString();
        }

        student.value = firestoreStudent.copyWith(profileImageUrl: imageUrl);
        _populateEditControllers();
      } else {
        throw Exception('Student data not found');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching student data: $e');
      _showErrorSnackbar(
        'Error',
        'Failed to load profile data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _populateEditControllers() {
    if (student.value != null) {
      fullNameController.text = student.value!.fullName;
      phoneController.text = student.value!.phone;
      parentPhoneController.text = student.value!.parentPhone ?? '';
      parentEmailController.text = student.value!.parentEmail ?? '';
      selectedSemester.value = student.value!.semester;
      selectedDepartment.value = student.value!.department;
    }
  }

  void startEditingProfile() {
    if (student.value == null) {
      _showErrorSnackbar('Error', 'Profile data not loaded yet');
      return;
    }
    _populateEditControllers();
    isEditingProfile.value = true;
  }

  void cancelEditing() {
    isEditingProfile.value = false;
    _populateEditControllers();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Updated to require exactly 10 digits
  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // NEW: Validation to check if parent email is same as student email
  bool _isSameAsStudentEmail(String parentEmail) {
    if (student.value == null) return false;
    return parentEmail.trim().toLowerCase() ==
        student.value!.email.trim().toLowerCase();
  }

  Future<void> saveProfileChanges() async {
    if (student.value == null) return;

    try {
      isLoading.value = true;

      if (fullNameController.text.trim().isEmpty) {
        _showErrorSnackbar('Validation Error', 'Full name is required');
        return;
      }

      if (!_isValidPhone(phoneController.text.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid 10-digit phone number',
        );
        return;
      }

      if (parentPhoneController.text.trim().isNotEmpty &&
          !_isValidPhone(parentPhoneController.text.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid 10-digit parent phone number',
        );
        return;
      }

      if (parentEmailController.text.trim().isNotEmpty &&
          !_isValidEmail(parentEmailController.text.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid parent email address',
        );
        return;
      }

      // NEW: Check if parent email is same as student email
      if (parentEmailController.text.trim().isNotEmpty &&
          _isSameAsStudentEmail(parentEmailController.text.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Parent email cannot be the same as student email',
        );
        return;
      }

      final updatedStudent = student.value!.copyWith(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        parentPhone: parentPhoneController.text.trim().isEmpty
            ? null
            : parentPhoneController.text.trim(),
        parentEmail: parentEmailController.text.trim().isEmpty
            ? null
            : parentEmailController.text.trim(),
        semester: selectedSemester.value,
        department: selectedDepartment.value,
      );

      // ✅ Prevent saving if no changes were made
      if (updatedStudent == student.value) {
        _showErrorSnackbar(
          'No Changes',
          'No changes were made to your profile.',
        );
        return;
      }

      await updateStudentData(updatedStudent);
      isEditingProfile.value = false;

      _showSuccessSnackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      print('Error saving profile changes: $e');
      _showErrorSnackbar('Error', 'Failed to save changes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStudentData(Student updatedStudent) async {
    try {
      final dataToUpdate = updatedStudent.toMap();
      dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('students')
          .doc(updatedStudent.uid)
          .update(dataToUpdate);

      student.value = updatedStudent;
    } catch (e) {
      print('Error updating student data: $e');
      _showErrorSnackbar('Error', 'Failed to update profile: ${e.toString()}');
      rethrow;
    }
  }

  // Removed the buildDepartmentDropdown method since department selection
  // will be handled directly in the UI like semester selection

  // Updated updateParentInfo method with the same validation
  Future<void> updateParentInfo({
    required String parentPhone,
    required String parentEmail,
  }) async {
    if (student.value == null) return;

    try {
      isLoading.value = true;

      if (parentPhone.trim().isNotEmpty && !_isValidPhone(parentPhone.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid 10-digit parent phone number',
        );
        return;
      }

      if (parentEmail.trim().isNotEmpty && !_isValidEmail(parentEmail.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Please enter a valid parent email address',
        );
        return;
      }

      // NEW: Check if parent email is same as student email
      if (parentEmail.trim().isNotEmpty &&
          _isSameAsStudentEmail(parentEmail.trim())) {
        _showErrorSnackbar(
          'Validation Error',
          'Parent email cannot be the same as student email',
        );
        return;
      }

      final updatedStudent = student.value!.copyWith(
        parentPhone: parentPhone.trim().isEmpty ? null : parentPhone.trim(),
        parentEmail: parentEmail.trim().isEmpty ? null : parentEmail.trim(),
      );

      await updateStudentData(updatedStudent);
      _showSuccessSnackbar(
        'Success',
        'Parent information updated successfully!',
      );
    } catch (e) {
      print('Error updating parent info: $e');
      _showErrorSnackbar(
        'Error',
        'Failed to update parent information: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await fetchStudentData();
  }

  void changePassword() {
    Get.snackbar(
      'Change Password',
      'Navigating to change password...',
      backgroundColor: AppColors.secondary,
      colorText: AppColors.background,
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
              onPressed: () async {
                Get.back();
                try {
                  await FirebaseAuth.instance.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('uid');
                  student.value = null;

                  Get.snackbar(
                    'Logged Out',
                    'You have been successfully logged out',
                    backgroundColor: AppColors.error,
                    colorText: AppColors.whiteColor,
                    snackPosition: SnackPosition.TOP,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                  );

                  await Future.delayed(Duration(milliseconds: 500));
                  Get.offAll(() => SplashScreen());
                } catch (e) {
                  print('Error during logout: $e');
                  _showErrorSnackbar('Error', 'Failed to logout properly');
                }
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

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: AppColors.success),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.whiteColor,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.error, color: AppColors.error),
    );
  }
}
