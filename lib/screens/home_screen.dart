import 'package:attendance_app/services/app_service.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../attendance_record_model.dart';
import 'view_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MMM dd,yyyy').format(DateTime.now());

  DateTime? selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "MARK ATTENDANCE ($formattedDate)",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => ViewRecord());
              },
              icon: const Icon(
                Icons.history,
                color: Colors.black,
              ))
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
              return AttendanceRecord.fromMap(
                  doc.data() as Map<String, dynamic>);
            }).toList();

            attendanceRecords
                .sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Text(
                          attendanceRecords.length.toString(),
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Total Present Today",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
                  ],
                ),
                Divider(
                  color: Theme.of(context).primaryColor,
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    AttendanceRecord attendanceRecord =
                        attendanceRecords[index];
                    return FutureBuilder(
                        future:
                            AuthService.getUserById(attendanceRecord.userId!),
                        builder: (context, snapshot) {
                          String name = attendanceRecord.userId!;
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
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 154, 16, 16),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Text(
                                  "${name.split(' ').first[0]}${name.split(' ').length > 1 ? name.split(' ').last[0] : ""}",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${attendanceRecord.isInPremises! ? "In-premises" : "Outside-premises"}',
                                  style: TextStyle(
                                      color: attendanceRecord.isInPremises!
                                          ? Colors.green
                                          : Colors.red),
                                ),
                                Text(
                                  DateFormat('hh:mm:ss')
                                      .format(attendanceRecord.dateTime!),
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
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
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            // Get.to(() => QrScanner());
            AppService.showLoader();
            if (await AttendanceService.markAttendance(
                AuthService.getCurrentUser()!.id.toString())) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  "Attendance marked successfully!",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Error marking attendance!",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ));
            }
            AppService.hideLoader();
          },
          label: const Text(
            "Mark Attendance",
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    );
  }
}
