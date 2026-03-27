import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({required this.isAvailable, this.message});

  final bool isAvailable;
  final String? message;
}

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<FirebaseBootstrapResult> initialize() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      return const FirebaseBootstrapResult(
        isAvailable: false,
        message:
            'Firebase is not configured yet. Run `flutterfire configure` and '
            'replace lib/firebase_options.dart to enable account features.',
      );
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (error) {
      return FirebaseBootstrapResult(
        isAvailable: false,
        message: 'Firebase initialization failed: $error',
      );
    }

    return const FirebaseBootstrapResult(isAvailable: true);
  }
}
