📱 NFC-Based Hybrid Attendance System

A secure and efficient attendance system using NFC technology, biometric authentication, and device binding to prevent proxy attendance.

### Features :

# Security Features
One account works on only one device
One device cannot be used for multiple accounts
Fingerprint authentication required before NFC scan
Teacher approval required for new login
Device change requires approval
Strong protection against proxy attendance

# Project Structure
nfc_attendance_system/   → Backend + Web dashboard
nfc_reader_app/          → Flutter mobile app (NFC reader)

# Technologies Used
Flutter (Mobile App)
HTML / JavaScript (Dashboard)
NFC Technology
Fingerprint Authentication
Git & GitHub

# Mobile App (nfc_reader_app)
Reads NFC tags/cards
Verifies fingerprint before scanning
Sends attendance data to server
Ensures device-based authentication

# Web Dashboard (nfc_attendance_system)
Teacher dashboard
Approve device change requests
Monitor attendance
Manage student data

# How It Works
User logs in (first time requires approval)
Device gets registered
User scans fingerprint
NFC card is tapped
Attendance is recorded securely
Any suspicious activity requires teacher approval

# Objective
To eliminate proxy attendance and ensure:
Authentic presence verification
Secure attendance tracking
Controlled device usage
