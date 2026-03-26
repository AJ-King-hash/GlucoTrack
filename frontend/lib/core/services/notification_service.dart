import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucotrack/core/api/api_service.dart';
import "package:glucotrack/firebase_options.dart";

/// Notification Service for GlucoTrack
///
/// Handles Firebase Cloud Messaging (FCM) for push notifications
/// and local notifications display.
class NotificationService {
  final ApiService _apiService;

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;

  // Callback for when a notification is received
  Function(Map<String, dynamic>)? onNotificationReceived;

  // Callback for when user taps on notification
  Function(Map<String, dynamic>)? onNotificationTapped;

  NotificationService(this._apiService);

  Future<void> registerFcmTokenAfterLogin() async {
    final token = await _messaging?.getToken();
    if (token != null) {
      await _apiService.updateFcmToken(token);
    }
  }

  /// Initialize Firebase and notification services
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Initialize local notifications
      _localNotifications = FlutterLocalNotificationsPlugin();
      await _initializeLocalNotifications();

      // Request notification permissions
      await _requestPermissions();

      // Get FCM token
      await _registerFcmToken();

      // Set up token refresh listener for when FCM token changes
      await refreshToken();

      // Set up foreground message handling
      _setupForegroundHandler();

      // Set up background message handling
      _setupBackgroundHandler();

      if (kDebugMode) {
        print('[NotificationService] Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Initialization error: $e');
      }
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications?.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request iOS permissions
    await _messaging?.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Request Android permissions (for Android 13+)
    await _localNotifications
        ?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Register FCM token with backend
  Future<void> _registerFcmToken() async {
    try {
      final token = await _messaging?.getToken();
      if (token != null) {
        await _apiService.updateFcmToken(token);
        if (kDebugMode) {
          print('[NotificationService] FCM token registered: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationService] Failed to register FCM token: $e');
      }
    }
  }

  /// Refresh FCM token (called when token changes)
  Future<void> refreshToken() async {
    _messaging?.onTokenRefresh.listen((token) async {
      await _apiService.updateFcmToken(token);
      if (kDebugMode) {
        print('[NotificationService] FCM token refreshed: $token');
      }
    });
  }

  /// Set up foreground message handler
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  /// Set up background message handler
  void _setupBackgroundHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
      if (onNotificationTapped != null && message.data.isNotEmpty) {
        onNotificationTapped!(message.data);
      }
    });
  }

  /// Handle incoming message
  void _handleMessage(RemoteMessage message) {
    // Show local notification for foreground messages
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification?.title ?? 'GlucoTrack',
        body: message.notification?.body ?? '',
        payload: message.data,
      );
    }

    // Call notification received callback
    if (onNotificationReceived != null && message.data.isNotEmpty) {
      onNotificationReceived!(message.data);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'glucotrack_reminders',
      'Reminders',
      channelDescription: 'Medicine and glucose check reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications?.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload != null ? jsonEncode(payload) : null,
    );

    // Also show toast for immediate feedback
    Fluttertoast.showToast(
      msg: body,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 4,
      backgroundColor: const Color.fromARGB(255, 76, 175, 80),
      textColor: const Color.fromARGB(255, 255, 255, 255),
      fontSize: 14.0,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (onNotificationTapped != null && response.payload != null) {
      // Parse JSON payload and call callback
      try {
        final decodedPayload =
            jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTapped!(decodedPayload);
      } catch (e) {
        // If parsing fails, pass as-is
        onNotificationTapped!({'payload': response.payload});
      }
    }
  }

  /// Update reminder settings
  Future<bool> updateReminders({
    String? glucoTime,
    String? medicineTime,
    String? timezone,
  }) async {
    final result = await _apiService.updateReminders(
      glucoTime: glucoTime,
      medicineTime: medicineTime,
      timezone: timezone,
    );

    return result.fold((failure) => false, (success) => true);
  }

  /// Trigger reminders manually (for testing)
  Future<bool> triggerReminders() async {
    final result = await _apiService.triggerReminders();

    return result.fold((failure) => false, (success) => true);
  }
}
