# MindFlow

MindFlow is a production-style Flutter Android MVP for emotional support, journaling, mood tracking, voice notes, photo memories, and anonymous student community support.

## Stack

- Flutter + Dart null safety
- Firebase Auth with email/password, Google Sign-In, email verification, session persistence, logout
- Cloud Firestore realtime collections
- Firebase Storage for voice journals and photo memories
- Riverpod state management
- GoRouter navigation
- Material 3 dark premium UI

## Firestore Collections

- `users`: `uid`, `username`, `email`, `avatar`, timestamps
- `journals`: private CRUD journal entries with mood and optional photo URL
- `moods`: private mood logs with intensity, note, timestamps
- `ai_chats`: private chat messages with AI/user flag and timestamps
- `voice_journals`: private uploaded audio metadata
- `photo_memories`: private uploaded emotional photos
- `community_posts`: anonymous realtime feed posts and support reactions

## Firebase Setup

This repository already includes `lib/firebase_options.dart` and `android/app/google-services.json`. For a new Firebase project:

1. Create a Firebase project.
2. Enable Authentication providers: Email/Password and Google.
3. Enable Cloud Firestore and Firebase Storage.
4. Run `flutterfire configure`.
5. Replace `android/app/google-services.json`.
6. Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

## Build

```bash
flutter pub get
flutter test
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Notes

MindFlow is not a therapy replacement. The AI chat uses an empathetic local response engine for MVP safety and can later be connected to a moderated AI backend.
