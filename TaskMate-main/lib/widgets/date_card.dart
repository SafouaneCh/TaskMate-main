import 'package:flutter/material.dart';

class DateCard extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  DateCard({required this.day, required this.date, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? null : Color(0xFFFFFFFF),
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(0, 1),
            colors: [Color(0xFF074565), Color(0xFF0E7FB9)],
          )
              : null,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown, // S'assure que le texte ne dépasse pas
                child: Text(
                  day,
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: -0.4,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.0),
              FittedBox(
                fit: BoxFit.scaleDown, // S'assure que le texte ne dépasse pas
                child: Text(
                  date,
                  style: TextStyle(
                    height: 1.2,
                    letterSpacing: -0.4,
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
