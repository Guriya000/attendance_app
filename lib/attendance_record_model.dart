import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String userId;
  final DateTime dateTime;
  final bool isInPremises;

  AttendanceRecord({
    required this.userId,
    required this.dateTime,
    required this.isInPremises,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      userId: data['userId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isInPremises: data['isInPremises'],
    );
  }
}
