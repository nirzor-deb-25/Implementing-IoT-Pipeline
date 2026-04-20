import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NfcReaderPage extends StatefulWidget {
  const NfcReaderPage({super.key});

  @override
  State<NfcReaderPage> createState() => _NfcReaderPageState();
}

class _NfcReaderPageState extends State<NfcReaderPage> {
  final TextEditingController roomController = TextEditingController(text: "E201");
  final TextEditingController courseController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();

  String status = "Ready to scan attendance";
  bool isLoading = false;

  final String scriptUrl =
      "https://script.google.com/macros/s/AKfycbwMe44-qGoZXDCOBKImOBhZVJGyMACTabapZPpbYTjjekxQGs_OeVPYp1SRsiJg8uI/exec";

  Future<void> submitAttendance() async {
    final room = roomController.text.trim();
    final course = courseController.text.trim();
    final teacher = teacherController.text.trim();
    final studentId = studentIdController.text.trim();

    if (room.isEmpty || course.isEmpty || teacher.isEmpty || studentId.isEmpty) {
      setState(() {
        status = "Please fill room, course, teacher, and student ID.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      status = "Sending attendance...";
    });

    try {
      final uri = Uri.parse(scriptUrl).replace(queryParameters: {
        "studentId": studentId,
        "room": room,
        "course": course,
        "teacher": teacher,
        "method": "NFC Reader"
      });

      final response = await http.get(uri);

      if (!mounted) return;

      setState(() {
        status = response.body;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = "Failed: $e";
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomController.dispose();
    courseController.dispose();
    teacherController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC Reader App"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildField(
              label: "Room Number",
              controller: roomController,
              hint: "E201",
            ),
            buildField(
              label: "Course Name",
              controller: courseController,
              hint: "Mobile App Development",
            ),
            buildField(
              label: "Teacher Name",
              controller: teacherController,
              hint: "Mr. Rahman",
            ),
            buildField(
              label: "Student ID",
              controller: studentIdController,
              hint: "2401813",
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitAttendance,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Mark Attendance"),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                status,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}