import 'package:flutter/material.dart';
import '../widgets/colors.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_widgets.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Copy of Welcome - 1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
    child: Center(
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Image.asset('assets/logo.png', height: 100), // Logo en haut
    SizedBox(height: 20),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: 'Create your own ',
              style: TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 55,
                color: blue1,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'life reminder',
              style: TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 55,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '!',
              style: TextStyle(
                fontFamily: 'LeagueSpartan',
                fontSize: 55,
                color:blue1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 20),
      Text(
        'Stay connected, stay organized',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'LeagueSpartanMedium',
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      SizedBox(height: 40),
      buildTextField('Username', 'Enter your name'),
      SizedBox(height: 20),
      buildTextField('Phone', 'Enter your phone number'),
      SizedBox(height: 20),
      buildTextField('Password', 'Enter your password'),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centre le contenu horizontalement
        children: [
          Checkbox(value: false, onChanged: (value) {}),
          Text(
            'Forgot password !',
            style: TextStyle(
              fontFamily: 'LeagueSpartan',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
        ],
      ),

            SizedBox(height: 20),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    ),
      ),
    );
  }
}
