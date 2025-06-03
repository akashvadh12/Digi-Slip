import 'dart:async';
import 'package:digislips/app/modules/notification/notification_model.dart';
import 'package:digislips/app/modules/notification/notification_service/notification_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;
  
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;
  StreamSubscription<int>? _unreadCountSubscription;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeController() async {
    try {
      // Initialize Firebase messaging
      await _notificationService.initialize();
      
      // Get user ID and load notifications
      await _getUserId();
      if (_userId != null) {
        _loadNotifications();
        _loadUnreadCount();
      } else {
        errorMessage.value = 'User not found. Please login again.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to initialize notifications: $e';
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('uid');
    } catch (e) {
      errorMessage.value = 'Failed to get user information: $e';
    }
  }

  void _loadNotifications() {
    if (_userId == null) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationService
        .getUserNotifications(_userId!)
        .listen(
          (notificationList) {
            notifications.value = notificationList;
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (error) {
            errorMessage.value = 'Failed to load notifications: $error';
            isLoading.value = false;
            print('Error loading notifications: $error');
          },
        );
  }

  void _loadUnreadCount() {
    if (_userId == null) return;
    
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _notificationService
        .getUnreadNotificationCount(_userId!)
        .listen(
          (count) {
            unreadCount.value = count;
          },
          onError: (error) {
            print('Failed to load unread count: $error');
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;
    
    try {
      await _notificationService.markAsRead(_userId!, notificationId);
      // The stream will automatically update the UI
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    
    if (!hasUnreadNotifications) {
      Get.snackbar(
        'Info',
        'No unread notifications to mark',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    try {
      isLoading.value = true;
      await _notificationService.markAllAsRead(_userId!);
      // The stream will automatically update the UI
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) return;
    
    try {
      await _notificationService.deleteNotification(_userId!, notificationId);
      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> refreshNotifications() async {
    if (_userId == null) {
      await _getUserId();
    }
    
    if (_userId != null) {
      _loadNotifications();
      _loadUnreadCount();
    } else {
      errorMessage.value = 'User not found. Please login again.';
    }
  }

  Future<void> cleanupOldNotifications() async {
    if (_userId == null) return;
    
    try {
      isLoading.value = true;
      await _notificationService.deleteOldNotifications(_userId!);
      Get.snackbar(
        'Success',
        'Old notifications cleaned up',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cleanup old notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create notification (can be called from other controllers)
  Future<void> createNotification({
    required String title,
    required String description,
    required NotificationType type,
    Map<String, dynamic>? metadata,
    bool sendPushNotification = true,
  }) async {
    if (_userId == null) await _getUserId();
    if (_userId == null) return;
    
    try {
      await _notificationService.createNotification(
        userId: _userId!,
        title: title,
        description: description,
        type: type,
        metadata: metadata,
        sendPushNotification: sendPushNotification,
      );
    } catch (e) {
      print('Failed to create notification: $e');
      Get.snackbar(
        'Error',
        'Failed to create notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Create leave status notification (can be called from leave controller)
  Future<void> createLeaveStatusNotification({
    required String status,
    required String leaveId,
    required DateTime fromDate,
    required DateTime toDate,
    String? reviewComments,
  }) async {
    if (_userId == null) await _getUserId();
    if (_userId == null) return;
    
    try {
      await _notificationService.createLeaveStatusNotification(
        userId: _userId!,
        status: status,
        leaveId: leaveId,
        fromDate: fromDate,
        toDate: toDate,
        reviewComments: reviewComments,
      );
    } catch (e) {
      print('Failed to create leave status notification: $e');
      Get.snackbar(
        'Error',
        'Failed to create leave notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Send notification to specific user (admin function)
  Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String description,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _notificationService.createNotification(
        userId: targetUserId,
        title: title,
        description: description,
        type: type,
        metadata: metadata,
        sendPushNotification: true,
      );
      
      Get.snackbar(
        'Success',
        'Notification sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Failed to send notification to user: $e');
      Get.snackbar(
        'Error',
        'Failed to send notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Retry loading notifications on error
  Future<void> retryLoading() async {
    errorMessage.value = '';
    await refreshNotifications();
  }

  // Handle notification tap from push notification
  void handleNotificationTap(Map<String, dynamic> data) {
    final notificationId = data['notificationId'] as String?;
    final type = data['type'] as String?;
    
    if (notificationId != null) {
      // Mark notification as read
      markAsRead(notificationId);
    }
    
    // Handle navigation based on notification type
    switch (type) {
      case 'approved':
      case 'rejected':
        // Navigate to leave details if leaveId is available
        final leaveId = data['leaveId'] as String?;
        if (leaveId != null) {
          // Get.toNamed('/leave-details', arguments: leaveId);
        }
        break;
      case 'document':
        // Navigate to document screen
        final documentId = data['documentId'] as String?;
        if (documentId != null) {
          // Get.toNamed('/document-details', arguments: documentId);
        }
        break;
      case 'comment':
        // Navigate to comments screen
        break;
      default:
        // Stay on notifications screen or navigate to home
        break;
    }
  }

  // Getters for UI state
  bool get hasUnreadNotifications => unreadCount.value > 0;
  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
  
  // Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return notifications.where((notification) => notification.type == type).toList();
  }
  
  // Get recent notifications (last 7 days)
  List<NotificationModel> get recentNotifications {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return notifications
        .where((notification) => notification.createdAt.isAfter(sevenDaysAgo))
        .toList();
  }
  
  // Get notification statistics
  Map<String, int> get notificationStats {
    final stats = <String, int>{};
    for (final notification in notifications) {
      final typeKey = notification.type.toString().split('.').last;
      stats[typeKey] = (stats[typeKey] ?? 0) + 1;
    }
    return stats;
  }
}