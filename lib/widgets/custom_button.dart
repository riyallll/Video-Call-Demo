import 'package:flutter/material.dart';
import 'package:video_call_demo/widgets/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.primaryColor,
          elevation: 4,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ?  CircularProgressIndicator(color: Colors.white)
            : Text(text, style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:AppColors.Background )),
      ),
    );
  }
}
