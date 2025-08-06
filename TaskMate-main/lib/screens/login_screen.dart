import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/colors.dart';
import 'home_screen.dart' as home;
import '../widgets/custom_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Copy of Welcome - 1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => home.HomeScreen()),
                        );
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: screenHeight * 0.05),

                          Container(
                            height: screenHeight * 0.12,
                            constraints: BoxConstraints(
                              maxHeight: 100,
                              minHeight: 80,
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Create your own ',
                                  style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontSize: screenWidth * 0.06,
                                    color: blue1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'life reminder',
                                  style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontSize: screenWidth * 0.06,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '!',
                                  style: TextStyle(
                                    fontFamily: 'LeagueSpartan',
                                    fontSize: screenWidth * 0.06,
                                    color: blue1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            'Stay connected, stay organized',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'LeagueSpartanMedium',
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // Username
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Username',
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartanMedium',
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  filled: true,
                                  fillColor:
                                      Colors.grey[200]?.withOpacity(0.7) ??
                                          Colors.grey.withOpacity(0.7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Email
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartanMedium',
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  filled: true,
                                  fillColor:
                                      Colors.grey[200]?.withOpacity(0.7) ??
                                          Colors.grey.withOpacity(0.7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Password
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartanMedium',
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  filled: true,
                                  fillColor:
                                      Colors.grey[200]?.withOpacity(0.7) ??
                                          Colors.grey.withOpacity(0.7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Forgot password checkbox
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(value: false, onChanged: (value) {}),
                              Text(
                                'Forgot password !',
                                style: TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  fontSize: screenWidth * 0.055,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          CustomButton(
                            text: 'Login',
                            onPressed: () {
                              context.read<AuthCubit>().login(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                            },
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: blue1,
                                fontSize: screenWidth * 0.045,
                                fontFamily: 'LeagueSpartanMedium',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
