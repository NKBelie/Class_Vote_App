
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CandidateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _candidates {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must log in first.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('candidates');
  }

  Future<void> addCandidate({
    required String name,
    required String position,
  }) async {
    final candidateName = name.trim();
    final candidatePosition = position.trim();

    if (candidateName.isEmpty || candidatePosition.isEmpty) {
      throw ArgumentError('Name and position are required.');
    }

    await _candidates.add({
      'name': candidateName,
      'position': candidatePosition,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCandidates() {
    return _candidates.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateCandidate({
    required String id,
    required String name,
    required String position,
  }) async {
    await _candidates.doc(id).update({
      'name': name.trim(),
      'position': position.trim(),
    });
  }

  Future<void> deleteCandidate(String id) async {
    await _candidates.doc(id).delete();
  }
}
