import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'student_id_card_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupPage(),
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final LocalAuthentication auth = LocalAuthentication();

  bool isLoading = true;
  bool loggedIn = false;

  String studentId = "";
  String fullName = "";
  String department = "";
  String batch = "";
  String session = "";
  String photoPath = "";

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<bool> authenticate() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final availableBiometrics = await auth.getAvailableBiometrics();

      if (!isDeviceSupported || availableBiometrics.isEmpty) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: 'Authenticate to access your ID card',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLoggedIn = prefs.getBool("loggedIn") ?? false;

    if (savedLoggedIn) {
      final biometricOk = await authenticate();

      if (!biometricOk) {
        setState(() {
          loggedIn = false;
          isLoading = false;
        });
        return;
      }

      studentId = prefs.getString("studentId") ?? "";
      fullName = prefs.getString("fullName") ?? "";
      department = prefs.getString("department") ?? "";
      batch = prefs.getString("batch") ?? "";
      session = prefs.getString("session") ?? "";
      photoPath = prefs.getString("photoPath") ?? "";
    }

    setState(() {
      loggedIn = savedLoggedIn;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loggedIn) {
      return StudentIdCardPage(
        studentName: fullName,
        studentId: studentId,
        department: department,
        batch: batch,
        session: session,
        university: "LAB University of Applied Sciences",
        roomHint: "Hold to reader",
        photoPath: photoPath,
      );
    }

    return const LoginPage();
  }
}