import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance
  Future<void> markAttendance(
      String userId, DateTime dateTime, bool isInPremises) async {
    await _firestore.collection('attendance').add({
      'userId': userId,
      'dateTime': dateTime,
      'isInPremises': isInPremises,
    });
  }

  // Get attendance records for a user
  Stream<QuerySnapshot> getAttendanceRecords(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots();
  }
}
