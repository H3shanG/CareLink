# ❤️ CareLink

> **All the care you need in one place.**

CareLink is a mobile healthcare and family-care platform developed as a university Software Engineering group project. The application aims to connect users with essential healthcare services such as blood donors, caregivers, pharmacies, emergency transportation, and child health management through a single mobile application.

The project is designed to demonstrate practical Software Engineering concepts including requirements analysis, UI/UX design, mobile application development, database integration, authentication, team collaboration, version control, testing, and project documentation.

---

## 📱 Project Overview

Finding healthcare-related services often requires users to access several different platforms. CareLink attempts to bring commonly needed healthcare and family-care services together within one application.

Users can select between:

- 👨‍⚕️ **Adult / Patient Care**
- 👶 **Baby / Child Care**

The application provides a simple interface where users can discover services, search for providers, create bookings, manage healthcare information, and access emergency-related services.

---

## ✨ Main Features

### 👨‍⚕️ Adult / Patient Care

- 🩸 Blood Donation
- 👩‍⚕️ Caregiver / Nurse Booking
- 💊 Medicine & Pharmacy
- 🚑 Emergency Transport
- ♿ Medical Equipment
- ❤️ Organ Donor Registry
- 📅 Booking Management
- 👤 User Profile Management

### 👶 Baby / Child Care

- 🩺 Pediatric Care
- 💊 Pediatric Medicine
- 📋 Child Health Records
- 💉 Vaccination Tracking
- ⚠️ Allergy Records
- 📈 Growth Tracking
- 🛒 Baby Equipment
- 🚑 Emergency Transport

---

## 🖼️ Application Screens

The planned user interface includes:

- Splash Screen
- Onboarding Screen
- Care Journey Selection
- Adult Care Dashboard
- Child Care Dashboard
- Profile Menu
- Blood Donation Screen
- Caregiver / Nurse Booking
- Medicine & Pharmacy
- Emergency Transport
- Booking Details
- Child Health Dashboard

> Screenshots of the application will be added here as development progresses.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| Firebase Authentication | User registration and login |
| Cloud Firestore | Application database |
| Firebase Storage | Image and file storage |
| Firebase Cloud Messaging | Notifications |
| Google Maps / Maps API | Location-based services |
| GitHub | Version control and collaboration |
| Figma | UI/UX design |
| GitHub Projects / Trello | Project management |

---

## 🏗️ Proposed Architecture

CareLink follows a modular structure where individual features are separated to make development and maintenance easier.

```text
lib/
│
├── main.dart
│
├── app/
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
│
├── models/
│   ├── user.dart
│   ├── booking.dart
│   ├── donor.dart
│   ├── provider.dart
│   ├── pharmacy.dart
│   └── child.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── notification_service.dart
│   └── location_service.dart
│
├── features/
│   ├── authentication/
│   ├── onboarding/
│   ├── home/
│   ├── blood_donation/
│   ├── caregiver/
│   ├── pharmacy/
│   ├── emergency_transport/
│   ├── child_health/
│   └── profile/
│
└── widgets/
    ├── custom_button.dart
    ├── service_card.dart
    ├── custom_search_bar.dart
    └── loading_indicator.dart
```

---

## 👥 Team

This project is developed by a team of **7 Software Engineering undergraduate students**.

| Member | Responsibility |
|---|---|
| Member 1 | Team Lead, Project Integration & Navigation |
| Member 2 | Authentication, Onboarding & User Profile |
| Member 3 | Blood Donation Module |
| Member 4 | Caregiver / Nurse Booking Module |
| Member 5 | Medicine & Pharmacy Module |
| Member 6 | Emergency Transport & Location Services |
| Member 7 | Child Health Management Module |

### Team Members

1. **[Member Name]** - [Student ID]
2. **[Member Name]** - [Student ID]
3. **[Member Name]** - [Student ID]
4. **[Member Name]** - [Student ID]
5. **[Member Name]** - [Student ID]
6. **[Member Name]** - [Student ID]
7. **[Member Name]** - [Student ID]

---

## 🔥 Main Database Collections

The planned Firestore database contains collections such as:

```text
users
providers
bookings
donors
bloodRequests
pharmacies
medicines
transportRequests
children
healthRecords
notifications
```

Example booking structure:

```text
bookings/
    bookingId/
        userId
        providerId
        service
        date
        time
        address
        price
        status
```

---

## 🔄 Git Workflow

We use a feature-branch workflow for development.

```text
main
  ↑
develop
  ↑
feature branches
```

Example branches:

```text
feature/authentication
feature/blood-donation
feature/caregiver-booking
feature/pharmacy
feature/emergency-transport
feature/child-health
feature/profile
```

### Development Process

