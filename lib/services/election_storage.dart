import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candidate.dart';

class ElectionData {
  ElectionData({
    required this.candidates,
    required this.nextId,
    required this.hasVoted,
  });

  final List<Candidate> candidates;

  // Legacy field retained for older code compatibility.
  // Firestore generates its own string document IDs.
  final int nextId;

  // Legacy local flag. Not authoritative for shared voting.
  final bool hasVoted;
}

class ElectionStorage {
  static const String _storageKey = 'classvote_election_data';

  static Future<ElectionData?> load() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(storedData);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid election data.');
    }

    final rawCandidates = decoded['candidates'];

    final candidates = rawCandidates is List
        ? rawCandidates
        .map(
          (item) => Candidate.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList()
        : <Candidate>[];

    final storedNextId = decoded['nextId'];

    final nextId = storedNextId is num
        ? storedNextId.toInt()
        : 1;

    return ElectionData(
      candidates: candidates,
      nextId: nextId,
      hasVoted: decoded['hasVoted'] == true,
    );
  }

  static Future<void> save(ElectionData data) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode({
      'candidates': data.candidates
          .map((candidate) => candidate.toJson())
          .toList(),
      'nextId': data.nextId,
      'hasVoted': data.hasVoted,
    });

    await preferences.setString(_storageKey, encoded);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
