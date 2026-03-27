import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase/firebase_bootstrap.dart';
import '../../models/calendar_display_mode.dart';
import '../models/auth_models.dart';

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirebaseAccountRepository {
  FirebaseAccountRepository({
    required FirebaseBootstrapResult bootstrap,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _bootstrap = bootstrap,
       _auth = auth,
       _firestore = firestore;

  static const _profilesCollection = 'user_profiles';

  final FirebaseBootstrapResult _bootstrap;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  bool get isAvailable => _bootstrap.isAvailable;

  String? get unavailableMessage => _bootstrap.message;

  Stream<AuthUser?> authStateChanges() {
    if (!isAvailable) {
      return Stream<AuthUser?>.value(null);
    }
    return _authInstance.authStateChanges().map(_mapUser);
  }

  Future<AuthSession> loadSession() async {
    if (!isAvailable) {
      return AuthSession.signedOut(message: unavailableMessage);
    }

    final user = _authInstance.currentUser;
    if (user == null) {
      return AuthSession.signedOut();
    }

    final authUser = _mapUser(user);
    if (authUser == null) {
      return AuthSession.signedOut();
    }

    final preferences = await _loadOrSeedPreferences(
      user: user,
      fallbackMode: CalendarDisplayMode.ethiopian,
    );

    return AuthSession.signedIn(user: authUser, preferences: preferences);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required CalendarDisplayMode fallbackMode,
  }) async {
    _ensureAvailable();
    final credential = await _authInstance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthRepositoryException('Unable to load the signed-in user.');
    }
    await _loadOrSeedPreferences(user: user, fallbackMode: fallbackMode);
  }

  Future<void> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    _ensureAvailable();
    final credential = await _authInstance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthRepositoryException('Unable to create the new account.');
    }

    await user.updateDisplayName(displayName.trim());
    await _saveProfileDocument(
      uid: user.uid,
      email: user.email,
      displayName: displayName.trim(),
      calendarDisplayMode: calendarDisplayMode,
    );
  }

  Future<void> signInWithGoogle({
    required CalendarDisplayMode fallbackMode,
  }) async {
    _ensureAvailable();

    UserCredential credential;
    if (kIsWeb) {
      credential = await _authInstance.signInWithPopup(GoogleAuthProvider());
    } else {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      credential = await _authInstance.signInWithCredential(authCredential);
    }

    final user = credential.user;
    if (user == null) {
      throw const AuthRepositoryException('Unable to complete Google sign-in.');
    }

    await _loadOrSeedPreferences(user: user, fallbackMode: fallbackMode);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _ensureAvailable();
    await _authInstance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    if (!isAvailable) {
      return;
    }

    await _authInstance.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore provider-specific sign-out issues after Firebase sign-out.
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    _ensureAvailable();
    final user = _authInstance.currentUser;
    if (user == null) {
      throw const AuthRepositoryException('You must be signed in first.');
    }

    await user.updateDisplayName(displayName.trim());
    await _saveProfileDocument(
      uid: user.uid,
      email: user.email,
      displayName: displayName.trim(),
      calendarDisplayMode: calendarDisplayMode,
    );
  }

  Future<void> updateCalendarDisplayMode(
    CalendarDisplayMode calendarDisplayMode,
  ) async {
    _ensureAvailable();
    final user = _authInstance.currentUser;
    if (user == null) {
      throw const AuthRepositoryException('You must be signed in first.');
    }

    await _profiles.doc(user.uid).set({
      'calendarDisplayMode': calendarDisplayMode.storageValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<AccountPreferences> _loadOrSeedPreferences({
    required User user,
    required CalendarDisplayMode fallbackMode,
  }) async {
    final snapshot = await _profiles.doc(user.uid).get();
    if (snapshot.exists) {
      final data = snapshot.data();
      return AccountPreferences(
        calendarDisplayMode: calendarDisplayModeFromStorage(
          data?['calendarDisplayMode'] as String?,
        ),
      );
    }

    final seededName = (user.displayName ?? '').trim();
    await _saveProfileDocument(
      uid: user.uid,
      email: user.email,
      displayName: seededName.isEmpty
          ? _fallbackDisplayName(user.email)
          : seededName,
      calendarDisplayMode: fallbackMode,
    );
    return AccountPreferences(calendarDisplayMode: fallbackMode);
  }

  Future<void> _saveProfileDocument({
    required String uid,
    required String? email,
    required String displayName,
    required CalendarDisplayMode calendarDisplayMode,
  }) async {
    await _profiles.doc(uid).set({
      'displayName': displayName,
      'email': email,
      'calendarDisplayMode': calendarDisplayMode.storageValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestoreInstance.collection(_profilesCollection);

  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestoreInstance =>
      _firestore ?? FirebaseFirestore.instance;

  void _ensureAvailable() {
    if (!isAvailable) {
      throw AuthRepositoryException(
        unavailableMessage ?? 'Firebase is not configured for this app yet.',
      );
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
      providers: user.providerData.map((entry) => entry.providerId).toList(),
    );
  }

  String _fallbackDisplayName(String? email) {
    if (email == null || email.isEmpty || !email.contains('@')) {
      return 'Tsion User';
    }
    return email.split('@').first;
  }
}
