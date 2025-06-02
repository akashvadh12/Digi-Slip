// // models/leave_request.dart
// class LeaveRequest {
//   final String id;
//   final String type;
//   final DateTime startDate;
//   final DateTime endDate;
//   final String reason;
//   final String status;
//   final DateTime submissionDate;
//   final int duration;
//   final String? rejectionReason;

//   LeaveRequest({
//     required this.id,
//     required this.type,
//     required this.startDate,
//     required this.endDate,
//     required this.reason,
//     required this.status,
//     required this.submissionDate,
//     required this.duration,
//     this.rejectionReason,
//   });

//   factory LeaveRequest.fromMap(Map<String, dynamic> map, String id) {
//     return LeaveRequest(
//       id: id,
//       type: map['type'] ?? '',
//       startDate: DateTime.parse(map['startDate']),
//       endDate: DateTime.parse(map['endDate']),
//       reason: map['reason'] ?? '',
//       status: map['status'] ?? '',
//       submissionDate: DateTime.parse(map['submissionDate']),
//       duration: map['duration'] ?? 0,
//       rejectionReason: map['rejectionReason'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'type': type,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'reason': reason,
//       'status': status,
//       'submissionDate': submissionDate.toIso8601String(),
//       'duration': duration,
//       'rejectionReason': rejectionReason,
//     };
//   }
// }
