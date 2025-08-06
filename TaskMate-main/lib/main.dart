import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/cubit/add_new_task_cubit.dart'; // Import AddNewTaskCubit
import 'package:taskmate/cubit/tasks_cubit.dart'; // Import TasksCubit
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
  bool _isInitialized = false;
  final AuthCubit _authCubit = AuthCubit();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _checkFirstTime();
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
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('AuthCubit state in build: ' + _authCubit.state.toString());

    // Show loading screen while initializing
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Copy of Welcome - 1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  SizedBox(height: 30),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(
            create: (context) => AddNewTaskCubit()), // Add AddNewTaskCubit
        BlocProvider(create: (context) => TasksCubit()), // Add TasksCubit
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
                    return Scaffold(
                      body: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Copy of Welcome - 1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/logo.png', height: 100),
                              SizedBox(height: 30),
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Checking authentication...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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
