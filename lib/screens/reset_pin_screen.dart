import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_sender/email_sender.dart';
import 'package:flutter/material.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPinController = TextEditingController();
  int _generatedOTP = 1;
  bool _isOTPSent = false;
  // Step 2: Verify if user exists in Firebase Firestore by email
  Future<void> _verifyUserAndSendOTP() async {
    final email = _emailController.text.trim();

    try {
      // Query Firestore to check if the user exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Step 3: Send OTP to the user's email
        _generatedOTP = _generateOTP();
        EmailSender emailsender = EmailSender();
        var response = await emailsender.sendOtp(email, _generatedOTP);
        print(response);
        setState(() {
          _isOTPSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User does not exist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Generate a 6-digit OTP
  int _generateOTP() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000);
  }

  // Step 5: Match OTP and reset PIN
  Future<void> _verifyOTPAndResetPin() async {
    final otp = _otpController.text.trim();
    final newPin = _newPinController.text.trim();

    if (otp == _generatedOTP) {
      // Step 6: Update PIN in Firestore
      final email = _emailController.text.trim();

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userId = querySnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'pin': newPin});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating PIN: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          "REST PIN",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 250,
              width: 250,
              child: Image.asset("assets/resetpin.jpg"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.red)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.5)),
                  label: const Text(
                    "Enter Your Email",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                  prefixIcon: Icon(
                    size: 16,
                    Icons.email,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
              child: GestureDetector(
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(1, 1.5),
                            spreadRadius: 1)
                      ],
                      color: Theme.of(context).primaryColor,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
                    child: Text(
                      "Reset Pin",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: () {
                  print("Function Called");
                  _verifyUserAndSendOTP();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
