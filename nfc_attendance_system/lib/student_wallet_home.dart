import 'package:flutter/material.dart';

class StudentWalletHome extends StatelessWidget {
  const StudentWalletHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo data (change later)
    const studentName = "Your Name";
    const studentId = "20230045";
    const university = "JSTU";
    const department = "CSE";
    const cardType = "Student";
    const roomHint = "Room: E201";

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow
            const Positioned(top: -140, left: -120, child: _Glow(color: Color(0xFF7C3AED), size: 320)),
            const Positioned(top: 40, right: -140, child: _Glow(color: Color(0xFF06B6D4), size: 340)),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StudentCard(
                      university: university,
                      studentName: studentName,
                      studentId: studentId,
                      department: department,
                      cardType: cardType,
                      roomHint: roomHint,
                    ),
                    const SizedBox(height: 18),

                    // Hold to reader
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_tethering_rounded, color: Colors.white.withOpacity(0.9), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Hold to reader",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Keep your phone near the classroom NFC reader\nfor attendance verification.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.65), height: 1.35, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // + button like Wallet
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.85),
        foregroundColor: const Color(0xFF0B1020),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Later: Add/Edit student details")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String university;
  final String studentName;
  final String studentId;
  final String department;
  final String cardType;
  final String roomHint;

  const _StudentCard({
    required this.university,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.cardType,
    required this.roomHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 18)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                university,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
              Text(
                cardType,
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.nfc_rounded, size: 74, color: Colors.white.withOpacity(0.85)),
          ),

          const SizedBox(height: 10),
          Text(studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 4),
          Text(department, style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700, fontSize: 13)),

          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.25), height: 1),
          const SizedBox(height: 14),

          Text(
            "STUDENT ID",
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            studentId,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _pill("Active"),
              const SizedBox(width: 8),
              _pill(roomHint),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(0.55), Colors.transparent]),
      ),
    );
  }
}