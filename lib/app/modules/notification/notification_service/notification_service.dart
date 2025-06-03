import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:digislips/app/modules/notification/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _notificationsCollection = 'notifications';
  static const String _userTokensCollection = 'user_tokens';

  // Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Request permission for notifications
    await _requestPermission();
    
    // Get and store FCM token
    await _setupFCMToken();
    
    // Set up message handlers
    _setupMessageHandlers();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _setupFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
    } catch (e) {
      print('Error setting up FCM token: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid');
      
      if (userId != null) {
        await _firestore.collection(_userTokensCollection).doc(userId).set({
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    
    // Handle notification tap when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification for foreground messages
    await _showLocalNotification(message);
    
    // Create notification in Firestore if it doesn't exist
    await _createNotificationFromRemoteMessage(message);
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    // Handle navigation based on notification data
    _handleNotificationNavigation(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'digislips_notifications',
      'DigiSlips Notifications',
      channelDescription: 'Notifications for DigiSlips app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implement navigation logic based on notification data
    // Example: Navigate to specific screen based on notification type
    final type = data['type'];
    final id = data['id'];
    
    switch (type) {
      case 'leave_status':
        // Navigate to leave details screen
        break;
      case 'document':
        // Navigate to document screen
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  Future<void> _createNotificationFromRemoteMessage(RemoteMessage message) async {
    try {
      final userId = message.data['userId'];
      if (userId != null) {
        final notification = NotificationModel(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          title: message.notification?.title ?? message.data['title'] ?? 'New Notification',
          description: message.notification?.body ?? message.data['body'] ?? '',
          createdAt: DateTime.now(),
          type: _parseNotificationType(message.data['type']),
          isRead: false,
          metadata: message.data,
        );

        await _firestore
            .collection(_notificationsCollection)
            .doc(notification.id)
            .set(notification.toMap());
      }
    } catch (e) {
      print('Error creating notification from remote message: $e');
    }
  }

  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'approved':
        return NotificationType.approved;
      case 'rejected':
        return NotificationType.rejected;
      case 'comment':
        return NotificationType.comment;
      case 'document':
        return NotificationType.document;
      default:
        return NotificationType.general;
    }
  }

  // Get user notifications stream
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Get unread notification count stream
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Delete old notifications (older than 30 days)
  Future<void> deleteOldNotifications(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final batch = _firestore.batch();
      
      final querySnapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete old notifications: $e');
    }
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String description,
    required NotificationType type,
    Map<String, dynamic>? metadata,
    bool sendPushNotification = true,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        type: type,
        isRead: false,
        metadata: metadata,
      );

      // Save to Firestore
      await _firestore
          .collection(_notificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());

      // Send push notification if requested
      if (sendPushNotification) {
        await _sendPushNotification(
          userId: userId,
          title: title,
          body: description,
          data: {
            'type': type.toString().split('.').last,
            'notificationId': notification.id,
            'userId': userId,
            ...?metadata,
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Create leave status notification
  Future<void> createLeaveStatusNotification({
    required String userId,
    required String status,
    required String leaveId,
    required DateTime fromDate,
    required DateTime toDate,
    String? reviewComments,
  }) async {
    final title = 'Leave Request ${status.toUpperCase()}';
    final description = reviewComments != null
        ? 'Your leave request from ${_formatDate(fromDate)} to ${_formatDate(toDate)} has been $status. Comment: $reviewComments'
        : 'Your leave request from ${_formatDate(fromDate)} to ${_formatDate(toDate)} has been $status.';

    final type = status.toLowerCase() == 'approved'
        ? NotificationType.approved
        : NotificationType.rejected;

    await createNotification(
      userId: userId,
      title: title,
      description: description,
      type: type,
      metadata: {
        'leaveId': leaveId,
        'status': status,
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'reviewComments': reviewComments,
      },
    );
  }

  // Send push notification to specific user
  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final tokenDoc = await _firestore
          .collection(_userTokensCollection)
          .doc(userId)
          .get();

      if (!tokenDoc.exists) {
        print('No FCM token found for user: $userId');
        return;
      }

      final token = tokenDoc.data()?['token'] as String?;
      if (token == null) {
        print('FCM token is null for user: $userId');
        return;
      }

      // Send notification via FCM
      await _sendFCMNotification(
        token: token,
        title: title,
        body: body,
        data: data ?? {},
      );
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  // Send FCM notification using HTTP API
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      const String serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'data': data,
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('FCM notification sent successfully');
      } else {
        print('Failed to send FCM notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Clean up resources
  void dispose() {
    // Cancel any active subscriptions if needed
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message processing here
}