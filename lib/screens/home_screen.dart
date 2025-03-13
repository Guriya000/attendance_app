import 'package:attendance_app/screens/qr_scanner.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:attendance_app/services/auth_services.dart';

import 'package:attendance_app/services/location_service.dart';
import 'package:attendance_app/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';

import '../attendance_record_model.dart';
import 'view_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// Get the current date
  DateTime now = DateTime.now();

  // Format the date using the intl package
  String formattedDate = DateFormat('MMM dd,yyyy').format(DateTime.now());

  // final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final AttendanceService _attendanceService = AttendanceService();
  final double buildingLat = 37.7749; // Example: San Francisco latitude
  final double buildingLong = -122.4194;
  final double radiusInMeters = 100; // 100 meters radius

  RxInt totalPresent = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "MARK ATTENDANCE ($formattedDate)",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => ViewRecord());
              },
              icon: const Icon(Icons.history))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: AttendanceService.getTodaysPresentUsers(),
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

            attendanceRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Text(
                          attendanceRecords.length.toString(),
                          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Total Present Today",
                          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
                  ],
                ),
                const Divider(),
                Expanded(
                    child: ListView.builder(
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    AttendanceRecord attendanceRecord = attendanceRecords[index];
                    return FutureBuilder(
                        future: AuthService.getUserById(attendanceRecord.userId),
                        builder: (context, snapshot) {
                          String name = attendanceRecord.userId;
                          if (snapshot.hasData) {
                            UserModel? user = snapshot.data;
                            if (user != null) {
                              name = user.name.toString();
                            }
                          }
                          return ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Text(
                                  "${name.split(' ').first[0]}${name.split(' ').length > 1 ? name.split(' ').last[0] : ""}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            title: Text(name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${attendanceRecord.isInPremises ? "In Premises" : "Outside Premises"}'),
                                Text(
                                  DateFormat('hh:mm:ss').format(attendanceRecord.dateTime),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                )),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          onPressed: () async {
            // Get.to(() => QrScanner());
            if (await AttendanceService.markAttendance()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Attendance marked successfully!"),
                backgroundColor: Colors.green,
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Error marking attendance!"),
                backgroundColor: Colors.red,
              ));
            }
          },
          label: const Text(
            "Mark Attendance",
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
    );
  }
}
