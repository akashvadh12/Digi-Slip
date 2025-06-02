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

        if (controller.hasError) {
          return _buildErrorState(controller);
        }

        if (!controller.hasNotifications) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshNotifications();
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
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Notifications',
            style: AppTextStyles.welcomeTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${controller.unreadCount.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          return controller.hasUnreadNotifications
              ? TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: Text(
                    'Mark all',
                    style: AppTextStyles.linkText.copyWith(color: Colors.white),
                  ),
                )
              : const SizedBox();
        }),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'cleanup':
                _showCleanupDialog(controller);
                break;
              case 'refresh':
                controller.refreshNotifications();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cleanup',
              child: Row(
                children: [
                  Icon(Icons.cleaning_services),
                  SizedBox(width: 8),
                  Text('Cleanup Old'),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildErrorState(NotificationsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refreshNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
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
          onLongPress: () => _showNotificationOptions(notification, controller),
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

  void _showNotificationOptions(NotificationModel notification, NotificationsController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notification Options',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 20),
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Mark as Read'),
                onTap: () {
                  Get.back();
                  controller.markAsRead(notification.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                controller.deleteNotification(notification.id);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCleanupDialog(NotificationsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cleanup Old Notifications'),
        content: const Text('This will delete notifications older than 30 days. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cleanupOldNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }
}