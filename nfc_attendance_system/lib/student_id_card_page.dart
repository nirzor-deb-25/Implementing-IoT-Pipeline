import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentIdCardPage extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String department;
  final String batch;
  final String session;
  final String university;
  final String roomHint;
  final String photoPath;

  const StudentIdCardPage({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.batch,
    required this.session,
    required this.university,
    required this.roomHint,
    required this.photoPath,
  });

  @override
  State<StudentIdCardPage> createState() => _StudentIdCardPageState();
}

class _StudentIdCardPageState extends State<StudentIdCardPage> {
  final LocalAuthentication auth = LocalAuthentication();

  String attendanceMessage =
      "Keep this screen open and tap your phone on the classroom reader to mark attendance.";

  bool nfcEnabled = false;

  Future<bool> verifyBeforeAttendance() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final availableBiometrics = await auth.getAvailableBiometrics();

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

      return ok;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Biometric error: $e")),
      );
      return false;
    }
  }

  Future<void> enableNfcAttendance() async {
    final biometricOk = await verifyBeforeAttendance();

    if (!mounted) return;

    if (!biometricOk) {
      setState(() {
        nfcEnabled = false;
        attendanceMessage =
            "Attendance cancelled: biometric verification failed.";
      });
      return;
    }

    setState(() {
      nfcEnabled = true;
      attendanceMessage =
          "NFC enabled for 15 seconds.\nNow tap your phone on the NFC reader to mark attendance.";
    });

    await Future.delayed(const Duration(seconds: 15));

    if (!mounted) return;

    setState(() {
      nfcEnabled = false;
      attendanceMessage =
          "NFC session expired. Verify again before tapping the reader.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1020),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1020),
          elevation: 0,
          centerTitle: true,
          title: const Text("Student ID Card"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 30,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                "assets/lab_logo.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.university,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.nfc, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  "NFC",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 84,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: widget.photoPath.isNotEmpty
                                  ? Image.network(
                                      widget.photoPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 40,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.studentName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.department,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.92),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "STUDENT ID",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.studentId,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Divider(color: Colors.white.withOpacity(0.25), height: 1),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill("Batch: ${widget.batch}"),
                          _pill("Session: ${widget.session}"),
                          _pill(widget.roomHint),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: nfcEnabled
                        ? Colors.green.withOpacity(0.15)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: nfcEnabled
                          ? Colors.green.withOpacity(0.4)
                          : Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        nfcEnabled ? Icons.verified_user : Icons.info_outline,
                        color: nfcEnabled ? Colors.greenAccent : Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          attendanceMessage,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: enableNfcAttendance,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(
                      nfcEnabled ? "NFC Enabled" : "Mark Attendance",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}