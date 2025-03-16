import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final String url;
  final String? iconImage;
  final bool isEmail;
  const SocialMediaButton(
      {super.key,
      this.icon,
      required this.label,
      required this.url,
      this.iconImage,
      this.isEmail = false});

  @override
  State<SocialMediaButton> createState() => _SocialMediaButtonState();
}

class _SocialMediaButtonState extends State<SocialMediaButton> {
  Future<void> _launchURL(String url, bool isEmail) async {
    final Uri uri = isEmail ? Uri.parse('mailto:$url') : Uri.parse(url);
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text(
                'Could not launch $url',
                style: const TextStyle(color: Colors.black),
              )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.black),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchURL(widget.url, widget.isEmail);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.iconImage != null)
            Image.asset(
              widget.iconImage!,
              width: 30,
              height: 30,
            ),
          if (widget.icon != null)
            Icon(widget.icon, size: 30, color: Colors.red.shade800),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: const TextStyle(
                fontSize: 17, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
