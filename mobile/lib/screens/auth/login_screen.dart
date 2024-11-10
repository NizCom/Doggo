import 'package:flutter/material.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/screens/bottom_menu.dart';
import 'package:mobile/screens/auth/signup_step1_screen.dart';
import 'package:mobile/common_widgets/round_button.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/common_widgets/round_textfield.dart';
import 'package:mobile/services/http_service.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/LoginScreen";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true; // State variable to track password visibility

  Future<void> _login() async {
    try {
      final response = await HttpService.login(
        _emailController.text,
        _passwordController.text,
      );
      print(response['user_id']);
      print(response['dog_id']);
      await PreferencesService.saveUserId(response['user_id']);
      await PreferencesService.saveDogId(response['dog_id']);

      if(mounted) {
        Navigator.pushNamed(context, BottomMenu.routeName);
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor1, AppColors.primaryColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                physics: constraints.maxHeight > 600 ? const NeverScrollableScrollPhysics() : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.15),
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 35,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 4.0,
                                    color: Color.fromARGB(128, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            RoundTextField(
                              textEditingController: _emailController,
                              hintText: "Email",
                              icon: 'assets/icons/message_icon.png',
                              textInputType: TextInputType.emailAddress,
                              isObscureText: false,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            RoundTextField(
                              textEditingController: _passwordController,
                              hintText: "Password",
                              icon: 'assets/icons/lock_icon.png',
                              textInputType: TextInputType.text,
                              isObscureText: _isPasswordObscured,
                              rightIcon: GestureDetector(
                                onTap: () {
                                  // Handle show/hide password
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                    _passwordController.text.isNotEmpty;
                                  });
                                },
                                child: const Icon(
                                  Icons.visibility,
                                  color: AppColors.grayColor,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.01),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            RoundButton(
                              title: "Login",
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login();
                                }
                              },
                              backgroundColor: AppColors.whiteColor,
                              titleColor: AppColors.secondaryColor1,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, SignUpStep1Screen.routeName);
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Don’t have an account yet? ",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Register now",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor1,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
