# Firebase Setup

This auth implementation is wired for FlutterFire, but the project is not connected
to a real Firebase project yet.

Required setup:

1. Enable Developer Mode on Windows if you need `flutter pub get` to finish plugin linking locally.
2. Create a Firebase project with:
   - Authentication
   - Email/password provider enabled
   - Google provider enabled
   - Cloud Firestore enabled
3. Run `flutterfire configure` from the repo root.
4. Replace [lib/firebase_options.dart](/d:/projects/Tsion-Ethiopian-Orthodox-Daily-/lib/firebase_options.dart) with the generated file.
5. Keep the generated native platform config files that `flutterfire configure` creates for Android, iOS, and Web.

Firestore collection used by this implementation:

- `user_profiles/{uid}`
  - `displayName`
  - `email`
  - `calendarDisplayMode`
  - `updatedAt`
