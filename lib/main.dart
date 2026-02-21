import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/alert_provider.dart';
import 'presentation/providers/stats_provider.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/global_keys.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // If the message contains a notification or data that we want to turn into a loud alert
  debugPrint("Handling background: ${message.messageId}");
  
  // We can manually show a notification here to ensure it uses our 'sos_channel'
  final notification = message.notification;
  if (notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sos_channel',
      'Emergency SOS',
      channelDescription: 'Used for critical life-saving alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('loud_alarm'),
      ticker: 'ticker',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await FlutterLocalNotificationsPlugin().show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}

void main() async {
  debugPrint("App starting stage 1...");
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint("Initializing Firebase...");
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully.");
    } else {
      debugPrint("Firebase already initialized.");
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  debugPrint("Calling runApp...");
  runApp(const BlindnessGuardianApp());

  _setupFirebaseMessaging();
}

Future<void> _setupFirebaseMessaging() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission for critical alerts
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Create high-priority channel for Android with custom sound
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sos_channel', 
      'Emergency SOS',
      description: 'Used for critical life-saving alerts',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('loud_alarm'),
      enableVibration: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🚨 SOS Received in Foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
  } catch (e) {
    debugPrint("Error during messaging setup: $e");
  }
}

class BlindnessGuardianApp extends StatelessWidget {
  const BlindnessGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'Blindness Guardian',
        navigatorKey: navigatorKey,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (authProvider.isAuthenticated) {
      return const HomeDashboard();
    }
    
    return const LoginPage();
  }
}
