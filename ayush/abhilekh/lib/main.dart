import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// IMPORTANT: You must generate this file using "flutterfire configure"
import 'firebase_options.dart'; 

import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/home_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init(); // Initialize Dependency Injection
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<AttendanceBloc>(create: (_) => di.sl<AttendanceBloc>()),
      ],
      child: MaterialApp(
        title: 'Student Registry',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to Authentication State to decide which screen to show
    return BlocBuilder<AuthBloc, bool>(
      builder: (context, isLoggedIn) {
        if (isLoggedIn) {
          return const StudentHomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}