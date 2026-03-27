import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';

final firebaseBootstrapProvider = Provider<FirebaseBootstrapResult>(
  (ref) => const FirebaseBootstrapResult(
    isAvailable: false,
    message: 'Firebase has not been initialized. Check main() bootstrap setup.',
  ),
);
