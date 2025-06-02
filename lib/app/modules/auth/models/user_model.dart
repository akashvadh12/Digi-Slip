import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String department;
  final String rollNumber;
  final bool isEmailVerified;
  final bool profileComplete;

  Student({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    required this.rollNumber,
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
      'isEmailVerified': isEmailVerified,
      'profileComplete': profileComplete,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      department: map['department'],
      rollNumber: map['rollNumber'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      profileComplete: map['profileComplete'] ?? true,
    );
  }
}
