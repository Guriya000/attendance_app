import 'package:attendance_app/social_media_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "ABOUT US",
          style: TextStyle(
              letterSpacing: 1,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 100,
            width: 100,
            child: Image.asset("assets/check.png"),
          ),
          const SizedBox(height: 10),
          const Text(
            "PresentSir",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.red)),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Developer's Information Section",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 5),
                  child: Column(
                    children: [
                      Text(
                        "Name: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        "Laraib Azhar",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        "laraibazhar107@gmail.com",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 130,
                width: 130,
                child: Image.asset("assets/girl.PNG"),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SocialMediaButton(
                label: "GitHub",
                url: "https://github.com/dashboard",
                icon: Icons.g_mobiledata_rounded,
              ),
              SocialMediaButton(
                label: "LinkedIn",
                url: "https://www.linkedin.com/in/laraib-malik-020052322/",
                icon: Icons.link_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
