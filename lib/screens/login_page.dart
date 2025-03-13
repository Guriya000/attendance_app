import 'package:attendance_app/screens/home_screen.dart';
import 'package:attendance_app/screens/signup_page.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 80, left: 10),
                  child: Text(
                    "LOGIN TO MARK ATTENDANCE",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 30, right: 30),
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 1.5)),
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
                          padding: const EdgeInsets.only(
                              top: 15, left: 30, right: 30),
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
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 1.5)),
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
                                color: Colors.blue.shade200,
                                border: Border.all(color: Colors.blue.shade500),
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
                              User? user = await _authService.signIn(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (user != null) {
                                Get.to(HomeScreen());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Login failed. Please try again.')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 400, left: 30, right: 30),
              child: Container(
                height: 200,
                width: double.infinity,
                child: Image.asset(
                  "assets/login.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
