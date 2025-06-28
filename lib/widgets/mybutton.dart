import 'dart:math';

import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final String buttonname;
  final VoidCallback? onPressed;

  const Mybutton({super.key, required this.buttonname, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900,
            Colors.blue,
            Color.fromARGB(255, 224, 131, 97)
          ],
          transform: GradientRotation(pi / 90),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonname,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
