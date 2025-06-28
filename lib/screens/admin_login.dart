import 'package:attendance_app/screens/dashboard_screen.dart';

import 'package:attendance_app/screens/reset_pin_screen.dart';
import 'package:attendance_app/services/app_service.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/user_model.dart';
import 'package:attendance_app/widgets/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLogin extends StatefulWidget {
  final String? refEmail;
  const AdminLogin({super.key, this.refEmail});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode _passwordFocusNode = FocusNode();
  bool _isFirstTime = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      AppService.showLoader(message: "Signing in...");
      UserModel? user = await AuthService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      AppService.hideLoader();
      if (user != null) {
        if (user.role == 'admin') {
          Get.offAll(const DashboardScreen());
        } else {
          AppService.showError(
              message: "Access restricted to administrators only.");
        }
      } else {
        AppService.showError(message: "Invalid credentials. Please try again.");
      }
    }
  }

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 33),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Administrator Login",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900))),
              ],
            ),
          ),
          const SizedBox(
            height: 1,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Divider(
              color: Colors.red.shade900,
              thickness: 3,
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
                  padding: const EdgeInsets.only(top: 15, left: 30, right: 30),

                  child: Mybutton(
                      buttonname: "LOGIN",
                      onPressed: () async {
                        await _login();
                      }),
                  // child: GestureDetector(
                  //   child: Container(
                  //     height: 45,
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Colors.grey.shade300,
                  //               offset: const Offset(1, 1.5),
                  //               spreadRadius: 1)
                  //         ],
                  //         color: Theme.of(context).primaryColor,
                  //         border: Border.all(color: Colors.red),
                  //         borderRadius: BorderRadius.circular(15)),
                  //     child: const Center(
                  //       child: Text(
                  //         "LOGIN",
                  //         style: TextStyle(
                  //             color: Colors.black, fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     await _login();
                  //   },
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
