import 'package:attendance_app/screens/qr_scanner.dart';
import 'package:attendance_app/services/attendance_services.dart';

import 'package:attendance_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 40),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${formattedDate}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              child: Container(
                height: 200,
                width: double.infinity,
                child: Image.asset("Assets/confirm.jpg"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 300, left: 40, right: 40),
              child: GestureDetector(
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.deepOrange.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.deepOrange.shade400)),
                  child: const Center(
                    child: Text(
                      "Mark Attendance",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: () async {
                  // Verify location and mark attendance
                  bool isInPremises = await _locationService.isUserInPremises(
                    buildingLat,
                    buildingLong,
                    radiusInMeters,
                  );

                  if (isInPremises) {
                    await _attendanceService.markAttendance(
                      'userId', // Replace with actual user ID
                      DateTime.now(),
                      true,
                    );

                    const Text('Attendance marked successfully!');
                  } else {
                    const Text('You are not in the building premises.');
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 350, left: 40, right: 40),
              child: GestureDetector(
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.deepOrange.shade400)),
                  child: const Center(
                    child: Text(
                      "Scan QR Code",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: () async {
                  // Navigate to the QR code scanner screen
                  final scannedData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScanner()),
                  );
                  // Display the scanned data
                  if (scannedData != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned Data: $scannedData')),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 400, left: 40, right: 40),
              child: GestureDetector(
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black)),
                  child: const Center(
                    child: Text(
                      "View Your Record",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
