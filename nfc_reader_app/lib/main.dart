import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NfcReaderPage(),
    );
  }
}

class NfcReaderPage extends StatefulWidget {
  const NfcReaderPage({super.key});

  @override
  State<NfcReaderPage> createState() => _NfcReaderPageState();
}

class _NfcReaderPageState extends State<NfcReaderPage> {
  static const platform = MethodChannel("nfc_reader_channel");

  final String webAppUrl =
      "https://script.google.com/macros/s/AKfycbwMe44-qGoZXDCOBKImOBhZVJGyMACTabapZPpbYTjjekxQGs_OeVPYp1SRsiJg8uI/exec";

  final TextEditingController roomController =
      TextEditingController(text: "E201");
  final TextEditingController courseController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController requiredMinutesController =
      TextEditingController(text: "120");

  String status = "Checking NFC...";
  String tagData = "No data yet";

  bool isNfcAvailable = false;
  bool scanEnabled = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    checkNfc();
    setupMethodChannel();
  }

  void setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (!scanEnabled) return;

      if (call.method == "onStudentIdRead") {
        final studentId = call.arguments.toString().trim();

        if (studentId.isEmpty || studentId == "ACCESS_DENIED") {
          if (!mounted) return;
          setState(() {
            status = "Student verification failed";
            tagData =
                "Access denied from student phone.\nBiometric verification may not be completed.";
          });
          return;
        }

        if (!mounted) return;
        setState(() {
          status = "Student ID read successfully";
          tagData = "Student ID: $studentId";
        });

        await markAttendance(studentId);
      } else if (call.method == "onNfcError") {
        if (!mounted) return;
        setState(() {
          status = "NFC read error";
          tagData = call.arguments.toString();
        });
      }
    });
  }

  Future<void> checkNfc() async {
    try {
      final available = await NfcManager.instance.isAvailable();
      if (!mounted) return;
      setState(() {
        isNfcAvailable = available;
        status = available ? "NFC is available" : "NFC is not available";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isNfcAvailable = false;
        status = "NFC check failed";
        tagData = "Error: $e";
      });
    }
  }

  Future<void> markAttendance(String studentId) async {
    final room = roomController.text.trim().isEmpty
        ? "E201"
        : roomController.text.trim();
    final course = courseController.text.trim();
    final teacher = teacherController.text.trim();
    final requiredMinutes = requiredMinutesController.text.trim();

    if (course.isEmpty || teacher.isEmpty || requiredMinutes.isEmpty) {
      if (!mounted) return;
      setState(() {
        status = "Missing required fields";
        tagData =
            "Please fill course name, teacher name and required minutes.";
      });
      return;
    }

    try {
      if (!mounted) return;
      setState(() {
        isSending = true;
        status = "Sending attendance...";
      });

      final uri = Uri.parse(webAppUrl).replace(queryParameters: {
        "studentId": studentId,
        "room": room,
        "course": course,
        "teacher": teacher,
        "requiredMinutes": requiredMinutes,
        "method": "NFC",
      });

      final response = await http.get(uri);

      if (!mounted) return;
      setState(() {
        isSending = false;
        status = "Attendance submitted";
        tagData = "Student ID: $studentId\n\n"
            "Room: $room\n"
            "Course: $course\n"
            "Teacher: $teacher\n"
            "Required Minutes: $requiredMinutes\n\n"
            "Server response:\n${response.body}";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSending = false;
        status = "Attendance submit failed";
        tagData = "Student ID: $studentId\n\n"
            "Room: $room\n"
            "Course: $course\n"
            "Teacher: $teacher\n"
            "Required Minutes: $requiredMinutes\n\n"
            "Error: $e";
      });
    }
  }

  Future<void> startScan() async {
    final course = courseController.text.trim();
    final teacher = teacherController.text.trim();
    final requiredMinutes = requiredMinutesController.text.trim();

    if (course.isEmpty || teacher.isEmpty || requiredMinutes.isEmpty) {
      if (!mounted) return;
      setState(() {
        status = "Please enter all required fields";
        tagData =
            "Course name, teacher name and required minutes must be filled before scan.";
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      scanEnabled = true;
      status = "Ready to read student phone";
      tagData = "Tap the student phone now";
    });
  }

  Future<void> stopScan() async {
    if (!mounted) return;
    setState(() {
      scanEnabled = false;
      status = "Scan stopped";
    });
  }

  @override
  void dispose() {
    roomController.dispose();
    courseController.dispose();
    teacherController.dispose();
    requiredMinutesController.dispose();
    super.dispose();
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("NFC Reader App"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 120,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    controller: roomController,
                    label: "Room",
                    hint: "E201",
                  ),
                  buildField(
                    controller: courseController,
                    label: "Course Name",
                    hint: "Mobile App Development",
                  ),
                  buildField(
                    controller: teacherController,
                    label: "Teacher Name",
                    hint: "Mr. Rahman",
                  ),
                  buildField(
                    controller: requiredMinutesController,
                    label: "Required Minutes",
                    hint: "120",
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          isNfcAvailable && !isSending ? startScan : null,
                      child: const Text("Start Scan"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: stopScan,
                      child: const Text("Stop Scan"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 220),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        tagData,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}