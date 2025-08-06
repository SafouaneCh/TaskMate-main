import 'package:flutter/material.dart';
import 'package:taskmate/widgets/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: blue1,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        minimumSize: Size(double.infinity, screenWidth * 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'LeagueSpartanMedium',
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
          color: yellow1,
        ),
      ),
    );
  }
}