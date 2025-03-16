import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../services/app_service.dart';
import '../services/attendance_services.dart';
import '../services/auth_services.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = 'Scan a QR code';
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      var json2 = json.decode(scanData.code!);
      if (json2.containsKey('class')) {
        controller.stopCamera();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Mark Attendance'),
              content: const Text('Do you want to mark attendance?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Get.back();
                    AppService.showLoader();
                    if (await AttendanceService.markAttendance(AuthService.getCurrentUser()!.id.toString(), json2['class'])) {
                      AppService.hideLoader();
                      Get.back();
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
                      AppService.hideLoader();
                      controller.resumeCamera();
                    }
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    controller.resumeCamera();
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      }
      // Navigate to another screen or perform an action with the scanned data
      // Navigator.pop(context, scannedData); // Return the scanned data to the previous screen
    });
  }

  @override
  void dispose() {
    // ignore: deprecated_member_use
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Mark Attendance by QR",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(scannedData),
            ),
          ),
        ],
      ),
    );
  }
}
