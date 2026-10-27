class Candidate {
  Candidate({required this.id, required this.name, required this.manifesto, this.votes = 0});
  final int id;
  String name;
  String manifesto;
  int votes;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'manifesto': manifesto, 'votes': votes,
  };

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    manifesto: json['manifesto'] as String,
    votes: (json['votes'] as num).toInt(),
  );
}
