import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomBar2 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomBar2({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(13, 0, 18, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x40565656),
            offset: Offset(0, -10),
            blurRadius: 50,
          ),
        ],
      ),
      child: CustomBottomBarContent(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

class CustomBottomBarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomBarContent({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 19, 34.9, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centrer les icônes
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onItemTapped(0),
            child: SvgIcon(
              assetPath: 'assets/vectors/vector_x2.svg',
              width: 25,
              height: 22,
            ),
          ),
          SizedBox(width: 20), // Espace entre les icônes
          GestureDetector(
            onTap: () => onItemTapped(1),
            child: SvgIcon(
              assetPath: 'assets/vectors/group_3501_x2.svg',
              width: 22,
              height: 22,
            ),
          ),
          SizedBox(width: 120), // Espace entre les icônes
          GestureDetector(
            onTap: () => onItemTapped(2),
            child: SvgIcon(
              assetPath: 'assets/vectors/group_3602_x2.svg',
              width: 22,
              height: 22,
            ),
          ),
          SizedBox(width: 20), // Espace entre les icônes
          GestureDetector(
            onTap: () => onItemTapped(3),
            child: SvgIcon(
              assetPath: 'assets/vectors/vector_2_x2.svg',
              width: 20.1,
              height: 20,
              margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final EdgeInsets? margin;

  const SvgIcon({
    required this.assetPath,
    required this.width,
    required this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: SvgPicture.asset(assetPath),
    );
  }
}
