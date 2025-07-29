import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomBar({super.key, 
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomBarHeight = screenHeight * 0.1; // Réduire la hauteur

    return SafeArea(
      child: Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 0.0,
            child :SafeArea(
              child: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Flexible(
                      child: Icon(Icons.home ,size: 20), // Icone flexible
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Flexible(
                      child: Icon(Icons.calendar_today ,size: 20), // Icone flexible
                    ),
                    label: 'Calendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Flexible(
                      child: Icon(Icons.person ,size: 20), // Icone flexible
                    ),
                    label: 'Contacts',
                  ),
                  BottomNavigationBarItem(
                    icon: Flexible(
                      child: Icon(Icons.settings ,size: 20), // Icone flexible
                    ),
                    label: 'Settings',
                  ),
                ],
                currentIndex: selectedIndex,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.black,
                onTap: onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
              )


            ),

        ),
      ),
    );
  }
}
