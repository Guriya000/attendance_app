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
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text(
            'Attendance Records',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text(
            'User not logged in.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          'Attendance Records',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          // IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Icons.calendar_month,
          //       color: Colors.purple,
          //     ))
        ],
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

          attendanceRecords.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

          return ListView.builder(
            itemCount: attendanceRecords.length,
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return ListTile(
                //tileColor: Colors.blue,
                title: RichText(
                  text: TextSpan(
                    text: 'Date: ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: record.dateTime.toString(),
                        style: TextStyle(
                          color: record.date == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? Colors.blue : Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    text: 'Status: ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: record.isInPremises == true ? 'In-premises' : 'Outside-premises',
                        style: TextStyle(
                          color: record.isInPremises == true ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
