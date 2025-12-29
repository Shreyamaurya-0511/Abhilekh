import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import 'campus_guard_service.dart';

class AttendanceRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final CampusGuardService campusGuard;

  AttendanceRepository({
    required this.firestore,
    required this.auth,
    required this.campusGuard,
  });

  Future<void> markAttendance({required bool isEntry}) async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Validate Hardware
    await campusGuard.validatePresence();

    // 2. Prepare Data
    final timestamp = FieldValue.serverTimestamp();
    final type = isEntry ? 'ENTRY' : 'EXIT';
    
    final batch = firestore.batch();
    final userRef = firestore.collection(AppConstants.collectionUsers).doc(user.uid);
    final logRef = firestore.collection(AppConstants.collectionLogs).doc();

    // Update User Status
    batch.update(userRef, {
      'currentStatus': isEntry ? 'INSIDE' : 'OUTSIDE',
      'lastUpdated': timestamp,
    });

    // Create Log Entry
    batch.set(logRef, {
      'uid': user.uid,
      'email': user.email,
      'type': type,
      'timestamp': timestamp,
    });

    await batch.commit();
  }

  Future<String> getUserStatus() async {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await firestore.collection(AppConstants.collectionUsers).doc(user.uid).get();
    if (!doc.exists) throw Exception("User document not found");

    return doc['currentStatus'] ?? 'OUTSIDE';
  }
}