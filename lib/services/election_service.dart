
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ElectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // All authenticated students see the same elections.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchElections() {
    return _db.collection('elections').snapshots();
  }

  // All students see the same candidates for an election.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCandidates(
      String electionId,
      ) {
    return _db
        .collection('elections')
        .doc(electionId)
        .collection('candidates')
        .snapshots();
  }

  // Submit one vote per authenticated account per election.
  Future<void> castVote({
    required String electionId,
    required String candidateId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please log in before voting.');
    }

    final voteRef = _db
        .collection('elections')
        .doc(electionId)
        .collection('votes')
        .doc(user.uid);

    await voteRef.set({
      'candidateId': candidateId,
      'votedAt': FieldValue.serverTimestamp(),
    });
  }

  // Read published results after the election closes.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchResults(
      String electionId,
      ) {
    return _db
        .collection('elections')
        .doc(electionId)
        .collection('results')
        .snapshots();
  }
}
