import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator; // ✅ Add validator

  const CommonTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator, // ✅ Accept validator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField( // ✅ Changed from TextField
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // ✅ Apply validator
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        errorStyle: const TextStyle(color: Colors.red), // ✅ Better error styling
      ),
    );
  }
}
