# ResumeTrack Pro 🚀

ResumeTrack Pro is a professional-grade, offline-first Flutter application designed to empower job seekers. It combines a robust **Multi-Profile Resume Builder** with an advanced **Job Application Tracker**, providing a centralized hub for managing your entire career search with precision and style.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter)
![Database](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite)

---

## ✨ Key Features

### 📊 Professional Dashboard
Get a high-level view of your career progress. The dashboard provides real-time analytics, success rate metrics, and lifecycle distribution charts powered by `fl_chart`.

### 📄 Intelligent Resume Builder
Create and manage multiple resume profiles tailored for different industries.
- **Inline Entry Forms**: Direct data entry for Education and Experience.
- **Skill Management**: Tag-based skill organization.
- **Modular Sections**: Easily edit Personal Info, Education, Skills, and Work History.

### 🎯 Job Application Lifecycle Tracker
Never lose track of an opportunity. Manage your applications through their entire journey:
- **Status Tracking**: Applied → Shortlisted → Interview → Selected/Rejected.
- **Resume Linking**: Track exactly which resume profile was used for each application.
- **Detailed Notes**: Keep records of contact persons, interview questions, and feedback.

### 📱 Premium SaaS-Inspired UI
A meticulously crafted interface designed for clarity and impact.
- **Slate & Indigo Theme**: A high-contrast, eye-friendly dark mode.
- **Responsive Layouts**: Optimized for a seamless mobile experience.
- **Glassmorphism Elements**: Modern, polished surface components.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [SQLite (sqflite)](https://pub.dev/packages/sqflite) - Robust relational storage.
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Typography**: [Google Fonts (Outfit)](https://fonts.google.com/specimen/Outfit)
- **Animations**: [Flutter Staggered Animations](https://pub.dev/packages/flutter_staggered_animations)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.22 or higher)
- Android Studio / VS Code with Flutter extensions
- A mobile emulator or physical device

### Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Anjali-patel27/Resume-Builder-Job-Application-Tracker-.git
    ```
2.  **Navigate to the project directory**:
    ```bash
    cd Resume-Builder-Job-Application-Tracker-
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```

---

## 📁 Architecture Overview

- **Models**: Structured data entities for Resumes and Applications.
- **Providers**: Centralized business logic and state management.
- **Services**: Abstracted database layer for SQLite operations.
- **Widgets**: Reusable UI components (GlassCards, StatusBadges, Custom Buttons).

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📬 Contact

For support or feedback, please reach out via the repository's issue tracker.

Developed with ❤️ for the Flutter community.
