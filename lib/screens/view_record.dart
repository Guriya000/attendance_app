import 'package:attendance_app/attendance_record_model.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewRecord extends StatelessWidget {
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.getCurrentUser()?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Attendance Records'),
        ),
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _attendanceService.getAttendanceRecords(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No attendance records found.'));
          }

          final attendanceRecords = snapshot.data!.docs.map((doc) {
            return AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return ListTile(
                title: Text('Date: ${record.dateTime.toString()}'),
                subtitle: Text(
                    'Status: ${record.isInPremises ? "In Premises" : "Outside Premises"}'),
              );
            },
          );
        },
      ),
    );
  }
}
