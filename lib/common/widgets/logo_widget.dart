// lib/common/widgets/logo_widget.dart
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.construction, // use your brand logo here
          color: Colors.white,
          size: 80,
        ),
        const SizedBox(height: 20),
        const Text(
          "SeamlessCall",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
