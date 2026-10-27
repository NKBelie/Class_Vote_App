import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/candidate.dart';

class ElectionData {
  const ElectionData({required this.candidates, required this.nextId, required this.hasVoted});
  final List<Candidate> candidates;
  final int nextId;
  final bool hasVoted;
}

class ElectionStorage {
  static const _key = 'classvote_election_v1';

  static Future<ElectionData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final candidates = (data['candidates'] as List<dynamic>)
        .map((item) => Candidate.fromJson(item as Map<String, dynamic>))
        .toList();
    final highestId = candidates.fold<int>(0, (max, c) => c.id > max ? c.id : max);
    final storedNextId = (data['nextId'] as num).toInt();
    return ElectionData(
      candidates: candidates,
      nextId: storedNextId > highestId ? storedNextId : highestId + 1,
      hasVoted: data['hasVoted'] as bool,
    );
  }

  static Future<void> save(ElectionData election) async {
    final prefs = await SharedPreferences.getInstance();
    final value = jsonEncode({
      'candidates': election.candidates.map((c) => c.toJson()).toList(),
      'nextId': election.nextId,
      'hasVoted': election.hasVoted,
    });
    final saved = await prefs.setString(_key, value);
    if (!saved) throw StateError('Unable to save election data');
  }
}
