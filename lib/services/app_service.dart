import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppService {
  static bool isLoading = false;
  static void showLoader({String message = 'Please wait...', bool barrierDismissible = false}) {
    isLoading = true;
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        )),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void hideLoader() {
    if (isLoading) Get.back();
    isLoading = false;
  }
}
