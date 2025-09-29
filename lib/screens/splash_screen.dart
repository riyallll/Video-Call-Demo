import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/user_list');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.Background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_call, size: 100, color: AppColors.primaryColor),
            const SizedBox(height: 20),
            Text(
              AppStrings.splashTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

