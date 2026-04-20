import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'student_id_card_page.dart';
import 'student_signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();

  bool isLoading = false;

  final String webAppUrl =
      "https://script.google.com/macros/s/AKfycbwMe44-qGoZXDCOBKImOBhZVJGyMACTabapZPpbYTjjekxQGs_OeVPYp1SRsiJg8uI/exec";

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("device_id");

    if (deviceId == null || deviceId.isEmpty) {
      final random = Random();
      deviceId =
          "DEV-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(999999)}";
      await prefs.setString("device_id", deviceId);
    }

    return deviceId;
  }

  Future<String> getDeviceModel() async {
    return "Android Phone";
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      debugPrint("canCheckBiometrics: $canCheckBiometrics");
      debugPrint("isDeviceSupported: $isDeviceSupported");
      debugPrint("availableBiometrics: $availableBiometrics");

      if (!isDeviceSupported) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This device does not support biometric authentication"),
          ),
        );
        return false;
      }

      if (availableBiometrics.isEmpty) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No fingerprint or face unlock is enrolled on this phone"),
          ),
        );
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Verify your identity to open your student ID card',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      debugPrint("didAuthenticate: $didAuthenticate");
      return didAuthenticate;
    } catch (e) {
      debugPrint("Biometric error: $e");
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Biometric error: $e")),
      );
      return false;
    }
  }

  Future<void> loginStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final deviceId = await getOrCreateDeviceId();
      final deviceModel = await getDeviceModel();

      final Uri url = Uri.parse(webAppUrl).replace(queryParameters: {
        "action": "loginStudent",
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
        "deviceId": deviceId,
        "deviceModel": deviceModel,
      });

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data["ok"] == true) {
        debugPrint("LOGIN SUCCESS -> starting biometric check");

        final bool biometricOk = await authenticateWithBiometrics();

        if (!biometricOk) {
          setState(() {
            isLoading = false;
          });
          return;
        }

        final student = data["student"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("loggedIn", true);
        await prefs.setString(
            "studentId", (student["studentId"] ?? "").toString());
        await prefs.setString(
            "fullName", (student["fullName"] ?? "").toString());
        await prefs.setString(
            "department", (student["department"] ?? "").toString());
        await prefs.setString("batch", (student["batch"] ?? "").toString());
        await prefs.setString("session", (student["session"] ?? "").toString());
        await prefs.setString("email", (student["email"] ?? "").toString());
        await prefs.setString("phone", (student["phone"] ?? "").toString());
        await prefs.setString(
            "username", (student["username"] ?? "").toString());
        await prefs.setString(
            "photoPath", (student["photoPath"] ?? "").toString());

        await prefs.setString("device_id", deviceId);
        await prefs.setString("device_model", deviceModel);
        await prefs.setString(
            "device_status", (student["deviceStatus"] ?? "").toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentIdCardPage(
              studentName: (student["fullName"] ?? "").toString(),
              studentId: (student["studentId"] ?? "").toString(),
              department: (student["department"] ?? "").toString(),
              batch: (student["batch"] ?? "").toString(),
              session: (student["session"] ?? "").toString(),
              university: "LAB University of Applied Sciences",
              roomHint: "Hold to reader",
              photoPath: (student["photoPath"] ?? "").toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      debugPrint("Login error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Student Login"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildTextField(
                  label: "Username",
                  controller: usernameController,
                ),
                buildTextField(
                  label: "Password",
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginStudent,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentSignupPage(),
                      ),
                    );
                  },
                  child: const Text("Don’t have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}