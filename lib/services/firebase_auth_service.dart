// lib/services/firebase_auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isRegistering = false; // Add flag to prevent redirect during registration
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  FirebaseAuthService() {
    // Initialize with current user
    _currentUser = _auth.currentUser;
    
    debugPrint('🔐 Firebase Auth Service initialized');
    debugPrint('🔐 Current user: ${_currentUser?.email}');
    debugPrint('🔐 Initial auth state: isAuthenticated=${isAuthenticated}');
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      // Skip if this is during registration
      if (_isRegistering) {
        debugPrint('🔄 Skipping auth state change during registration');
        return;
      }
      
      // Only update if user actually changed
      if (_currentUser?.uid != user?.uid) {
        _currentUser = user;
        debugPrint('🔄 Auth state changed: user=${user?.email}, isAuthenticated=${isAuthenticated}');
        notifyListeners();
        _emitAuthState();
        
        if (user != null) {
          debugPrint('✅ Firebase User signed in: ${user.email}');
        } else {
          debugPrint('🔒 Firebase User signed out');
        }
      }
    });
    
    // Emit initial state after a short delay to ensure stability
    Future.delayed(const Duration(milliseconds: 100), () {
      _emitAuthState();
    });
  }

  void _emitAuthState() {
    _authStateController.add(AuthState(
      isAuthenticated: isAuthenticated,
      user: _currentUser?.email,
    ));
  }

  // Register new user with Firebase
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? licenceNumber,
    String? rcNumber,
  }) async {
    try {
      debugPrint('📝 Registering user: $email');
      
      // Set registration flag to prevent auth state changes from redirecting
      _isRegistering = true;
      
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name and photo
      await credential.user?.updateDisplayName(name);
      await credential.user?.updatePhotoURL('https://ui-avatars.com/api/?name=$name&background=random');
      await credential.user?.reload();
      
      debugPrint('✅ User registered successfully: ${credential.user?.email}');
      
      // IMPORTANT: Log out immediately after registration
      await _auth.signOut();
      _currentUser = null;
      debugPrint('🔒 User logged out after registration - needs to login');
      
      // Clear registration flag
      _isRegistering = false;
      
      // Store user data in Firestore in background (non-blocking)
      _storeUserDataInFirestore(credential.user!, name, userType, licenceNumber, rcNumber).catchError((e) {
        debugPrint('⚠️ Background Firestore storage failed: $e');
      });
      
      // Send email verification in background (don't block login)
      _sendEmailVerification().catchError((e) {
        debugPrint('⚠️ Email verification failed: $e');
      });
      
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      _isRegistering = false; // Clear flag on error
      debugPrint('❌ Firebase registration error: ${e.code}');
      
      // Handle specific Firebase errors
      if (e.code.contains('api-key') || e.code.contains('invalid')) {
        throw Exception('firebase-config-error');
      }
      
      throw Exception(e.code);
    } catch (e) {
      _isRegistering = false; // Clear flag on error
      debugPrint('❌ Unexpected registration error: $e');
      throw Exception('registration-failed');
    }
  }

  // Store user data in Firestore
  Future<void> _storeUserDataInFirestore(User user, String name, String userType, [String? licenceNumber, String? rcNumber]) async {
    try {
      debugPrint('💾 Storing user data in Firestore...');
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name,
        'userType': userType,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'status': 'active',
        // Add vendor-specific fields if provided
        if (licenceNumber != null) 'licenceNumber': licenceNumber,
        if (rcNumber != null) 'rcNumber': rcNumber,
        // Add role-based identification fields
        'role': userType, // 'farmer' or 'vendor' for easy querying
        'accountType': userType, // Additional field for clarity
        // Add search-friendly fields
        'searchTerms': [
          name.toLowerCase(),
          userType.toLowerCase(),
          if (licenceNumber != null) licenceNumber.toLowerCase(),
          if (rcNumber != null) rcNumber.toLowerCase(),
        ],
      });
      
      debugPrint('✅ User data stored in Firestore successfully');
    } catch (e) {
      debugPrint('❌ Error storing user data in Firestore: $e');
      // Don't throw error here - registration should still succeed even if Firestore fails
      // The user can still login, we'll retry storing data later
    }
  }

  // Login user with Firebase
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Logging in user: $email');
      
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure current user is updated immediately
      _currentUser = credential.user;
      debugPrint('✅ User logged in successfully: ${credential.user?.email}');
      debugPrint('🔐 Authentication state: isAuthenticated=${isAuthenticated}');
      notifyListeners();
      
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase login error: ${e.code}');
      throw Exception(e.code);
    } catch (e) {
      debugPrint('❌ Unexpected login error: $e');
      throw Exception('login-failed');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('🔑 Starting Google Sign-In');
      
      if (kIsWeb) {
        // For web, use Firebase Auth directly with Google provider
        debugPrint('🌐 Using Firebase Auth Google provider for web');
        
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        // Use signInWithPopup for web
        final userCredential = await _auth.signInWithPopup(googleProvider);
        _currentUser = userCredential.user;
        
        debugPrint('✅ Web Google Sign-In successful: ${_currentUser?.email}');
        debugPrint('🔐 Authentication state: isAuthenticated=${isAuthenticated}');
        
        // Explicitly emit auth state after Google Sign-In
        notifyListeners();
        _emitAuthState();
        
        // Store user data in Firestore if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          _storeUserDataInFirestore(
            userCredential.user!, 
            userCredential.user!.displayName ?? 'Google User', 
            'farmer'  // Default to farmer for Google sign-in users
          ).catchError((e) {
            debugPrint('⚠️ Background Firestore storage failed: $e');
          });
        }
        
        return userCredential;
      } else {
        // For mobile platforms, use google_sign_in package
        debugPrint('📱 Using GoogleSignIn package for mobile');
        
        final GoogleSignIn googleSignIn = GoogleSignIn();
        
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('google-sign-in-cancelled');
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        final userCredential = await _auth.signInWithCredential(credential);
        _currentUser = userCredential.user;
        
        debugPrint('✅ Mobile Google Sign-In successful: ${_currentUser?.email}');
        debugPrint('🔐 Authentication state: isAuthenticated=${isAuthenticated}');
        
        // Explicitly emit auth state after Google Sign-In
        notifyListeners();
        _emitAuthState();
        
        // Store user data in Firestore if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          _storeUserDataInFirestore(
            userCredential.user!, 
            userCredential.user!.displayName ?? 'Google User', 
            'farmer'  // Default to farmer for Google sign-in users
          ).catchError((e) {
            debugPrint('⚠️ Background Firestore storage failed: $e');
          });
        }
        
        return userCredential;
      }
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  // Send email verification
  Future<void> _sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('📧 Verification email sent to ${user.email}');
      }
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      rethrow;
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      
      // Sign out from Google Sign-In if not on web
      if (!kIsWeb) {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
        } catch (e) {
          debugPrint('Google Sign-In not configured, skipping: $e');
        }
      }
      
      _currentUser = null;
      debugPrint('👋 User logged out successfully');
      notifyListeners();
      _emitAuthState();
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // Still emit auth state even if logout partially fails
      _currentUser = null;
      notifyListeners();
      _emitAuthState();
      throw Exception('logout-failed');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('📧 Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');
      throw Exception(e.code);
    }
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    try {
      await _currentUser?.updateDisplayName(name);
      await _currentUser?.reload();
      _currentUser = _auth.currentUser;
      notifyListeners();
      _emitAuthState();
      debugPrint('✅ Display name updated to: $name');
    } catch (e) {
      debugPrint('❌ Update display name error: $e');
      throw Exception('update-display-name-failed');
    }
  }

  // Update profile photo URL
  Future<void> updatePhotoUrl(String url) async {
    try {
      await _currentUser?.updatePhotoURL(url);
      await _currentUser?.reload();
      _currentUser = _auth.currentUser;
      notifyListeners();
      _emitAuthState();
      debugPrint('✅ Photo URL updated');
    } catch (e) {
      debugPrint('❌ Update photo URL error: $e');
      throw Exception('update-photo-url-failed');
    }
  }

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user display name
  String? get userDisplayName => currentUser?.displayName;

  // Get user ID
  String? get userId => currentUser?.uid;

  // Update authentication state after registration popup
  Future<void> updateAuthStateAfterRegistration() async {
    _currentUser = _auth.currentUser;
    debugPrint('🔐 Updating auth state after popup: isAuthenticated=${isAuthenticated}');
    debugPrint('🔐 Current user: ${_currentUser?.email}');
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
