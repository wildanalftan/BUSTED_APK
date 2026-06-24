import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/notification_service.dart';

class UsersNotifier extends Notifier<List<UserEntity>> {
  @override
  List<UserEntity> build() {
    _loadUsers();
    return [];
  }

  Future<void> _loadUsers() async {
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserEntity(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          isAdmin: data['isAdmin'] ?? false,
          isBlocked: data['isBlocked'] ?? false,
        );
      }).toList();
      state = users;
    });
  }

  Future<bool> registerUser(UserEntity user) async {
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email, 
        password: user.password
      );
      if (cred.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set(user.toJson());
      }
      return true;
    } catch (e) {
      debugPrint('Firebase registration failed: $e');
      return false;
    }
  }

  Future<void> toggleBlockUser(String email) async {
    try {
      final query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
      for (var doc in query.docs) {
        final currentBlock = doc.data()['isBlocked'] ?? false;
        await doc.reference.update({'isBlocked': !currentBlock});
      }
    } catch(e) {
      debugPrint('Failed to toggle block: $e');
    }
  }

  Future<void> clearAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Failed to clear users: $e');
    }
  }
}

final usersProvider = NotifierProvider<UsersNotifier, List<UserEntity>>(() {
  return UsersNotifier();
});

class CurrentUserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    _loadSession();
    return null;
  }

  Future<void> _loadSession() async {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = null;
      } else {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists) {
              final data = doc.data()!;
              final u = UserEntity(
                name: data['name'] ?? '',
                email: data['email'] ?? '',
                password: data['password'] ?? '',
                isAdmin: data['isAdmin'] ?? false,
                isBlocked: data['isBlocked'] ?? false,
                fcmToken: data['fcmToken'] as String?,
              );
              if (u.isBlocked) {
                await FirebaseAuth.instance.signOut();
                state = null;
              } else {
                state = u;
                _updateFcmToken(firebaseUser.uid);
              }
          } else {
              state = UserEntity(name: 'User', email: firebaseUser.email ?? '', password: '');
          }
        } catch(e) {
          debugPrint('Failed fetching user profile: $e');
          state = null;
        }
      }
    });
  }

  Future<void> _updateFcmToken(String uid) async {
    try {
      final token = await LocalNotificationService.getFcmToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
        });
        debugPrint('Successfully updated FCM token for user $uid in Firestore');
      }
    } catch (e) {
      debugPrint('Failed to update FCM token in Firestore: $e');
    }
  }

  Future<String?> loginWithCredentials(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // Explicitly fetch user doc to ensure state is ready for routing
      if (cred.user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final u = UserEntity(
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            password: data['password'] ?? '',
            isAdmin: data['isAdmin'] ?? false,
            isBlocked: data['isBlocked'] ?? false,
            fcmToken: data['fcmToken'] as String?,
          );
          if (u.isBlocked) {
            await FirebaseAuth.instance.signOut();
            return 'Your account has been blocked by the Administrator.';
          }
          state = u;
          _updateFcmToken(cred.user!.uid);
        } else {
          state = UserEntity(name: 'User', email: email, password: '');
        }
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') return 'Account not found or incorrect password!';
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  Future<void> login(UserEntity user) async {
    // Kept for backward compatibility if any old logic calls this. 
    state = user;
  }

  Future<void> logout() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({
          'fcmToken': FieldValue.delete(),
        });
        debugPrint('Successfully cleared FCM token on logout');
      } catch (e) {
        debugPrint('Failed to clear FCM token on logout: $e');
      }
    }
    await FirebaseAuth.instance.signOut();
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, UserEntity?>(() {
  return CurrentUserNotifier();
});
