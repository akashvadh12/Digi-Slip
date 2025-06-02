// notification_controller.dart
import 'dart:async';
import 'package:digislips/app/modules/notification/notification_controller.dart';
import 'package:digislips/app/modules/notification/notification_model.dart';
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
    await _getUserId();
    if (_userId != null) {
      _loadNotifications();
      _loadUnreadCount();
    } else {
      errorMessage.value = 'User not found. Please login again.';
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
          },
          onError: (error) {
            errorMessage.value = 'Failed to load notifications: $error';
            isLoading.value = false;
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
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      isLoading.value = true;
      await _notificationService.markAllAsRead(_userId!);
      // The stream will automatically update the UI
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read: $e',
        snackPosition: SnackPosition.BOTTOM,
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
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.BOTTOM,
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
    }
  }

  Future<void> cleanupOldNotifications() async {
    if (_userId == null) return;

    try {
      await _notificationService.deleteOldNotifications(_userId!);
      Get.snackbar(
        'Success',
        'Old notifications cleaned up',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cleanup old notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper method to create notifications (can be called from other controllers)
  Future<void> createNotification({
    required String title,
    required String description,
    required NotificationType type,
    Map<String, dynamic>? metadata,
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
      );
    } catch (e) {
      print('Failed to create notification: $e');
    }
  }

  // Method to create leave status notification (can be called from leave controller)
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
    }
  }

  bool get hasUnreadNotifications => unreadCount.value > 0;
  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
}
