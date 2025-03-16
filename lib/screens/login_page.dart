import 'package:attendance_app/screens/about_us.dart';
import 'package:attendance_app/screens/home_screen.dart';
import 'package:attendance_app/screens/reset_pin_screen.dart';
import 'package:attendance_app/screens/signup_page.dart';
import 'package:attendance_app/services/app_service.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFirstTime = true;

  // Save email to SharedPreferences
  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
  }

  // Load saved email from SharedPreferences
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');

    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _isFirstTime = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "LOGIN TO MARK ATTENDANCE",
          style: TextStyle(
              letterSpacing: 1,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.only(top: 350, left: 40, right: 40),
            width: double.infinity,
            child: Image.asset(
              "assets/signup.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 50,
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
                                borderSide:
                                    const BorderSide(color: Colors.red)),
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
                            labelStyle: const TextStyle(
                                color: Colors.blue, fontSize: 12),
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
                          decoration: InputDecoration(
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    const BorderSide(color: Colors.red)),
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
                            labelStyle: const TextStyle(
                                color: Colors.blue, fontSize: 12),
                          ),
                        )),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 30, right: 30),
                      child: GestureDetector(
                        child: Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(1, 1.5),
                                    spreadRadius: 1)
                              ],
                              color: Theme.of(context).primaryColor,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(15)),
                          child: const Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: () async {
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
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
                  "Reset Your Pin",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Get.to(const ResetPinScreen());
                },
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              child: const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "About Developer",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
              onTap: () {
                Get.to(const AboutUs());
              },
            ),
          )
        ],
      ),
    );
  }
}
