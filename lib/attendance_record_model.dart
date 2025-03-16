import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  String? userId;
  String? date;
  String? time;
  DateTime? dateTime;
  bool? isInPremises;
  String? className;

  AttendanceRecord({this.userId, this.dateTime, this.date, this.time, this.isInPremises, this.className});

  factory AttendanceRecord.fromMap(Map<String, dynamic> data) {
    return AttendanceRecord(
      userId: data['userId'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isInPremises: data['isInPremises'],
      date: data.containsKey('date') ? data['date'] : null,
      time: data.containsKey('time') ? data['time'] : null,
      className: data.containsKey('class') ? data['class'] : null,
    );
  }
}
