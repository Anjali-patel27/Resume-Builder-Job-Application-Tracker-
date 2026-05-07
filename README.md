# 📄 ResumeTrack Pro — Smart Resume Builder & Job Application Tracker

A **Flutter-based** mobile application that allows students and job seekers to create structured resumes, manage multiple job applications, track application status, and receive career insights — with full **offline-first** support.

---

## 🚀 Features

### 🗂️ Resume Builder Module
- Create & edit multiple resume profiles
- Personal Details, Education, Skills, Experience (optional)
- Profile Name for easy identification and linking

### 💼 Job Application Module
- Add applications with Company, Role, Date Applied, and linked Resume
- Auto-generates unique Application IDs (`APP-XXXXXXX-XXXX`)
- Notes section for extra context

### 📊 Application Tracking Module
- 5-stage tracking: **Applied → Shortlisted → Interview Scheduled → Rejected → Selected**
- One-tap status update from the detail view
- Color-coded status badges throughout the UI

### 📈 Application Dashboard
- Total applications & resumes counters
- Interview count stat card
- Pie chart showing status distribution
- Recent applications list with quick navigation

### 🔗 Resume-Version Mapping
- Each application is linked to a specific resume profile at the time of submission
- The resume profile name is stored alongside the application for historical accuracy

### 🔍 Search & Filter Module
- Real-time search by company name or job role
- Filter by application status (All / Applied / Shortlisted / Interview / Rejected / Selected)
- Result count indicator

### 📴 Offline Functionality
- All data stored locally using **Hive** (NoSQL embedded database)
- Full CRUD works without internet connectivity
- Online/offline banner indicator in the UI

### ✅ Validation & Error Handling
- Required field validation on all forms
- Duplicate profile name prevention
- Meaningful Snackbar feedback

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.32 / Dart 3.8 |
| State Management | Provider |
| Local Storage | Hive + Hive Flutter |
| Charts | fl_chart |
| Fonts | Google Fonts (Outfit) |
| Animations | flutter_staggered_animations |
| Network Awareness | connectivity_plus |
| UUID Generation | uuid |

---

## 📱 Screens

1. **Splash Screen** — Animated brand intro
2. **Dashboard Screen** — Stats, pie chart, recent applications
3. **Resume List Screen** — All resume profiles
4. **Resume Builder Screen** — 4-tab form (Personal / Education / Skills / Experience)
5. **Job Application Entry Screen** — Add new application with resume picker
6. **Application Detail Screen** — Full details + status stepper + delete
7. **Search & Filter Screen** — Real-time search and status filtering

---

## 🗂️ Project Structure

```
lib/
├── main.dart                     # App entry, Hive init, splash screen
├── models/
│   ├── resume.dart               # Resume, Education, Experience models
│   ├── resume.g.dart             # Hive adapters
│   ├── job_application.dart      # JobApplication model + ApplicationStatus
│   └── job_application.g.dart   # Hive adapters
├── providers/
│   ├── resume_provider.dart      # Resume CRUD + state
│   ├── application_provider.dart # Application CRUD + filter + stats
│   └── connectivity_provider.dart # Online/offline tracking
├── screens/
│   ├── main_navigation.dart      # Bottom nav shell + offline banner
│   ├── dashboard_screen.dart     # Dashboard with pie chart
│   ├── resume_list_screen.dart   # Resume list
│   ├── resume_builder_screen.dart # Resume builder form
│   ├── job_application_entry_screen.dart
│   ├── application_detail_screen.dart
│   └── search_filter_screen.dart
├── widgets/
│   ├── glass_card.dart           # Glassmorphic card component
│   ├── status_badge.dart         # Colored status indicator
│   └── gradient_button.dart      # Gradient button
└── utils/
    ├── app_colors.dart           # Color constants + gradients
    └── app_theme.dart            # ThemeData configuration
```

---

## 🔄 Resume-Application Mapping Logic

When a user creates a job application:
1. They **select a resume profile** from a visual card picker
2. Both the `resumeId` (UUID) and `resumeProfileName` (display name) are stored with the application
3. This ensures historical integrity — even if the resume is later renamed or deleted, the application record retains the original profile name
4. The Application Detail screen shows the linked resume name under "Resume Used"

---

## 📦 Getting Started

```bash
# Clone the repository
git clone https://github.com/Anjali-patel27/Resume-Builder-Job-Application-Tracker-.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔮 Future Scope

- Firebase backend sync for cloud backup and multi-device support
- PDF export of resume from the app
- Job posting integration (LinkedIn / Naukri APIs)
- Push notifications for interview reminders
- AI-powered resume suggestions based on job role
- Dark / Light theme toggle

---

## 📝 Conclusion

ResumeTrack Pro solves the real-world pain points of job seekers by unifying resume management and application tracking in a single, offline-capable app. With a clean modular architecture (Provider + Hive), intuitive navigation, and a premium dark UI, it provides a smooth and reliable experience for managing career progress.

---

*Developed with ❤️ using Flutter*
