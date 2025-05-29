

// notifications_screen.dart
import 'package:digislips/app/core/theme/app_colors.dart';
import 'package:digislips/app/core/theme/app_text_styles.dart';
import 'package:digislips/app/modules/notification/notification_controller.dart';
import 'package:digislips/app/modules/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshNotifications();
          },
          color: AppColors.primary,
          child: _buildNotificationsList(controller),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(NotificationsController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      title: Text(
        'Notifications',
        style: AppTextStyles.welcomeTitle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          final hasUnread = controller.notifications.any((n) => !n.isRead);
          return hasUnread
              ? TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: Text(
                    'Mark all',
                    style: AppTextStyles.linkText.copyWith(color: Colors.white),
                  ),
                )
              : const SizedBox();
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll show up here',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.notifications.length,
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        return _buildNotificationCard(notification, controller);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.markAsRead(notification.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead ? AppColors.cardBackground : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: notification.isRead 
                  ? Border.all(color: AppColors.borderColor, width: 1)
                  : Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: notification.isRead 
                      ? AppColors.greyColor.withOpacity(0.05)
                      : AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                color: notification.isRead ? AppColors.blackColor : AppColors.blackColor,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              Text(
                                notification.time,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: AppTextStyles.body.copyWith(
                          height: 1.3,
                          color: notification.isRead ? AppColors.textGrey : AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case NotificationType.approved:
        iconData = Icons.check_circle;
        backgroundColor = AppColors.success.withOpacity(0.1);
        iconColor = AppColors.success;
        break;
      case NotificationType.rejected:
        iconData = Icons.cancel;
        backgroundColor = AppColors.error.withOpacity(0.1);
        iconColor = AppColors.error;
        break;
      case NotificationType.comment:
        iconData = Icons.chat_bubble_outline;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        iconColor = AppColors.primary;
        break;
      case NotificationType.document:
        iconData = Icons.description_outlined;
        backgroundColor = AppColors.warning.withOpacity(0.1);
        iconColor = AppColors.warning.withOpacity(0.8);
        break;
      case NotificationType.general:
        iconData = Icons.notifications_outlined;
        backgroundColor = AppColors.lightGrey;
        iconColor = AppColors.greyColor;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
