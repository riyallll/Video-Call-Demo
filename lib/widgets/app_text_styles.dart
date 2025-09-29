import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: AppColors.error,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 13,
    color: AppColors.textLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
