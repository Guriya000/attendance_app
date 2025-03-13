import 'package:attendance_app/attendance_record_model.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = AuthService.getCurrentUser()?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Records'),
        ),
        body: const Center(
          child: Text('User not logged in.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AttendanceService.getAttendanceRecords(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          final attendanceRecords = snapshot.data!.docs.map((doc) {
            return AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return ListTile(
                title: Text(
                  'Date: ${record.dateTime.toString()}',
                  style: TextStyle(color: record.date == DateFormat('dd-MM-yyyy').format(DateTime.now()) ? Colors.green.shade800 : null),
                ),
                subtitle: Text('Status: ${record.isInPremises ? "In-Premises" : "Outside-Premises"}'),
              );
            },
          );
        },
      ),
    );
  }
}
