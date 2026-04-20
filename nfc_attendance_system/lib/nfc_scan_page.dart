import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage> {
  final LocalAuthentication auth = LocalAuthentication();

  String status = "Press the button below to verify identity and enable NFC attendance for 15 seconds.";

  Future<bool> verifyBeforeAttendance() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final availableBiometrics = await auth.getAvailableBiometrics();

      debugPrint("Attendance biometric supported: $isDeviceSupported");
      debugPrint("Attendance available biometrics: $availableBiometrics");

      if (!isDeviceSupported || availableBiometrics.isEmpty) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biometric authentication is not available"),
          ),
        );
        return false;
      }

      final bool ok = await auth.authenticate(
        localizedReason: 'Verify fingerprint before enabling NFC attendance',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("bio_verified", true);
        await prefs.setInt(
          "bio_time",
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      debugPrint("Attendance biometric result: $ok");
      return ok;
    } catch (e) {
      debugPrint("Attendance biometric error: $e");
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Biometric error: $e")),
      );
      return false;
    }
  }

  Future<void> enableNfcAttendance() async {
    final biometricOk = await verifyBeforeAttendance();

    if (!biometricOk) {
      if (!mounted) return;
      setState(() {
        status = "Attendance cancelled: biometric verification failed";
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      status =
          "NFC enabled for 15 seconds.\nNow tap your phone on the NFC reader to mark attendance.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text("NFC Attendance")),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nfc, size: 100),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    status,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: enableNfcAttendance,
                  child: const Text("Verify & Enable NFC"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}