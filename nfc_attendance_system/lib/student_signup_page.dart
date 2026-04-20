import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StudentSignupPage extends StatefulWidget {
  const StudentSignupPage({super.key});

  @override
  State<StudentSignupPage> createState() => _StudentSignupPageState();
}

class _StudentSignupPageState extends State<StudentSignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController sessionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Uint8List? selectedImageBytes;
  String? selectedImageBase64;
  String? selectedImageName;

  final ImagePicker _picker = ImagePicker();

  final String webAppUrl =
      "https://script.google.com/macros/s/AKfycbwMe44-qGoZXDCOBKImOBhZVJGyMACTabapZPpbYTjjekxQGs_OeVPYp1SRsiJg8uI/exec";

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        selectedImageBytes = bytes;
        selectedImageBase64 = base64Encode(bytes);
        selectedImageName = image.name;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image pick error: $e")),
      );
    }
  }

  Future<http.Response> postWithRedirect(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    final encodedBody = jsonEncode(body);

    final client = http.Client();

    try {
      final request = http.Request("POST", url);
      request.headers["Content-Type"] = "application/json";
      request.body = encodedBody;
      request.followRedirects = false;

      final firstStream = await client.send(request);
      final firstResponse = await http.Response.fromStream(firstStream);

      debugPrint("FIRST STATUS: ${firstResponse.statusCode}");
      debugPrint("FIRST HEADERS: ${firstResponse.headers}");
      debugPrint("FIRST BODY: ${firstResponse.body}");

      if ((firstResponse.statusCode == 302 ||
              firstResponse.statusCode == 301 ||
              firstResponse.statusCode == 303 ||
              firstResponse.statusCode == 307 ||
              firstResponse.statusCode == 308) &&
          firstResponse.headers["location"] != null) {
        final redirectUrl = firstResponse.headers["location"]!;
        debugPrint("REDIRECT URL: $redirectUrl");

        // IMPORTANT: second request should be GET, not POST
        final finalResponse = await client.get(Uri.parse(redirectUrl));

        debugPrint("FINAL STATUS CODE: ${finalResponse.statusCode}");
        debugPrint("FINAL HEADERS: ${finalResponse.headers}");
        debugPrint("FINAL RESPONSE BODY: ${finalResponse.body}");

        return finalResponse;
      }

      return firstResponse;
    } finally {
      client.close();
    }
  }

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a student photo.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final body = {
      "action": "registerStudent",
      "studentId": studentIdController.text.trim(),
      "fullName": fullNameController.text.trim(),
      "department": departmentController.text.trim(),
      "batch": batchController.text.trim(),
      "session": sessionController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim(),
      "photoBase64": selectedImageBase64,
      "photoFileName": selectedImageName ?? "student_photo.png",
    };

    try {
      final response = await postWithRedirect(
        Uri.parse(webAppUrl),
        body,
      );

      final raw = response.body.trim();

      if (!mounted) return;

      if (raw.startsWith("<")) {
        final shortBody = raw.length > 500 ? raw.substring(0, 500) : raw;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server returned HTML: $shortBody"),
            duration: const Duration(seconds: 8),
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final data = jsonDecode(raw);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Response received")),
      );

      if (data["ok"] == true) {
        studentIdController.clear();
        fullNameController.clear();
        departmentController.clear();
        batchController.clear();
        sessionController.clear();
        emailController.clear();
        phoneController.clear();
        usernameController.clear();
        passwordController.clear();

        setState(() {
          selectedImageBytes = null;
          selectedImageBase64 = null;
          selectedImageName = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration error: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
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
    studentIdController.dispose();
    fullNameController.dispose();
    departmentController.dispose();
    batchController.dispose();
    sessionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Sign Up"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.grey.shade200,
                      ),
                      child: selectedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                selectedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text("Choose Photo"),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              buildTextField(label: "Student ID", controller: studentIdController),
              buildTextField(label: "Full Name", controller: fullNameController),
              buildTextField(label: "Department", controller: departmentController),
              buildTextField(label: "Batch", controller: batchController),
              buildTextField(label: "Session", controller: sessionController),
              buildTextField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              buildTextField(
                label: "Phone",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              buildTextField(label: "Username", controller: usernameController),
              buildTextField(
                label: "Password",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerStudent,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}