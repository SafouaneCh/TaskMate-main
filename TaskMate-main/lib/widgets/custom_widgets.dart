import 'package:flutter/material.dart';

Widget buildTextField(String label, String hint) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: 'LeagueSpartanMedium',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200]?.withOpacity(0.7) ?? Colors.grey.withOpacity(0.7), // Utilisez une valeur par défaut si Colors.grey[200] est null
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
