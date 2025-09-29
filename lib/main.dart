import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call_demo/providers/user_provider.dart';
import 'package:video_call_demo/screens/login_screen.dart';
import 'package:video_call_demo/screens/splash_screen.dart';
import 'package:video_call_demo/screens/user_list_screen.dart';
import 'package:video_call_demo/screens/video_call_screen.dart';
import 'package:video_call_demo/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pushService = PushNotificationService();
  await pushService.initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Call App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/user_list': (context) => const UserListScreen(),
        '/video_call': (context) => const VideoCallScreen(),
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
