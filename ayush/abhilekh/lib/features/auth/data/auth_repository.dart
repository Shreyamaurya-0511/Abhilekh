import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  // Stream used by Bloc to check if user is logged in
  Stream<User?> get userStream => auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Authentication Failed");
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> register(String email, String password) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      
      if (user != null) {
        // Create user document in Firestore
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'currentStatus': 'INSIDE',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration Failed");
    }
  }
}