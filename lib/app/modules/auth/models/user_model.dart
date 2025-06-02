import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String rollNumber;
  final String semester;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final bool profileComplete;

  Student({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.rollNumber,
    this.semester = '1st Semester',
    this.profileImageUrl,
    this.isEmailVerified = false,
    this.profileComplete = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'rollNumber': rollNumber,
      'semester': semester,
      'profileImageUrl': profileImageUrl,
      'isEmailVerified': isEmailVerified,
      'profileComplete': profileComplete,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      semester: map['semester'] ?? '1st Semester',
      profileImageUrl: map['profileImageUrl'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      profileComplete: map['profileComplete'] ?? true,
    );
  }

  // Helper method to create a copy with updated fields
  Student copyWith({
    String? fullName,
    String? phone,
    String? department,
    String? semester,
    String? profileImageUrl,
    bool? isEmailVerified,
    bool? profileComplete,
  }) {
    return Student(
      uid: this.uid,
      fullName: fullName ?? this.fullName,
      email: this.email, // Email usually shouldn't be editable
      phone: phone ?? this.phone,
      department: department ?? this.department,
      rollNumber: this.rollNumber, // Roll number usually shouldn't be editable
      semester: semester ?? this.semester,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }
}