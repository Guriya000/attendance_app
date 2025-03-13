import 'package:attendance_app/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  // Mark attendance
  static Future<bool> markAttendance() async {
    if (AuthService.getCurrentUser() != null) {
      DateTime now = DateTime.now();
      await _firestore.collection('attendance').add({
        'userId': AuthService.getCurrentUser()!.id.toString(),
        'dateTime': now,
        'date': DateFormat('dd-MM-yyyy').format(now),
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
    return _firestore.collection('attendance').where('userId', isEqualTo: userId).snapshots();
  }

  static Stream<QuerySnapshot> getTodaysPresentUsers() {
    return _firestore.collection('attendance').where('date', isEqualTo: DateFormat('dd-MM-yyyy').format(DateTime.now())).snapshots();
  }
}
