import 'package:attendance_app/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../user_model.dart';

class AuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static UserModel? currentLoginUser;

  // Sign up with email and password
  static Future<UserModel?> signUp(UserModel userModel) async {
    try {
      await _firestore.collection('users').add(userModel.toJson()).then((userData) {
        print(userData);
        userModel.id = userData.id;
        currentLoginUser = userModel;
        return currentLoginUser;
      });
    } catch (e) {
      print("Error during signup: $e");
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserModel?> signIn(String email, String pincode) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).where('pincode', isEqualTo: pincode).get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        userData['id'] = querySnapshot.docs.first.id;
        currentLoginUser = UserModel.fromJson(userData);
        return currentLoginUser;
      } else {
        // Hide the existing snackbar if any
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

        // Show a snackbar with an error message
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("No user found with the provided email and pincode."),
          ),
        );
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    currentLoginUser = null;
    Get.offAll(() => const LoginPage());
  }

  // Get current user
  static UserModel? getCurrentUser() {
    return currentLoginUser;
  }

  // Get user by ID
  static Future<UserModel?> getUserById(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc(id).get();

      if (documentSnapshot.exists) {
        var userData = documentSnapshot.data() as Map<String, dynamic>;
        userData['id'] = documentSnapshot.id;
        return UserModel.fromJson(userData);
      } else {
        print("No user found with the provided ID.");
        return null;
      }
    } catch (e) {
      print("Error fetching user by ID: $e");
      return null;
    }
  }
}
