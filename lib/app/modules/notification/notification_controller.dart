// app/modules/notification/notification_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digislips/app/modules/auth/models/user_model.dart';
import 'package:digislips/app/modules/leave/leave_model/leave_model.dart';
import 'package:digislips/app/modules/leave/leave_service/leave_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

enum NotificationType {
  leaveApproved,
  leaveRejected,
  leavePending,
  leaveSubmitted,
  profileUpdate,
  general,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedLeaveId;
  final Color backgroundColor;
  final IconData icon;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedLeaveId,
    required this.backgroundColor,
    required this.icon,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'relatedLeaveId': relatedLeaveId,
      'backgroundColor': backgroundColor.value,
      'icon': icon.codePoint,
    };
  }

  // Helper method to get icon from code point
  static IconData _getIconFromCodePoint(int codePoint) {
    // Map common code points to their constant IconData
    switch (codePoint) {
      case 0xe5ca: // check_circle
        return Icons.check_circle;
      case 0xe5c9: // cancel
        return Icons.cancel;
      case 0xef64: // pending
        return Icons.pending;
      case 0xe163: // send
        return Icons.send;
      case 0xe7fd: // person
        return Icons.person;
      case 0xe88e: // info
        return Icons.info;
      default:
        return Icons.info; // fallback
    }
  }

  // Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isRead: json['isRead'] ?? false,
      relatedLeaveId: json['relatedLeaveId'],
      backgroundColor: Color(json['backgroundColor']),
      icon: _getIconFromCodePoint(json['icon']),
    );
  }

  // Factory method to create from LeaveModel
  factory NotificationModel.fromLeaveModel(LeaveModel leave) {
    String title;
    String message;
    NotificationType type;
    Color backgroundColor;
    IconData icon;

    switch (leave.status.toLowerCase()) {
      case 'approved':
        title = 'Leave Approved';
        message = 'Your ${leave.leaveType} leave request has been approved';
        type = NotificationType.leaveApproved;
        backgroundColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case 'rejected':
        title = 'Leave Rejected';
        message = 'Your ${leave.leaveType} leave request has been rejected';
        type = NotificationType.leaveRejected;
        backgroundColor = const Color(0xFFD32F2F);
        icon = Icons.cancel;
        break;
      case 'pending':
        title = 'Leave Pending';
        message = 'Your ${leave.leaveType} leave request is pending approval';
        type = NotificationType.leavePending;
        backgroundColor = Colors.orange;
        icon = Icons.pending;
        break;
      default:
        title = 'Leave Submitted';
        message = 'Your ${leave.leaveType} leave request has been submitted';
        type = NotificationType.leaveSubmitted;
        backgroundColor = Colors.blue;
        icon = Icons.send;
    }

    return NotificationModel(
      id: '${leave.id}_${leave.status.toLowerCase()}',
      title: title,
      message: message,
      type: type,
      timestamp: leave.submittedAt,
      relatedLeaveId: leave.id,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }

  // Factory method for profile updates
  factory NotificationModel.profileUpdate(String message) {
    return NotificationModel(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Profile Updated',
      message: message,
      type: NotificationType.profileUpdate,
      timestamp: DateTime.now(),
      backgroundColor: Colors.indigo,
      icon: Icons.person,
    );
  }

  // Factory method for general notifications
  factory NotificationModel.general(String title, String message) {
    return NotificationModel(
      id: 'general_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.general,
      timestamp: DateTime.now(),
      backgroundColor: Colors.grey,
      icon: Icons.info,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Create a copy with updated properties
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedLeaveId,
    Color? backgroundColor,
    IconData? icon,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedLeaveId: relatedLeaveId ?? this.relatedLeaveId,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
    );
  }
}

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var student = Rxn<Student>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LeaveService _leaveService = LeaveService();

  // Stream subscriptions
  StreamSubscription? _leaveSubscription;
  StreamSubscription? _profileSubscription;

  // Track initialization state to prevent initial load notifications
  bool _isInitialProfileLoad = true;
  Student? _previousStudentData;

  // Storage keys
  static const String _notificationsKey = 'stored_notifications';
  static const String _readNotificationsKey = 'read_notifications';
  static const String _deletedNotificationsKey = 'deleted_notifications';
  static const String _shownNotificationsKey = 'shown_notifications';

  // Track which notifications have been processed
  Set<String> _readNotificationIds = {};
  Set<String> _deletedNotificationIds = {};
  Set<String> _shownNotificationIds = {};

  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
    fetchNotifications();
  }

  @override
  void onClose() {
    _leaveSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }

  // Load stored notification states
  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load read notification IDs
      final readIds = prefs.getStringList(_readNotificationsKey) ?? [];
      _readNotificationIds = readIds.toSet();

      // Load deleted notification IDs
      final deletedIds = prefs.getStringList(_deletedNotificationsKey) ?? [];
      _deletedNotificationIds = deletedIds.toSet();

      // Load shown notification IDs
      final shownIds = prefs.getStringList(_shownNotificationsKey) ?? [];
      _shownNotificationIds = shownIds.toSet();

      // Load stored notifications
      final storedNotifications = prefs.getString(_notificationsKey);
      if (storedNotifications != null) {
        final List<dynamic> notificationList = json.decode(storedNotifications);
        notifications.value = notificationList
            .map((json) => NotificationModel.fromJson(json))
            .where((notif) => !_deletedNotificationIds.contains(notif.id))
            .map(
              (notif) => notif.copyWith(
                isRead: _readNotificationIds.contains(notif.id),
              ),
            )
            .toList();

        _updateUnreadCount();
      }
    } catch (e) {
      print('Error loading stored notification data: $e');
    }
  }

  // Save notification states
  Future<void> _saveNotificationStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save read notification IDs
      await prefs.setStringList(
        _readNotificationsKey,
        _readNotificationIds.toList(),
      );

      // Save deleted notification IDs
      await prefs.setStringList(
        _deletedNotificationsKey,
        _deletedNotificationIds.toList(),
      );

      // Save shown notification IDs
      await prefs.setStringList(
        _shownNotificationsKey,
        _shownNotificationIds.toList(),
      );

      // Save current notifications
      final notificationJsonList = notifications
          .map((notif) => notif.toJson())
          .toList();
      await prefs.setString(
        _notificationsKey,
        json.encode(notificationJsonList),
      );
    } catch (e) {
      print('Error saving notification states: $e');
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      // Get UID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      if (uid == null) {
        Get.snackbar(
          'Error',
          'User not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Reset initialization flag
      _isInitialProfileLoad = true;
      _previousStudentData = null;

      // Fetch student data first
      await _fetchStudentData(uid);

      // Fetch leave-related notifications
      _fetchLeaveNotifications(uid);

      // Fetch profile-related notifications
      _fetchProfileNotifications(uid);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchStudentData(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection('students')
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        student.value = Student.fromMap(docSnapshot.data()!);
        _previousStudentData = student.value;
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  void _fetchLeaveNotifications(String uid) {
    try {
      // Cancel previous subscription if exists
      _leaveSubscription?.cancel();

      // Listen to user's leave applications for notifications
      _leaveSubscription = _leaveService
          .getUserLeaveApplications(uid)
          .listen(
            (leaveModels) {
              // Convert LeaveModel to NotificationModel
              final leaveNotifications = leaveModels
                  .map((leave) => NotificationModel.fromLeaveModel(leave))
                  .where((notif) => !_deletedNotificationIds.contains(notif.id))
                  .toList();

              // Remove old leave notifications
              notifications.removeWhere(
                (notif) =>
                    notif.type == NotificationType.leaveApproved ||
                    notif.type == NotificationType.leaveRejected ||
                    notif.type == NotificationType.leavePending ||
                    notif.type == NotificationType.leaveSubmitted,
              );

              // Add new leave notifications with proper read state
              for (var notif in leaveNotifications) {
                final updatedNotif = notif.copyWith(
                  isRead: _readNotificationIds.contains(notif.id),
                );
                notifications.add(updatedNotif);
              }

              // Sort by timestamp (newest first)
              notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

              // Update unread count and save state
              _updateUnreadCount();
              _saveNotificationStates();
            },
            onError: (error) {
              print('Error fetching leave notifications: $error');
              Get.snackbar(
                'Error',
                'Failed to load leave notifications: $error',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
          );
    } catch (e) {
      print('Error setting up leave notifications stream: $e');
    }
  }

  void _fetchProfileNotifications(String uid) {
    try {
      // Cancel previous subscription if exists
      _profileSubscription?.cancel();

      // Listen to student profile changes
      _profileSubscription = _firestore
          .collection('students')
          .doc(uid)
          .snapshots()
          .listen(
            (docSnapshot) {
              if (docSnapshot.exists) {
                final newStudent = Student.fromMap(docSnapshot.data()!);

                // Skip the initial load to prevent false notifications
                if (_isInitialProfileLoad) {
                  _isInitialProfileLoad = false;
                  student.value = newStudent;
                  _previousStudentData = newStudent;
                  return;
                }

                // Only create notification if there's an actual change in data
                if (_previousStudentData != null &&
                    _hasProfileChanged(_previousStudentData!, newStudent)) {
                  final profileNotification = NotificationModel.profileUpdate(
                    'Your profile information has been updated successfully',
                  );

                  // Only add if not already shown and not deleted
                  if (!_shownNotificationIds.contains(profileNotification.id) &&
                      !_deletedNotificationIds.contains(
                        profileNotification.id,
                      )) {
                    final updatedNotif = profileNotification.copyWith(
                      isRead: _readNotificationIds.contains(
                        profileNotification.id,
                      ),
                    );

                    // Add to notifications
                    notifications.insert(0, updatedNotif);
                    _shownNotificationIds.add(profileNotification.id);
                    _updateUnreadCount();
                    _saveNotificationStates();
                  }
                }

                student.value = newStudent;
                _previousStudentData = newStudent;
              }
            },
            onError: (error) {
              print('Error fetching profile notifications: $error');
            },
          );
    } catch (e) {
      print('Error setting up profile notifications stream: $e');
    }
  }

  // Helper method to check if profile data has actually changed
  bool _hasProfileChanged(Student oldStudent, Student newStudent) {
    // Compare relevant fields that would constitute a profile update
    return oldStudent.fullName != newStudent.fullName ||
        oldStudent.email != newStudent.email ||
        oldStudent.rollNumber != newStudent.rollNumber ||
        oldStudent.semester != newStudent.semester ||
        oldStudent.profileImageUrl != newStudent.profileImageUrl;
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((notif) => !notif.isRead).length;
  }

  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    await fetchNotifications();
    isRefreshing.value = false;
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere(
      (notif) => notif.id == notificationId,
    );
    if (index != -1 && !notifications[index].isRead) {
      // Update the notification
      notifications[index] = notifications[index].copyWith(isRead: true);

      // Track as read
      _readNotificationIds.add(notificationId);

      _updateUnreadCount();
      _saveNotificationStates();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
        _readNotificationIds.add(notifications[i].id);
      }
    }
    _updateUnreadCount();
    _saveNotificationStates();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((notif) => notif.id == notificationId);
    _deletedNotificationIds.add(notificationId);
    _updateUnreadCount();
    _saveNotificationStates();
  }

  void clearAllNotifications() {
    // Mark all current notifications as deleted
    for (var notif in notifications) {
      _deletedNotificationIds.add(notif.id);
    }

    notifications.clear();
    unreadCount.value = 0;
    _saveNotificationStates();
  }

  // Add manual notification (for testing or other purposes)
  void addNotification(String title, String message, {NotificationType? type}) {
    final notification = NotificationModel.general(title, message);

    if (!_deletedNotificationIds.contains(notification.id)) {
      final updatedNotif = notification.copyWith(
        isRead: _readNotificationIds.contains(notification.id),
      );
      notifications.insert(0, updatedNotif);
      _updateUnreadCount();
      _saveNotificationStates();
    }
  }

  // Filter notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return notifications.where((notif) => notif.type == type).toList();
  }

  // Get recent notifications (last 7 days)
  List<NotificationModel> getRecentNotifications() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return notifications
        .where((notif) => notif.timestamp.isAfter(weekAgo))
        .toList();
  }

  // Helper getters
  String get studentName => student.value?.fullName ?? 'Student';
  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasUnreadNotifications => unreadCount.value > 0;

  // Clear old storage (call this if you want to reset everything)
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
    await prefs.remove(_readNotificationsKey);
    await prefs.remove(_deletedNotificationsKey);
    await prefs.remove(_shownNotificationsKey);

    _readNotificationIds.clear();
    _deletedNotificationIds.clear();
    _shownNotificationIds.clear();
  }
}
