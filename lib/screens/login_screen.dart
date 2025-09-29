import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call_demo/widgets/CommonTextField.dart';
import '../providers/user_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_strings.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@test.com');
  final _passwordController = TextEditingController(text: 'password');

  bool _loading = false;
  String? _error;

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ok = await userProvider.login(email, password);

    setState(() => _loading = false);

    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/user_list');
      }
    } else {
      setState(() {
        _error = AppStrings.loginFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 70, color: AppColors.primaryColor),
                const SizedBox(height: 16),
                Text(AppStrings.loginTitle, style: AppTextStyles.heading),
                const SizedBox(height: 30),
                CommonTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return AppStrings.enterValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CommonTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  obscureText: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordLengthError;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                if (_error != null)
                  Text(_error!, style: AppTextStyles.errorText),
                const SizedBox(height: 20),

                // 4. Login Button
                CustomButton(
                  text: AppStrings.loginButton,
                  isLoading: _loading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _onLogin();
                    }
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}