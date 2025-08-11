import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/colors.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: screenHeight * 0.05),

                          // Back button
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

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

                          Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontSize: screenWidth * 0.08,
                              color: blue1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            'Enter your email address to reset your password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'LeagueSpartanMedium',
                              fontSize: screenWidth * 0.045,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          Form(
                            key: _formKey,
                            child: Column(
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
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          if (state is AuthLoading)
                            Center(child: CircularProgressIndicator())
                          else
                            CustomButton(
                              text: 'Send Reset Link',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // For now, show a success message
                                  // In a real app, you would call the backend API
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Password reset link sent to ${_emailController.text}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Navigate back to login screen
                                  Navigator.pop(context);
                                }
                              },
                            ),

                          SizedBox(height: screenHeight * 0.03),

                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "Back to Login",
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
