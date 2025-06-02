
import 'package:digislips/app/modules/notification/notification_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class NotificationsController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    isLoading.value = true;
    
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      notifications.value = [
        NotificationModel(
          id: '1',
          title: 'Leave Approved',
          description: 'Your Pink Slip request for March 10-11 has been approved.',
          time: '2 hrs ago',
          type: NotificationType.approved,
        ),
        NotificationModel(
          id: '2',
          title: 'Leave Rejected',
          description: 'Your leave request for March 15 was not approved. See comments.',
          time: 'Yesterday',
          type: NotificationType.rejected,
        ),
        NotificationModel(
          id: '3',
          title: 'New Comment',
          description: 'Prof. Smith commented on your leave request.',
          time: '3 hrs ago',
          type: NotificationType.comment,
        ),
        NotificationModel(
          id: '4',
          title: 'Document Updated',
          description: 'Your Pink Slip document has been updated with new information.',
          time: '5 hrs ago',
          type: NotificationType.document,
        ),
        NotificationModel(
          id: '5',
          title: 'Leave Approved',
          description: 'Your Pink Slip request for March 5-6 has been approved.',
          time: 'Yesterday',
          type: NotificationType.approved,
        ),
      ];
      isLoading.value = false;
    });
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
  }

  void refreshNotifications() {
    loadNotifications();
  }
}