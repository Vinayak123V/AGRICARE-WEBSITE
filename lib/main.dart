import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'agricare_app.dart';
import 'firebase_options.dart';

// Set this to true to use Firebase Authentication
// Set this to false to use Mock Authentication (for testing without Firebase)
const bool USE_FIREBASE_AUTH = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Starting AgriCare App...');
  
  bool useFirebaseAuth = USE_FIREBASE_AUTH;
  
  // Always initialize Firebase so Firestore and other services work,
  // even when we are using mock authentication.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase initialized successfully');
    if (USE_FIREBASE_AUTH) {
      debugPrint('🔐 Using FIREBASE Authentication');
    } else {
      debugPrint('🌐 Using MOCK Authentication (Demo Mode)');
      useFirebaseAuth = false;
    }
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('⚠️  Falling back to MOCK Authentication only');
    useFirebaseAuth = false;
  }

  // Set preferred app size for desktop/web
  if (kIsWeb) {
    // Set a fixed size for web to simulate desktop experience
    debugPrint('🖥️  Setting web app size to 1366x768');
  }

  runApp(AgriCareApp(useFirebaseAuth: useFirebaseAuth));
}
