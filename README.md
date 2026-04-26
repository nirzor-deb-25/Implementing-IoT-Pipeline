# NFC-Based Hybrid Attendance System

This project focuses on developing a hybrid attendance system using NFC technology and a mobile application. The aim was to explore how attendance can be recorded more reliably compared to traditional manual methods.



## Project Overview

The system was designed to reduce proxy attendance and improve efficiency by using NFC-based identification. The project mainly focuses on a mobile-based solution, supported by initial hardware experimentation.



## Work Done

### Mobile Application (Flutter)

- Developed a Flutter application for attendance handling
- Designed basic UI screens including:
  - Login page
  - NFC scanning page
  - Student-related interfaces
- Integrated NFC functionality using the mobile device

### NFC Implementation

- Successfully used **mobile phone NFC** for reading tags/cards
- Implemented basic scanning logic within the app
- This became the main working solution

### Hardware Testing (ESP32 + PN532)

- Attempted to integrate PN532 NFC module with ESP32-S3
- Tested both I2C and SPI communication
- Used Arduino IDE and libraries for setup

Issues faced:
- PN532 was not detected properly
- Communication errors persisted
- Device was visible in I2C scan but not working with library

Final decision:
- Hardware approach was not finalized
- Shifted to mobile NFC solution

### Teacher Dashboard

- Created a simple HTML-based dashboard (`teacher_dashboard.html`)
- Intended to display attendance data structure
- Not connected to backend yet

### Project Organization

- Structured the project into multiple folders:
  - Final Project Implementation
  - Initial Project Planning
  - UI/UX design
  - Reports and documentation
- Used Git and GitHub for version control



## Project Structure

- Final Project Implementation/
- Initial Project Planning/
- ML/
- Project in Company Coperation Report/
- UI UX/
- nfc_attendance_system/
- nfc_reader_app/
- teacher_dashboard.html
- README.md



## Technologies Used

- Flutter (Dart)
- HTML
- Git & GitHub
- Arduino IDE (for testing)
- ESP32-S3 (experimental)
- PN532 NFC module (experimental)



## How to Run

1. Clone the repository:
   git clone https://github.com/nirzor-deb-25/Implementing-IoT-Pipeline.git

2. Go to the app folder:
   cd nfc_reader_app

3. Install dependencies:
   flutter pub get

4. Run the app:
   flutter run



## Limitations

- ESP32 + PN532 hardware setup did not work successfully
- No backend/database integration
- Dashboard is static (no live data connection)
- No authentication system implemented



## Reports

All project reports are available in:
Project in Company Coperation Report/



## Author

Nirzor Deb  
https://github.com/nirzor-deb-25


## License

This project is developed for academic purposes.
