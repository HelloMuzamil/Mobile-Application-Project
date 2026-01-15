import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _reminderChannel =
      AndroidNotificationChannel(
    'birthday_reminders',
    'Birthday Reminders',
    description: 'Notifications for upcoming birthdays',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel _birthdayChannel =
      AndroidNotificationChannel(
    'birthday_today',
    'Birthday Today',
    description: 'Notifications for birthdays happening today',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// ✅ INITIALIZE NOTIFICATIONS
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_reminderChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_birthdayChannel);

    await _requestPermissions();
  }

  /// ✅ PERMISSION REQUEST
  static Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// ✅ NOTIFICATION TAP HANDLER - YEH FIX KIYA GAYA HAI
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    
    // ✅ ACTION BUTTON CHECK (Android)
    if (response.actionId == 'send_wishes') {
      if (payload != null) {
        final parts = payload.split('|');
        if (parts.length >= 4) {
          final phone = parts[2];
          final templateId = parts[1];
          final name = parts[3];
          _sendBirthdayMessage(phone, templateId, name);
        }
      }
      return;
    }
    
    // ✅ NORMAL TAP (notification body tap)
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length >= 4) {
        final phone = parts[2];
        final templateId = parts[1];
        final name = parts[3];
        _sendBirthdayMessage(phone, templateId, name);
      }
    }
  }

  /// ✅ CHECK AND SCHEDULE NOTIFICATIONS
  static Future<void> checkAndScheduleNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final birthdaysSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('birthdays')
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var doc in birthdaysSnapshot.docs) {
        final data = doc.data();
        final dobTimestamp = data['dob'] as Timestamp?;
        final name = data['name'] as String? ?? 'Friend';
        final phone = data['phone'] as String? ?? '';
        final templateId = data['selectedTemplateId'] as String?;

        if (dobTimestamp == null) continue;

        final dob = dobTimestamp.toDate();
        DateTime thisBirthday = DateTime(now.year, dob.month, dob.day);
        
        if (thisBirthday.isBefore(today)) {
          thisBirthday = DateTime(now.year + 1, dob.month, dob.day);
        }

        final daysUntilBirthday = thisBirthday.difference(today).inDays;

        // ✅ 1 DAY BEFORE - REMINDER
        if (daysUntilBirthday == 1) {
          await _scheduleReminderNotification(
            doc.id,
            name,
            thisBirthday,
          );
        }

        // ✅ BIRTHDAY DAY - 12 AM (MIDNIGHT)
        if (daysUntilBirthday == 0) {
          await _scheduleBirthdayNotification(
            doc.id,
            name,
            phone,
            templateId,
            thisBirthday,
          );
        }
      }
    } catch (e) {
      print("❌ Notification Error: $e");
    }
  }

  /// ✅ REMINDER NOTIFICATION (1 day before)
  static Future<void> _scheduleReminderNotification(
    String birthdayId,
    String name,
    DateTime birthdayDate,
  ) async {
    final notificationId = birthdayId.hashCode;

    await _notifications.show(
      notificationId,
      '🎂 Tomorrow is $name\'s Birthday!',
      'Don\'t forget to wish $name tomorrow!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          channelDescription: _reminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// ✅ BIRTHDAY NOTIFICATION (on birthday at 12 AM)
  static Future<void> _scheduleBirthdayNotification(
    String birthdayId,
    String name,
    String phone,
    String? templateId,
    DateTime birthdayDate,
  ) async {
    final notificationId = birthdayId.hashCode + 1000;
    final payload = '$birthdayId|$templateId|$phone|$name';

    await _notifications.show(
      notificationId,
      '🎉 Happy Birthday $name!',
      'Tap to send birthday wishes via WhatsApp',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _birthdayChannel.id,
          _birthdayChannel.name,
          channelDescription: _birthdayChannel.description,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          actions: [
            const AndroidNotificationAction(
              'send_wishes',
              'Send Wishes 🎂',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// ✅ SEND BIRTHDAY MESSAGE VIA WHATSAPP - FIXED
  static Future<void> _sendBirthdayMessage(
      String phone, String? templateId, String name) async {
    try {
      String message = "Happy Birthday $name! 🎉🎂";

      // ✅ Template text fetch karo agar selected hai
      if (templateId != null && templateId.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final templateDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('templates')
                .doc(templateId)
                .get();

            if (templateDoc.exists) {
              final templateText = templateDoc.data()?['text'];
              if (templateText != null && templateText.isNotEmpty) {
                message = templateText;
              }
            }
          } catch (e) {
            print("⚠️ Template fetch error: $e");
          }
        }
      }

      // ✅ Phone number clean karo (+ sign ko encode karna zaroori hai)
      String cleanPhone = phone.trim();
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+$cleanPhone';
      }

      // ✅ WhatsApp URL banao
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

      print("✅ Opening WhatsApp: $whatsappUrl");

      // ✅ WhatsApp launch karo
      if (await canLaunchUrl(whatsappUrl)) {
        final launched = await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          print("❌ Failed to launch WhatsApp");
        }
      } else {
        print("❌ Cannot launch WhatsApp URL");
      }
    } catch (e) {
      print("❌ WhatsApp Error: $e");
    }
  }

  /// ✅ CANCEL ALL NOTIFICATIONS
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// ✅ CANCEL SPECIFIC NOTIFICATION
  static Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }
}