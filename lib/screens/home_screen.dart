import 'package:attendance_app/screens/login_page.dart';
import 'package:attendance_app/screens/qr_scanner.dart';
import 'package:attendance_app/services/app_service.dart';
import 'package:attendance_app/services/attendance_services.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
            "${DateFormat('yyyy-MM-dd').format(DateTime.now()) == DateFormat('yyyy-MM-dd').format(selectedDate!) ? "Mark Attendance" : "Attendance History"} (${DateFormat('MMM dd,yyyy').format(selectedDate!)})",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            if (AuthService.getCurrentUser()!.role == 'admin')
              IconButton(
                  onPressed: () async {
                    selectedDate = await showDatePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime.now(), currentDate: selectedDate);
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.purple,
                  )),
            IconButton(
                onPressed: () {
                  Get.to(() => ViewRecord());
                },
                icon: const Icon(
                  Icons.history,
                  color: Colors.blueAccent,
                )),
            IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Logout",
                    middleText: "Are you sure you want to logout?",
                    textCancel: "No",
                    textConfirm: "Yes",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      AuthService.currentLoginUser = null;
                      Get.offAll(() => const LoginPage());
                    },
                  );
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.red[900],
                ))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: AttendanceService.getTodaysPresentUsers(date: selectedDate),
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

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          const Text(
                            "",
                            style: const TextStyle(color: Colors.blue, fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Outside: ',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(
                                  text: attendanceRecords.where((element) => element.isInPremises == true).length.toString(),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                      Expanded(
                          child: Column(
                        children: [
                          Text(
                            attendanceRecords.length.toString(),
                            style: const TextStyle(color: Colors.blue, fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Total Present",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                      Expanded(
                          child: Column(
                        children: [
                          const Text(
                            "",
                            style: const TextStyle(color: Colors.blue, fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Inside: ',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(
                                  text: attendanceRecords.where((element) => element.isInPremises == true).length.toString(),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                    ],
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      AttendanceRecord attendanceRecord = attendanceRecords[index];
                      return FutureBuilder(
                          future: AuthService.getUserById(attendanceRecord.userId!),
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
                                    color: Colors.primaries[attendanceRecord.userId.hashCode % Colors.primaries.length],
                                    // color: Colors.blue,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Center(
                                  child: Text(
                                    "${name.split(' ').first[0]}${name.split(' ').length > 1 ? name.split(' ').last[0] : ""}",
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Status: ',
                                          style: DefaultTextStyle.of(context).style,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: attendanceRecord.isInPremises == true ? 'In-premises' : 'Outside-premises',
                                              style: TextStyle(
                                                color: attendanceRecord.isInPremises == true ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (attendanceRecord.className != null)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (attendanceRecord.className != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(color: Colors.primaries[attendanceRecord.className.hashCode % Colors.primaries.length], borderRadius: BorderRadius.circular(5)),
                                          child: Text(
                                            attendanceRecord.className.toString(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        )
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'At: ',
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: DateFormat('hh:mm:ss').format(attendanceRecord.dateTime!),
                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
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
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 5.0, // Distance from the bottom
              right: 5.0, // Distance from the right
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    // Get.to(() => QrScanner());
                    AppService.showLoader();
                    if (await AttendanceService.markAttendance(AuthService.getCurrentUser()!.id.toString())) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Attendance marked successfully!",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.green,
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
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  )),
            ),
            Positioned(
              bottom: 70.0, // Positioned above the first FAB
              right: 5.0, // Aligned with the first FAB
              child: FloatingActionButton(
                backgroundColor: Colors.blue[300],
                onPressed: () {
                  Get.to(() => QrScanner());
                },
                child: const Icon(
                  Icons.qr_code,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ));
  }
}
