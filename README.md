# 📱 Social Connect

A modern Flutter-based social networking app built as part of my internship project.  
The app provides user authentication, profile management, post sharing (text + images), likes, comments, and Firebase integration.

---

## 🚀 Features
✅ **Authentication**
- Email & password signup/login using Firebase Auth
- Password reset functionality

✅ **User Profiles**
- View and edit profile (name, bio, profile image)
- Persistent storage in Firebase Firestore

✅ **Posts**
- Create, upload, and preview posts (text + images)
- Real-time updates from Firestore

✅ **Engagement**
- Like and comment on posts
- Data synced via Firebase Cloud Firestore

✅ **App Settings**
- Logout functionality
- Custom splash screen

---

## 🛠️ Tech Stack
- **Flutter** (Dart)
- **Firebase** (Auth, Firestore, Storage)
- **Kotlin DSL + Gradle 8** (for Android builds)
- **Clean UI** with Material Design principles

---

## 📂 Project Structure
lib/
├── main.dart
├── screens/
│ ├── login_screen.dart
│ ├── signup_screen.dart
│ ├── home_screen.dart
│ ├── profile_screen.dart
│ ├── create_post_screen.dart
│ ├── post_feed_screen.dart
│ └── settings_screen.dart
├── widgets/
│ ├── custom_text_field.dart
│ ├── post_card.dart
│ └── profile_avatar.dart


---

## 🔧 Installation & Setup
1. Clone this repo:
   ```bash
   git clone https://github.com/<your-username>/social_connect.git
   cd social_connect


Get dependencies:

flutter pub get


Add your Firebase config:

Place google-services.json inside android/app/

Place GoogleService-Info.plist inside ios/Runner/ (for iOS)

Run the app:

flutter run
