import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/colors.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for text fields
    final nameController = TextEditingController();
    final emailController = TextEditingController(); // <-- Add emailController
    final passwordController = TextEditingController();

    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Copy of Welcome - 1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 60),
                  Image.asset('assets/logo.png', height: 100),
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
                            color: blue1,
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
                  buildTextField('Username', 'Enter your name',
                      controller: nameController),
                  SizedBox(height: 20),
                  buildTextField(
                      'Email', 'Enter your email', // <-- Change label
                      controller: emailController), // <-- Use emailController
                  SizedBox(height: 20),
                  buildTextField('Password', 'Enter your password',
                      controller: passwordController, obscureText: true),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                        text: 'Login',
                        onPressed: () {
                          BlocProvider.of<AuthCubit>(context).login(
                            name: nameController.text.trim(),
                            email: emailController.text
                                .trim(), // <-- Use emailController
                            password: passwordController.text.trim(),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        color: blue1,
                        fontSize: 18,
                        fontFamily: 'LeagueSpartanMedium',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function for text fields
Widget buildTextField(String label, String hint,
    {TextEditingController? controller, bool obscureText = false}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(),
    ),
  );
}
