import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: MediaQuery.of(context).size.width / 2 - 27.5, // Centrer le bouton
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27.5),
          gradient: LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(0, 1),
            colors: <Color>[
              Color(0xFF074666),
              Color(0xFF0E81BD),
              Color(0xFFFFFFFF)
            ],
            stops: <double>[0, 1, 1],
          ),
        ),
        child: Container(
          width: 55,
          height: 55,
          padding: EdgeInsets.all(18.5),
          child: SvgPicture.asset(
            'assets/vectors/vector_7_x2.svg', // Assurez-vous que le chemin est correct
            width: 31,
            height: 31,
          ),
        ),
      ),
    );
  }
}
