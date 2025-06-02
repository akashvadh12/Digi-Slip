import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/auth/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/splash_screen/splash_screen.dart';
import 'package:digislips/app/routes/app_rout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileController extends GetxController {
  // Firestore and Storage instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable student data
  var student = Rxn<Student>();

  // Loading states
  var isLoading = false.obs;
  var isEditingProfile = false.obs;
  var isUploadingImage = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Edit form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  var selectedSemester = '1st Semester'.obs;

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

  // Available departments (you can customize this)
  final List<String> availableDepartments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Chemical',
    'Others',
  ];

  // Getters for easy access to student data
  String get fullName => student.value?.fullName ?? 'Loading...';
  String get role => 'Student';
  String get department => student.value?.department ?? 'Loading...';
  String get studentId => student.value?.rollNumber ?? 'Loading...';
  String get email => student.value?.email ?? 'Loading...';
  String get phone => student.value?.phone ?? 'Loading...';
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
    departmentController.dispose();
    super.onClose();
  }

  // Fetch student data from Firestore
  Future<void> fetchStudentData() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      if (uid == null || uid.isEmpty) {
        throw Exception('No user ID found. Please login again.');
      }

      // Get profile data from Firestore
      final doc = await _firestore.collection('students').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Student firestoreStudent = Student.fromMap(doc.data()!);

        // Get profile image URL from Realtime Database
        final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
          'profile_images/$uid',
        );
        final DataSnapshot snapshot = await dbRef.get();

        String? imageUrl;
        if (snapshot.exists && snapshot.value != null) {
          imageUrl = snapshot.value.toString();
        }

        // Update student model with image URL from Realtime DB
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

  // Populate edit form controllers with current data
  void _populateEditControllers() {
    if (student.value != null) {
      fullNameController.text = student.value!.fullName;
      phoneController.text = student.value!.phone;
      departmentController.text = student.value!.department;
      selectedSemester.value = student.value!.semester;
    }
  }

  // Start editing profile
  void startEditingProfile() {
    if (student.value == null) {
      _showErrorSnackbar('Error', 'Profile data not loaded yet');
      return;
    }

    _populateEditControllers();
    isEditingProfile.value = true;
  }

  // Cancel editing
  void cancelEditing() {
    isEditingProfile.value = false;
    _populateEditControllers(); // Reset to original values
  }

  // Save profile changes
  Future<void> saveProfileChanges() async {
    if (student.value == null) return;

    try {
      isLoading.value = true;

      // Validate required fields
      if (fullNameController.text.trim().isEmpty) {
        _showErrorSnackbar('Validation Error', 'Full name is required');
        return;
      }

      if (phoneController.text.trim().isEmpty) {
        _showErrorSnackbar('Validation Error', 'Phone number is required');
      }

      // Create updated student object
      final updatedStudent = student.value!.copyWith(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        department: departmentController.text.trim().isEmpty
            ? selectedSemester.value
            : departmentController.text.trim(),
        semester: selectedSemester.value,
      );

      await updateStudentData(updatedStudent);
      isEditingProfile.value = false;
    } catch (e) {
      print('Error saving profile changes: $e');
      _showErrorSnackbar('Error', 'Failed to save changes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update student data in Firestore
  Future<void> updateStudentData(Student updatedStudent) async {
    try {
      final dataToUpdate = updatedStudent.toMap();
      dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('students')
          .doc(updatedStudent.uid)
          .update(dataToUpdate);

      student.value = updatedStudent;
      _showSuccessSnackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      print('Error updating student data: $e');
      _showErrorSnackbar('Error', 'Failed to update profile: ${e.toString()}');
      rethrow;
    }
  }

  // Show image source selection dialog
  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Select Image Source', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Camera', style: AppTextStyles.body),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.secondary),
              title: Text('Gallery', style: AppTextStyles.body),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            if (student.value?.profileImageUrl != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Remove Photo', style: AppTextStyles.body),
                onTap: () {
                  Get.back();
                  removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  } // Pick image from camera

  Future<void> pickImageFromCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showErrorSnackbar(
          'Permission Denied',
          'Camera permission is required',
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadProfileImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      _showErrorSnackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadProfileImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      _showErrorSnackbar('Error', 'Failed to select image: ${e.toString()}');
    }
  }

  // Upload profile image to Firebase Storage and update Realtime Database
  Future<void> uploadProfileImage(File imageFile) async {
    if (student.value == null || student.value!.uid.isEmpty) {
      _showErrorSnackbar('Error', 'User data not found');
      return;
    }

    try {
      isUploadingImage.value = true;

      final String fileName =
          'profile_${student.value!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'profile_images/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      final String downloadURL = await snapshot.ref.getDownloadURL();

      // Save the image URL to Realtime Database under user's node
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
        'profile_images/${student.value!.uid}',
      );
      await dbRef.set(downloadURL);

      // Optionally update local student model with new URL
      final updatedStudent = student.value!.copyWith(
        profileImageUrl: downloadURL,
      );
      student.value = updatedStudent;

      _showSuccessSnackbar('Success', 'Profile image updated successfully!');
    } catch (e) {
      print('Error uploading profile image: $e');
      _showErrorSnackbar('Error', 'Failed to upload image: ${e.toString()}');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Remove profile image from Firebase Storage and Realtime Database
  Future<void> removeProfileImage() async {
    if (student.value == null || student.value!.profileImageUrl == null) {
      _showErrorSnackbar('Error', 'No profile image to remove');
      return;
    }

    try {
      isUploadingImage.value = true;

      try {
        final Reference imageRef = _storage.refFromURL(
          student.value!.profileImageUrl!,
        );
        await imageRef.delete();
      } catch (e) {
        print('Error deleting image from storage: $e');
        // Continue even if deletion fails
      }

      // Remove image URL from Realtime Database
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child(
        'profile_images/${student.value!.uid}',
      );
      await dbRef.remove();

      // Update local student model
      final updatedStudent = student.value!.copyWith(profileImageUrl: null);
      student.value = updatedStudent;

      _showSuccessSnackbar('Success', 'Profile image removed successfully!');
    } catch (e) {
      print('Error removing profile image: $e');
      _showErrorSnackbar('Error', 'Failed to remove image: ${e.toString()}');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Refresh profile from Realtime Database
  Future<void> refreshProfile() async {
    await fetchStudentData(); // Make sure fetchStudentData() pulls from Realtime DB
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
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    colorText: AppColors.error,
                    snackPosition: SnackPosition.TOP,
                    margin: EdgeInsets.all(16),
                    borderRadius: 12,
                  );

                  await Future.delayed(Duration(milliseconds: 500));
                  Get.offAll(
                    () => SplashScreen(),
                    transition: Transition.fadeIn,
                  );
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

  // Helper methods for showing snackbars
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success.withOpacity(0.1),
      colorText: AppColors.success,
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
      backgroundColor: AppColors.error.withOpacity(0.1),
      colorText: AppColors.error,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      duration: Duration(seconds: 4),
      icon: Icon(Icons.error, color: AppColors.error),
    );
  }
}
