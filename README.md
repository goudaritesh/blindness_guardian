# Blindness Guardian Application

A Flutter Android application built with clean architecture using Provider state management and Firebase Realtime Database for real-time safety tracking of a visual impairment smart stick.

This MVP covers all base requirements:
- **Authentication**: Firebase Email/Password signup & login with persistent sessions.
- **Home Dashboard**: Modern, high-contrast Material dark theme UI with metrics and live data.
- **Real-time Map tracking**: Utilizing Google Maps Flutter & Provider.
- **Emergency Alert System**: Loud full-screen alerts triggered by Firebase updates.
- **Clean Architecture Models**: Abstracted Domain layers from UI Provider Layers.
- **Push Notifications Setup**: Handlers registered via Firebase Messaging.

## Prerequisites & Setup (Very Important)

Since `google-services.json` and external API keys are highly confidential and project-local:

### 1. Firebase Configuration
1. Go to Firebase Console -> Add a new project (`blindness_guardian`)
2. Add an Android app with the package name `com.blindnessguardian.blindness_guardian`
3. Download the `google-services.json` file and place it in `android/app/`.
4. Run `dart pub global run flutterfire_cli:flutterfire configure` to generate the correct cross-platform configuration.

### 2. Location & Navigation
This application uses **Native Navigation**. We have removed the reliance on the heavy Google Maps SDK and external API keys:
- The app fetches raw GPS coordinates from the Smart Stick via Firebase.
- When you click "Open in Maps", the app automatically launches your device's native navigation app (Google Maps, Apple Maps, etc.) with the exact coordinates pre-filled.
- **No Google Maps API Key or Cloud Billing is required.**
### 3. Firebase Services Activation
Ensure that you have enabled these services in your Firebase Console:
- **Authentication** (Email/Password Provider)
- **Realtime Database** (With correct Read/Write rules - default or Auth Only)
- **Storage** (To upload captured camera photos)

## Run the App
```bash
flutter pub get
flutter run
```

## IoT Integration (ESP32 Smart Stick)

To connect your Smart Stick to this app, the ESP32 must write directly to your Firebase Realtime Database:

### 1. Database Endpoints
- **Alerts**: `POST https://[PROJECT_ID].asia-southeast1.firebasedatabase.app/alerts.json`
  - Body: `{"type": "SOS", "timestamp": {".sv": "timestamp"}, "lat": 0.0, "lng": 0.0, "resolved": false}`
- **Live Location**: `POST https://[PROJECT_ID].asia-southeast1.firebasedatabase.app/location_logs/[DEVICE_ID].json`
  - Body: `{"lat": 12.34, "lng": 78.90}`
- **Device Status**: `PATCH https://[PROJECT_ID].asia-southeast1.firebasedatabase.app/device_status/[DEVICE_ID].json`
  - Body: `{"isOnline": true, "batteryLevel": 85, "lastSync": {".sv": "timestamp"}, "isSafe": true}`

### 2. Matching Device IDs
When you sign up in the app, the **Blind Stick Device ID** you enter must EXACTLY match the `[DEVICE_ID]` used in your ESP32 code (e.g., `stick_001`).

### 3. Alarm Sound
Place a file named `loud_alarm.mp3` inside `assets/audio/` so the app can play a sound during an emergency.
