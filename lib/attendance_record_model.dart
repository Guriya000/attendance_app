import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String userId;
  final String date;
  final String time;
  final DateTime dateTime;
  final bool isInPremises;

  AttendanceRecord({
    required this.userId,
    required this.dateTime,
    required this.date,
    required this.time,
    required this.isInPremises,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      userId: data['userId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isInPremises: data['isInPremises'],
      date: data['date'],
      time: data['time'],
    );
  }
}
