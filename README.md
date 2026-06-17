# Aquacare CRM

Aquacare CRM is an Android-first Flutter CRM app for a water filter business. It uses GetX, Clean Architecture, Firebase Authentication, Google Sign-In, Cloud Firestore, and SQLite with an offline-first sync queue.

## Implemented scope

- Google Sign-In with Firebase Auth
- Pending approval flow for newly signed-in users
- Role-based dashboards for owner, employee, and technician
- Local SQLite source of truth for users, customers, installations, services, and sync queue
- Cloud sync to Firestore with retryable pending/failed queue states
- Customer create/update/delete rules based on role
- Installation entry flow
- Service request creation and technician updates
- User approval and role management
- Audit log listing
- Search by customer name, mobile number, area, and installation serial number
- Offline banner, sync badges, loading states, and empty states

## Stack

- Flutter
- Dart
- GetX
- Firebase Core
- Firebase Auth
- Google Sign-In
- Cloud Firestore
- SQLite via `sqflite`
- `connectivity_plus`
- `uuid`
- `intl`

## Android package ID

The project is configured for:

`com.aquacare.crm`

Update your Firebase Android app registration to use that exact package name.

## Firebase setup

1. Create a Firebase project.
2. Add an Android app with package name `com.aquacare.crm`.
3. Download `google-services.json`.
4. Place `google-services.json` in:

`android/app/google-services.json`

5. Enable Google sign-in in Firebase Authentication.
6. Add your debug and release SHA-1/SHA-256 fingerprints in Firebase.
7. Replace the placeholder values in [lib/firebase_options.dart](/D:/My%20Projects/aquacare_crm/lib/firebase_options.dart) or generate the real file with FlutterFire and copy the Android section into this project.

Recommended generated command on your machine:

```bash
flutterfire configure --project=<your-project-id> --platforms=android
```

If you prefer not to use FlutterFire CLI, manually replace:

- `apiKey`
- `appId`
- `messagingSenderId`
- `projectId`
- `storageBucket`

inside [lib/firebase_options.dart](/D:/My%20Projects/aquacare_crm/lib/firebase_options.dart).

## First owner bootstrap

The app supports multiple owners.

For the very first owner in a new Firebase project:

1. Sign in once with Google.
2. The app creates `users/{uid}` with:
   - `role: pending`
   - `status: pending`
3. Open Firestore and manually update that document to:
   - `role: owner`
   - `status: approved`
4. Reopen the app or tap refresh on the waiting screen.

After that, approved owners can:

- approve pending users
- assign roles
- promote more owners
- block users

## Firestore collections

- `users/{uid}`
- `customers/{customerId}`
- `installations/{installationId}`
- `service_requests/{serviceId}`
- `audit_logs/{logId}`

## Firestore security rules

Deploy the rules from [firestore.rules](/D:/My%20Projects/aquacare_crm/firestore.rules).

Typical command:

```bash
firebase deploy --only firestore:rules
```

## Local verification steps for you

Run these locally after adding Firebase config:

```bash
flutter pub get
flutter analyze
flutter build apk
```

If `flutter analyze` reports issues, send me the analyzer output and I’ll fix them.

## Project structure

Key folders:

- `lib/core`
- `lib/data`
- `lib/features/auth`
- `lib/features/users`
- `lib/features/customers`
- `lib/features/installations`
- `lib/features/services`
- `lib/features/dashboard`

## Notes

- This version does not include AMC tracking.
- This version does not include photo or document upload.
- The app is implemented for Android usage only.
- Non-Android Flutter folders remain generated but are not part of the CRM implementation.
