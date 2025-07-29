import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/cubit/auth_cubit.dart';

Widget buildTextField(String label, String hint,
    {TextEditingController? controller, bool obscureText = false}) {
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
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200]?.withOpacity(0.7) ??
              Colors.grey.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}

class LoginPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextField('Name', 'Enter your name',
                controller: nameController),
            SizedBox(height: 16),
            buildTextField('Email', 'Enter your email',
                controller: emailController),
            SizedBox(height: 16),
            buildTextField('Password', 'Enter your password',
                controller: passwordController, obscureText: true),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthCubit>(context).login(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
