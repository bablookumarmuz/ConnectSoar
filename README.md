# ConnectSoar

> A modern Flutter-based communication and meeting platform for teams, with authentication, meeting management, live meetings, participant controls, scheduling, and in-meeting chat.

---

## 📱 About ConnectSoar

**ConnectSoar** is a modern collaboration and meeting application built with **Flutter**.

The application provides a centralized platform where employees, managers, and administrators can authenticate, create and schedule meetings, join meetings, manage participants, communicate through chat, and manage their account settings.

The application is designed with a responsive and modern UI/UX approach, with special attention to different screen sizes, keyboard states, and Android device compatibility.

---

## ✨ Key Features

### 🔐 Authentication

- Secure user login
- Production backend authentication
- Access token handling
- Refresh token handling
- Current user profile
- Forgot password
- Change password
- Role-based user information
- Automatic authentication state handling

### 📅 Meeting Management

- Create instant meetings
- Schedule meetings
- View upcoming meetings
- View live meetings
- Meeting details
- Join using Meeting ID
- Join using Meeting Code
- Cancel/delete meetings
- End meetings
- Copy meeting information/link
- Meeting search

### 🎥 Live Meeting

- Camera controls
- Microphone controls
- Speaker controls
- Participant management
- Active speaker interface
- Picture-in-picture style meeting UI
- Meeting timer
- Network status indicator
- Pre-join screen
- Device diagnostics
- Virtual background options

### 👥 Participant Management

- View participants
- Search participants
- Invite participants
- Participant role management
- Mute participant
- Disable participant camera
- Remove participant
- Mute all participants
- Lower all raised hands

### 💬 In-Meeting Chat

- Real-time meeting chat interface
- Message list
- Message input
- Emoji reactions
- Keyboard-aware chat UI

### 📊 Dashboard

- Live meeting statistics
- Scheduled meeting statistics
- Upcoming meetings
- Quick actions
- Meeting search
- Modern responsive dashboard

### ⚙️ Settings

- User profile
- Account information
- Role information
- Department
- Designation
- Phone information
- Profile image support
- Change password
- Application settings

---

## 🛠️ Technology Stack

| Technology | Usage |
|---|---|
| Flutter | Mobile application framework |
| Dart | Application programming language |
| Android | Primary mobile platform |
| REST API | Backend communication |
| WebSocket | Live communication where supported by backend |
| Secure Storage | Authentication token storage |
| Firebase/Native Services | Platform-specific services where configured |
| Postman | API testing |
| Git | Version control |
| GitHub | Source code management |

---

## 🏗️ Project Architecture

The application follows a feature-oriented Flutter architecture.

```text
lib/
│
├── core/
│   ├── config/
│   ├── network/
│   ├── storage/
│   └── ...
│
├── features/
│   ├── auth/
│   ├── meetings/
│   ├── chat/
│   ├── people/
│   ├── dashboard/
│   └── settings/
│
└── main.dart
```

### Core Responsibilities

**Core**

Contains shared application infrastructure such as:

- API configuration
- Network client
- API exceptions
- Secure storage
- Common utilities

**Features**

Each major application module is separated into its own feature area.

This makes the project easier to maintain and extend as new backend APIs are added.

---

## 🌐 Backend

The application connects to the production backend:

```text
https://connectsoar-backend.onrender.com
```

### Authentication API

Authentication APIs are currently integrated with the production backend.

The authentication module includes:

```text
POST /api/v1/auth/login
POST /api/v1/auth/refresh
GET  /api/v1/auth/me
POST /api/v1/auth/change-password
POST /api/v1/auth/forgot-password
POST /api/v1/auth/logout
```

### Meeting API

Meeting functionality is integrated with the backend meeting APIs provided for the project.

The application supports:

- Meeting creation
- Meeting scheduling
- Meeting listing
- Meeting details
- Join by meeting ID
- Join by meeting code
- Participants
- Meeting chat
- Meeting ending
- Meeting cancellation/deletion

