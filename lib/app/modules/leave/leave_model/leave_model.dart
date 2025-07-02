// app/models/leave_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String? id;
  final String? userid;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final String reason;
  final String destination;
  final String travelMode;
  final List<String> documentUrls;
  final String status;
  final String? leav_id;
  final DateTime submittedAt;
  final String submittedBy;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewComments;

  LeaveModel({
    required this.userid,
    this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    this.destination = '',
    this.travelMode = '',
    this.documentUrls = const [],
    this.status = 'Pending',
    this.leav_id,
    required this.submittedAt,
    required this.submittedBy,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewComments,
  });

  // Convert from Firestore document
  factory LeaveModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return LeaveModel(
      id: doc.id,
      leaveType: data['leaveType'] ?? '',
      fromDate: (data['fromDate'] as Timestamp).toDate(),
      toDate: (data['toDate'] as Timestamp).toDate(),
      totalDays: data['totalDays'] ?? 0,
      reason: data['reason'] ?? '',
      destination: data['destination'] ?? '',
      travelMode: data['travelMode'] ?? '',
      documentUrls: List<String>.from(data['documentUrls'] ?? []),
      status: data['status'] ?? 'Pending',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      submittedBy: data['submittedBy'] ?? '',
      userid: data['userid']?? '',
      reviewedBy: data['reviewedBy'],
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewComments: data['reviewComments'], 
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'leaveType': leaveType,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'totalDays': totalDays,
      'reason': reason,
      'destination': destination,
      'travelMode': travelMode,
      'documentUrls': documentUrls,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'submittedBy': submittedBy,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewComments': reviewComments,
    };
  }

  // Create a copy with updated fields
  LeaveModel copyWith({
    String? id,
    String? leaveType,
    DateTime? fromDate,
    DateTime? toDate,
    int? totalDays,
    String? reason,
    String? destination,
    String? travelMode,
    List<String>? documentUrls,
    String? status,
    DateTime? submittedAt,
    String? submittedBy,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComments,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      leaveType: leaveType ?? this.leaveType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      destination: destination ?? this.destination,
      travelMode: travelMode ?? this.travelMode,
      documentUrls: documentUrls ?? this.documentUrls,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      submittedBy: submittedBy ?? this.submittedBy,
      userid: userid ?? this.userid,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }

  @override
  String toString() {
    return 'LeaveModel(id: $id, leaveType: $leaveType, fromDate: $fromDate, toDate: $toDate, status: $status)';
  }
}
