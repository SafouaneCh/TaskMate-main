import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Add this import
import 'screens/signup_screen.dart'; // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    // Add this line to check for token and update AuthCubit state
    Future.microtask(() {
      context.read<AuthCubit>().getUserData();
    });
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      // Set it to false so next time it won't show WelcomeScreen
      prefs.setBool('isFirstTime', false);
    }

    setState(() {
      _isFirstTime = isFirstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
      ],
      child: MaterialApp(
        home: _isFirstTime
            ? WelcomeScreen()
            : BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoggedIn) {
                    return HomeScreen();
                  } else if (state is AuthSignUp) {
                    return SignupScreen();
                  } else if (state is AuthLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    // AuthInitial, AuthError, or any other state
                    return LoginScreen();
                  }
                },
              ),
      ),
    );
  }
}
