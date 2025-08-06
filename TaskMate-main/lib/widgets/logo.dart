import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
