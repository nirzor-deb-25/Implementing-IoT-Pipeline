### NFC-Based Hybrid Attendance System
A secure attendance system using NFC, biometric authentication, and device binding to prevent proxy attendance and ensure authenticity.
The system ensures that attendance is recorded only when the actual user is physically present.
It combines a mobile NFC reader application with a web-based dashboard for monitoring and control.
Designed for educational institutions and organizations, it provides a reliable and tamper-resistant attendance solution.

### Overview:
Traditional attendance systems are vulnerable to proxy attendance and misuse.


### This project addresses these issues by combining:
NFC-based identification
Biometric verification
Device-level restrictions

### Target Users:
Educational institutions
Training centers
Organizations requiring secure attendance tracking

### Features
One account per device
Prevents multiple accounts on a single device
Fingerprint authentication required before NFC scan

### Teacher approval required for:
New login
Device change
Protection against proxy attendance

### Project Structure
nfc_attendance_system/   # Backend + Web dashboard
nfc_reader_app/          # Flutter NFC mobile app


### Tech Stack

Mobile App	= Flutter (Dart)
Web	= HTML, JavaScript
Hardware =	NFC + Fingerprint
Versioning = 	Git & GitHub

### Getting Started

### Prerequisites
Flutter SDK installed
NFC-enabled Android device
Git installed

### Installation
git clone https://github.com/nirzor-deb-25/nfc_attendance_system.git
cd nfc_reader_app
flutter pub get
flutter run


### Usage
Login (requires approval for first-time use)
Verify fingerprint
Tap NFC card
Attendance is recorded securely

### Architecture Overview
[User Device]
   ↓ (Fingerprint + NFC)
[Flutter App]
   ↓ (API Request)
[Backend System]
   ↓
[Database + Dashboard]

### Testing
Manual testing on NFC-enabled devices

### Functional testing for:
Authentication
Device binding
Approval system
CI/CD and Security
GitHub Security Features
Dependabot alerts
Secret scanning
Push protection
Code scanning (CodeQL recommended)


This project is licensed under the MIT License.

### Acknowledgments
Flutter community
NFC technology resources
Academic guidance
