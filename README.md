# Niramay Clinic

Niramay Clinic is a Flutter + Firebase mobile app for day-to-day clinic operations, including patient records, appointments, and visit tracking.

## Features

- Firebase authentication (login/logout)
- Patient management (add, edit, list, delete)
- Appointment management (add, edit, list, delete)
- Visit management (add, edit, list, delete)
- Patient-wise visit history flow
- Dashboard with date-wise appointments

## Tech Stack

- Flutter (Dart)
- Firebase Auth
- Cloud Firestore
- BLoC (`flutter_bloc`)
- GoRouter
- GetIt

## Project Structure

```text
lib/
  app/                 # app shell, router, theme
  features/
    auth/
    dashboard/
    patients/
    appointments/
    visit/
    common/
  utils/
```

## Getting Started

1. Install Flutter SDK and platform tooling (Android Studio/Xcode).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase for your own project:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (generated with FlutterFire CLI)
4. Run the app:
   ```bash
   flutter run
   ```

## Firestore Note

For patient-wise visits, if you query by `patientId` and sort by `visitDate`, Firestore may require a composite index.

## Contributing

1. Create a feature branch.
2. Make changes and test on simulator/device.
3. Open a pull request with a clear description.