```text
Create Feature Branch
        ↓
Develop Feature
        ↓
Test Feature
        ↓
Commit & Push
        ↓
Create Pull Request
        ↓
Code Review
        ↓
Merge into develop
        ↓
Integration Testing
        ↓
Merge into main
```

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Git
- Android Emulator or physical Android device
- Firebase project

Check your Flutter installation:

```bash
flutter doctor
```

---

## 📥 Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/CareLink.git
```

Move into the project directory:

```bash
cd CareLink
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## 🔥 Firebase Configuration

The project uses Firebase for authentication and database functionality.

Firebase services used include:

```text
Firebase Authentication
Cloud Firestore
Firebase Storage
Firebase Cloud Messaging
```

Each developer must configure Firebase for their development environment before running Firebase-dependent functionality.

> Firebase configuration files containing sensitive information should not be publicly shared unless they are intended for client-side use and properly secured through Firebase Security Rules.

---

## 🧪 Testing

The project will include several levels of testing.

### Unit Testing

Used to test individual functions, models, and services.

```bash
flutter test
```

### Widget Testing

Used to verify individual Flutter UI components.

### Integration Testing

Used to test complete workflows such as:

```text
Login
   ↓
Home
   ↓
Select Service
   ↓
Select Provider
   ↓
Create Booking
   ↓
Booking Confirmation
```

---

## 📌 Example User Flow

### Caregiver Booking

```text
Login
   ↓
Adult Care
   ↓
Caregiver / Nurse Booking
   ↓
Search Caregiver
   ↓
View Caregiver
   ↓
Choose Date & Time
   ↓
Confirm Booking
   ↓
Booking Details
```

### Blood Donation

```text
Home
   ↓
Blood Donation
   ↓
Select Blood Group
   ↓
View Nearby Donors
   ↓
Select Donor
   ↓
Send Request
```

### Child Health

```text
Child Care
   ↓
Select Child Profile
   ↓
Health Dashboard
   ↓
Vaccinations / Allergies / Growth
   ↓
View Health Records
```

---

## 🗺️ Project Development Roadmap

| Phase | Task | Status |
|---|---|---|
| Phase 1 | Requirement Analysis | 🔄 In Progress |
| Phase 2 | UI/UX Design | 🔄 In Progress |
| Phase 3 | Project Architecture | ⏳ Planned |
| Phase 4 | Authentication | ⏳ Planned |
| Phase 5 | Core Feature Development | ⏳ Planned |
| Phase 6 | Firebase Integration | ⏳ Planned |
| Phase 7 | Maps & Location Services | ⏳ Planned |
| Phase 8 | Notifications | ⏳ Planned |
| Phase 9 | Testing | ⏳ Planned |
| Phase 10 | Final Integration | ⏳ Planned |
| Phase 11 | Documentation | ⏳ Planned |
| Phase 12 | Final Presentation | ⏳ Planned |

---

## 🎯 Project Objectives

The main objectives of CareLink are to:

- Provide healthcare-related services through one mobile application.
- Make it easier to discover healthcare providers and services.
- Provide a simple caregiver booking process.
- Help users locate potential blood donors.
- Provide access to nearby pharmacies.
- Support emergency transport requests.
- Help parents maintain basic child health information.
- Demonstrate good Software Engineering practices through modular development, testing, version control, and team collaboration.

---

## 🔐 Security & Privacy

Because CareLink works with healthcare-related information, security and privacy are important considerations.

The project aims to implement:

- Secure user authentication
- Firebase Security Rules
- Role-based data access where required
- Input validation
- Secure database operations
- Protection of personal information
- Restricted access to health records

---

## ⚠️ Disclaimer

CareLink is currently being developed as an **academic Software Engineering project**.

It is a prototype and should **not** be used as a replacement for professional medical advice, diagnosis, treatment, ambulance services, or official emergency healthcare systems.

In a real emergency, users should contact the appropriate official emergency services.

---

## 📚 Software Engineering Concepts Demonstrated

This project demonstrates practical use of:

- Requirements Engineering
- Agile Development
- UI/UX Design
- Mobile Application Development
- Database Design
- Authentication
- API Integration
- Object-Oriented Programming
- Version Control
- Git Branching
- Code Reviews
- Testing
- Team Collaboration
- Software Documentation
- System Integration

---

## 🎓 Academic Information

**Project Name:** CareLink  
**Project Type:** Mobile Application  
**Module:** [Module Name]  
**Degree Program:** Software Engineering  
**University:** [University Name]  
**Academic Year:** 2026  
**Team Size:** 7 Members

---

## 📄 License

This project is developed primarily for academic and educational purposes.

See the `LICENSE` file for more information.

---

## ❤️ CareLink

**Healthier People. Stronger Families.**

Developed with ❤️ by the CareLink Software Engineering Team.
