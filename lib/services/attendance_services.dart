import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static double checkLatitude = 0;
  static double checkLongitude = 0;
  static double checkMeter = 0;

  // Mark attendance
  static Future<bool> markAttendance(String userId) async {
    // double latitude = 33.418816;
    // double longitude = 73.223078;

    if (AuthService.getCurrentUser() != null) {
      if (await hasMarkedAttendanceToday(AuthService.getCurrentUser()!.id.toString()) && false) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
            "You have already marked your attendance for today!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
        return false;
      }
      bool isUserInPremises = await LocationService.isUserInPremises(checkLatitude, checkLongitude, checkMeter);
      DateTime now = DateTime.now();
      await _firestore.collection('attendance').add({
        'userId': AuthService.getCurrentUser()!.id.toString(),
        'dateTime': now,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('hh:mm:ss').format(now),
        'isInPremises': isUserInPremises,
      });
      return true;
    } else {
      return false;
    }
  }

  // Get attendance records for a user
  static Stream<QuerySnapshot> getAttendanceRecords(String userId) {
    return _firestore.collection('attendance').where('userId', isEqualTo: userId).snapshots();
  }

  static Future<bool> hasMarkedAttendanceToday(String userId) async {
    DateTime now = DateTime.now();
    QuerySnapshot querySnapshot = await _firestore.collection('attendance').where('userId', isEqualTo: userId).where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(now)).get();

    return querySnapshot.docs.isNotEmpty;
  }

  static Future<void> getAppSettings() async {
    QuerySnapshot querySnapshot = await _firestore.collection('app_settings').get();
    if (querySnapshot.docs.isNotEmpty) {
      checkLatitude = (querySnapshot.docs.first.data() as Map<String, dynamic>)['check_latitude'] as double;
      checkLongitude = (querySnapshot.docs.first.data() as Map<String, dynamic>)['check_longitude'] as double;
      checkMeter = (querySnapshot.docs.first.data() as Map<String, dynamic>)['check_meter'] as double;
      print(querySnapshot.docs.first.data());
    } else {
      return null;
    }
  }

  static Stream<QuerySnapshot> getTodaysPresentUsers() {
    return _firestore.collection('attendance').where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now())).snapshots();
  }

  static Future<void> markAttendanceWithLocation(String userId) async {
    if (AuthService.getCurrentUser() != null) {
      DateTime now = DateTime.now();
      LocationService locationService = LocationService();
      bool isInPremises = await LocationService.isUserInPremises(33.261568, 73.305751, 100);
      await _firestore.collection('attendance').add({
        'userId': AuthService.getCurrentUser()!.id.toString(),
        'dateTime': now,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('hh:mm:ss').format(now),
        'isInPremises': isInPremises,
      });
    }
  }
}
