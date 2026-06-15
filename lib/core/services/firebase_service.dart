import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  // We remove isAvailable flag as Firebase is strictly required now.
  static bool get isAvailable => true; // Kept for backward compatibility if any lingering references exist temporarily.

  static Future<void> init() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);
      debugPrint('[FirebaseService] Firebase initialized successfully. Running in Cloud Mode.');
    } catch (e) {
      debugPrint('[FirebaseService] Firebase initialization failed: $e.');
    }
  }
}
