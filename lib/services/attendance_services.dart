import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance
  static Future<bool> markAttendance(String userId) async {
    if (AuthService.getCurrentUser() != null) {
      DateTime now = DateTime.now();
      await _firestore.collection('attendance').add({
        'userId': AuthService.getCurrentUser()!.id.toString(),
        'dateTime': now,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('hh:mm:ss').format(now),
        'isInPremises': false,
      });
      return true;
    } else {
      return false;
    }
  }

  // Get attendance records for a user
  static Stream<QuerySnapshot> getAttendanceRecords(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  static Stream<QuerySnapshot> getTodaysPresentUsers() {
    return _firestore
        .collection('attendance')
        .where('date',
            isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .snapshots();
  }

  static Future<void> markAttendanceWithLocation(String userId) async {
    if (AuthService.getCurrentUser() != null) {
      DateTime now = DateTime.now();
      LocationService locationService = LocationService();
      bool isInPremises =
          await locationService.isUserInPremises(33.261568, 73.305751, 100);
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
