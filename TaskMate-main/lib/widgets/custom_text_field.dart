import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const CustomTextField({super.key, required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

final TextStyle selectedTextStyle = TextStyle(
  fontFamily: 'LeagueSpartanMedium',
  fontWeight: FontWeight.bold,
  fontSize: 16,
  height: 1.2,
  letterSpacing: -0.4,
  color: Colors.white,
);

final TextStyle unselectedTextStyle = TextStyle(
  fontFamily: 'LeagueSpartanMedium',
  fontSize: 14,
  height: 1.2,
  letterSpacing: -0.4,
  color: Colors.black,
);
