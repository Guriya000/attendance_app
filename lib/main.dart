import 'package:attendance_app/screens/dashboard_screen.dart';
import 'package:attendance_app/screens/login_page.dart';
import 'package:attendance_app/screens/reset_pin_screen.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:email_otp/email_otp.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  AttendanceService.getAppSettings();
  EmailOTP.config(
    appName: 'PresentSir',
    otpType: OTPType.numeric,
    expiry: 30000,
    emailTheme: EmailTheme.v6,
    appEmail: 'heyy@presentsir.com',
    otpLength: 6,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PresentSir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme:
            const InputDecorationTheme(focusColor: Colors.red),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.grey.shade300,
        //  primaryColor: const Color.fromARGB(255, 224, 131, 97),
        secondaryHeaderColor: Colors.red.shade900,
      ),
      darkTheme: ThemeData.fallback(),
      themeMode: ThemeMode.system,
      home: LoginPage(), // Change this to your desired screen
    );
  }
}