> API endpoints should be updated whenever new backend API documentation is provided by the backend team.

---

## 🔑 Authentication Flow

The application uses access and refresh tokens.

```text
User
 │
 ▼
Login
 │
 ▼
Backend Authentication
 │
 ├── Success
 │      │
 │      ▼
 │   Access Token
 │      │
 │      ▼
 │   Authenticated App
 │
 └── Password Change Required
        │
        ▼
   Change Password
```

When an access token expires:

```text
API Request
     │
     ▼
401 Unauthorized
     │
     ▼
Refresh Token
     │
     ▼
New Access Token
     │
     ▼
Retry Request
```

Tokens should be stored securely and must never be committed to GitHub.

---

## 👤 User Roles

ConnectSoar supports role-based users such as:

- **Admin**
- **Manager**
- **Employee**

The actual permissions and capabilities are controlled by the backend/API implementation.

---

## 🚀 Getting Started

### Prerequisites

Install:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Git
- VS Code or Android Studio

Verify Flutter:

```bash
flutter --version
```

Verify Flutter environment:

```bash
flutter doctor
```

---

## 📥 Installation

Clone the repository:

```bash
git clone https://github.com/bablookumarmuz/ConnectSoar.git
```

Enter the project:

```bash
cd ConnectSoar
```

Install dependencies:

```bash
flutter pub get
```

---

## ▶️ Run the Application

Connect an Android device or start an Android emulator.

Then run:

```bash
flutter run
```

---

## 🧪 Testing

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

---

## 📦 Build Debug APK

For development/testing builds:

```bash
flutter build apk --debug
```

APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

> Debug APK is intended for development and testing. Production release builds should follow the team's release/signing process.

---

## 🔍 API Testing

Postman can be used to test backend APIs independently of the Flutter application.

The repository may contain API collections, but **environment files containing passwords, access tokens, refresh tokens, or other secrets must not be committed to GitHub.**

Use a local environment file for sensitive values.

---

## 📱 Responsive UI/UX

ConnectSoar is designed to work across different Android screen sizes.

The UI has been tested for:

- Standard Android devices
- Narrow-width layouts
- 320dp
- 360dp
- 390dp
- Keyboard-open states
- Bottom sheets
- Dialogs
- Meeting controls
- Scrollable forms

The application aims to maintain:

- No RenderFlex overflow
- No clipped content
- No unintended widget overlap
- Keyboard-safe layouts
- Safe-area compatibility
- Accessible controls

---

## 🔒 Security Guidelines

Never commit:

```text
.env
*.env
access tokens
refresh tokens
passwords
API keys
private keys
keystore files
key.properties
```

Never hardcode production credentials inside the Flutter source code.

Use secure storage for authentication tokens.

---

## 🔄 Development Workflow

Create a feature branch:

```bash
git checkout -b feature/feature-name
```

Make your changes and test:

```bash
flutter analyze
flutter test
```

Stage changes:

```bash
git add .
```

Commit:

```bash
git commit -m "Add feature description"
```

Push:

```bash
git push -u origin feature/feature-name
```

Create a Pull Request on GitHub and merge into `main` after review.

---

## 📌 Current Development Status

### Completed

- Flutter application foundation
- Modern responsive UI/UX
- Authentication integration
- Dashboard
- Meeting management
- Meeting scheduling
- Meeting joining
- Pre-join experience
- Live meeting interface
- Participant management
- Meeting chat interface
- Settings
- Responsive/keyboard-aware layouts
- Debug APK verification

### Future / API-Dependent Work

Additional backend modules can be integrated as their API documentation becomes available.

The Flutter application should follow the backend team's latest API documentation rather than inventing or assuming undocumented endpoints.

---

## 👨‍💻 Repository

**GitHub:**

https://github.com/bablookumarmuz/ConnectSoar

---

## 📄 License

This project is currently intended for internal/team development.

License and distribution terms should be defined by the project owner/company.
