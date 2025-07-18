import 'package:flutter/material.dart';
import 'package:taskmate/widgets/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: blue1, // Couleur de fond du bouton

      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'LeagueSpartanMedium', // Police personnalisée
          fontSize: 28, // Taille de la police
          fontWeight: FontWeight.bold, // Épaisseur de la police
          color: yellow1, // Couleur du texte
        ),
      ),
    );
  }
}