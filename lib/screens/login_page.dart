import 'package:attendance_app/main.dart';
import 'package:attendance_app/screens/admin_login.dart';

import 'package:attendance_app/screens/home_screen.dart';
import 'package:attendance_app/screens/reset_pin_screen.dart';
import 'package:attendance_app/screens/signup_page.dart';
import 'package:attendance_app/services/app_service.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/user_model.dart';
import 'package:attendance_app/widgets/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String? refEmail;
  const LoginPage({super.key, this.refEmail});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode _passwordFocusNode = FocusNode();
  bool _isFirstTime = true;

  Future<void> _loadSavedEmail() async {
    String? savedEmail = AuthService.getEmail();
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _isFirstTime = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      _passwordFocusNode.requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.refEmail != null) {
      _emailController.text = widget.refEmail.toString();
    } else {
      _loadSavedEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 120,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Back!",
                          style: GoogleFonts.lato(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade900)),
                      Text("Glad to see you again!",
                          style: GoogleFonts.lato(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 30, right: 30),
                      child: TextFormField(
                        controller: _emailController,
                        onFieldSubmitted: (value) {
                          if (_isFirstTime) {
                            _loadSavedEmail();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.5)),
                          label: const Text("Enter Email"),
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            size: 16,
                            Icons.email,
                            color: Colors.red.shade900,
                          ),
                          labelStyle:
                              const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      )),
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 30, right: 30),
                      child: TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your pin';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        focusNode: _passwordFocusNode,
                        maxLength: 4,
                        onChanged: (value) {
                          if (value.length == 4) {
                            _login();
                          }
                        },
                        onEditingComplete: () async {
                          _login();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.red, width: 1.5)),
                          label: const Text("Enter Pin"),
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            size: 16,
                            Icons.password,
                            color: Colors.red.shade900,
                          ),
                          labelStyle:
                              const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Row(
                      children: [
                        const Text(
                          "Forget Pin?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Text("Reset Pin",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                  fontSize: 14)),
                          onTap: () {
                            Get.to(const ResetPinScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 30, right: 30),
                      child: Mybutton(
                        buttonname: "LOGIN",
                        onPressed: _login,
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  child: Text(
                    "SIGNUP",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700),
                  ),
                  onTap: () {
                    Get.to(const SignupPage());
                  },
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: const Text(
                "Admin Panel",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              onTap: () {
                Get.to(const AdminLogin());
              },
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      AppService.showLoader(message: "Signing in...");
      UserModel? user = await AuthService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      AppService.hideLoader();
      if (user != null) {
        Get.offAll(const HomeScreen());
      }
    }
  }
}
