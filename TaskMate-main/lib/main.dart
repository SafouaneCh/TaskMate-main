import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/cubit/add_new_task_cubit.dart'; // Import AddNewTaskCubit
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Add this import
import 'screens/signup_screen.dart'; // Add this import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = true;
  final AuthCubit _authCubit = AuthCubit();

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    // Initialize auth after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authCubit.getUserData();
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
    print('AuthCubit state in build: ' + _authCubit.state.toString());
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(
            create: (context) => AddNewTaskCubit()), // Add AddNewTaskCubit
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
