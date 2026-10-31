import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  Candidate({
    required this.id,
    required this.name,
    required this.manifesto,
    this.votes = 0,
  });

  final String id;
  String name;
  String manifesto;
  int votes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'manifesto': manifesto,
    'votes': votes,
  };

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'].toString(),
      name: json['name'] as String,
      manifesto: json['manifesto'] as String,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
    );
  }

  factory Candidate.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return Candidate(
      id: document.id,
      name: data['name'] as String? ?? '',
      manifesto: data['manifesto'] as String? ?? '',
      votes: 0,
    );
  }
}
