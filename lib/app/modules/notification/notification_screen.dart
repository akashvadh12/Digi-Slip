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
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError && controller.notifications.isEmpty) {
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
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.unreadCount.value > 99 
                      ? '99+' 
                      : '${controller.unreadCount.value}',
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
                  onPressed: controller.isLoading.value 
                      ? null 
                      : () => controller.markAllAsRead(),
                  child: Text(
                    'Mark all',
                    style: AppTextStyles.linkText.copyWith(
                      color: controller.isLoading.value 
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                    ),
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
              case 'stats':
                _showNotificationStats(controller);
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
              value: 'stats',
              child: Row(
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 8),
                  Text('Statistics'),
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
            onPressed: () => controller.retryLoading(),
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
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsController controller) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationCard(notification, controller);
          },
        ),
        // Loading overlay when performing operations
        Obx(() {
          if (controller.isLoading.value && controller.notifications.isNotEmpty) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              controller.markAsRead(notification.id);
            }
            _handleNotificationTap(notification);
          },
          onLongPress: () => _showNotificationOptions(notification, controller),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead 
                  ? AppColors.cardBackground 
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: notification.isRead 
                  ? Border.all(color: AppColors.borderColor, width: 1)
                  : Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: notification.isRead 
                      ? AppColors.greyColor.withOpacity(0.05)
                      : AppColors.primary.withOpacity(0.1),
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
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w700,
                                color: AppColors.blackColor,
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
                                style: AppTextStyles.caption.copyWith(
                                  color: notification.isRead 
                                      ? AppColors.textGrey 
                                      : AppColors.primary,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.normal 
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.description,
                        style: AppTextStyles.body.copyWith(
                          height: 1.4,
                          color: notification.isRead 
                              ? AppColors.textGrey 
                              : AppColors.greyColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.metadata != null && 
                          notification.metadata!.containsKey('leaveId'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(notification.type).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Leave Request',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(notification.type),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
        backgroundColor = AppColors.success.withOpacity(0.15);
        iconColor = AppColors.success;
        break;
      case NotificationType.rejected:
        iconData = Icons.cancel;
        backgroundColor = AppColors.error.withOpacity(0.15);
        iconColor = AppColors.error;
        break;
      case NotificationType.comment:
        iconData = Icons.chat_bubble_outline;
        backgroundColor = AppColors.primary.withOpacity(0.15);
        iconColor = AppColors.primary;
        break;
      case NotificationType.document:
        iconData = Icons.description_outlined;
        backgroundColor = AppColors.warning.withOpacity(0.15);
        iconColor = AppColors.warning;
        break;
      case NotificationType.general:
        iconData = Icons.notifications_outlined;
        backgroundColor = AppColors.lightGrey;
        iconColor = AppColors.greyColor;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }

  Color _getStatusColor(NotificationType type) {
    switch (type) {
      case NotificationType.approved:
        return AppColors.success;
      case NotificationType.rejected:
        return AppColors.error;
      case NotificationType.comment:
        return AppColors.primary;
      case NotificationType.document:
        return AppColors.warning;
      case NotificationType.general:
        return AppColors.greyColor;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification metadata
    if (notification.metadata != null) {
      final leaveId = notification.metadata!['leaveId'] as String?;
      final documentId = notification.metadata!['documentId'] as String?;
      
      if (leaveId != null) {
        // Navigate to leave details
        // Get.toNamed('/leave-details', arguments: leaveId);
        Get.snackbar('Navigation', 'Opening leave details: $leaveId');
      } else if (documentId != null) {
        // Navigate to document details
        // Get.toNamed('/document-details', arguments: documentId);
        Get.snackbar('Navigation', 'Opening document: $documentId');
      }
    }
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
                leading: Icon(Icons.mark_email_read, color: AppColors.primary),
                title: const Text('Mark as Read'),
                onTap: () {
                  Get.back();
                  controller.markAsRead(notification.id);
                },
              ),
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: const Text('View Details'),
              onTap: () {
                Get.back();
                _showNotificationDetails(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(notification, controller);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.description),
              const SizedBox(height: 16),
              Text('Type: ${notification.type.toString().split('.').last}'),
              Text('Time: ${notification.time}'),
              Text('Status: ${notification.isRead ? "Read" : "Unread"}'),
              if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Additional Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...notification.metadata!.entries.map(
                  (entry) => Text('${entry.key}: ${entry.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(NotificationModel notification, NotificationsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Are you sure you want to delete "${notification.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteNotification(notification.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
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

  void _showNotificationStats(NotificationsController controller) {
    final stats = controller.notificationStats;
    final totalNotifications = controller.notifications.length;
    final recentNotifications = controller.recentNotifications.length;

    Get.dialog(
      AlertDialog(
        title: const Text('Notification Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Notifications: $totalNotifications'),
              Text('Unread: ${controller.unreadCount.value}'),
              Text('Recent (7 days): $recentNotifications'),
              const SizedBox(height: 16),
              const Text('By Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...stats.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}