import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.candidates, required this.onReset, required this.onCandidates});
  final List<Candidate> candidates;
  final VoidCallback onReset;
  final VoidCallback onCandidates;

  @override
  Widget build(BuildContext context) {
    final ranked = List<Candidate>.from(candidates)..sort((a, b) => b.votes.compareTo(a.votes));
    final total = candidates.fold<int>(0, (sum, c) => sum + c.votes);
    final leaders = ranked.where((c) => total > 0 && c.votes == ranked.first.votes).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Election results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkPurple)),
      const Text('Vote totals, percentages, and candidate rankings.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      Row(children: [
        StatCard(label: 'Total votes', value: '$total', icon: Icons.how_to_vote),
        const SizedBox(width: 10),
        StatCard(label: 'Candidates', value: '${candidates.length}', icon: Icons.groups, color: const Color(0xFF14866D)),
      ]),
      const SizedBox(height: 22),
      if (ranked.isEmpty)
        EmptyState(icon: Icons.bar_chart, title: 'No results available',
          description: 'Register candidates and record votes to see election results.',
          action: FilledButton(onPressed: onCandidates, child: const Text('Manage candidates')))
      else ...[
        const Text('Candidate rankings', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: darkPurple)),
        if (total == 0) const Padding(padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('No votes have been cast yet.', style: TextStyle(color: Colors.black54))),
        const SizedBox(height: 12),
        ...ranked.asMap().entries.map((entry) {
          final index = entry.key;
          final candidate = entry.value;
          final percentage = total == 0 ? 0.0 : candidate.votes / total;
          final tied = total > 0 && ranked.where((c) => c.votes == candidate.votes).length > 1;
          return Padding(padding: const EdgeInsets.only(bottom: 13), child: Card(
            child: Padding(padding: const EdgeInsets.all(17), child: Column(children: [
              Row(children: [
                CircleAvatar(backgroundColor: lightPurple, child: Text('#${index + 1}', style: const TextStyle(color: primaryPurple))),
                const SizedBox(width: 12),
                Expanded(child: Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.bold, color: darkPurple))),
                Text('${(percentage * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple)),
              ]),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: percentage, minHeight: 9, borderRadius: BorderRadius.circular(10),
                  backgroundColor: lightPurple, color: primaryPurple),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${candidate.votes} vote${candidate.votes == 1 ? '' : 's'}'),
                if (tied) const Text('Tied', style: TextStyle(color: primaryPurple)),
              ]),
            ])),
          ));
        }),
        if (total > 0) Card(color: lightPurple, child: Padding(padding: const EdgeInsets.all(18),
          child: Row(children: [
            const Icon(Icons.emoji_events, color: primaryPurple),
            const SizedBox(width: 12),
            Expanded(child: Text(leaders.length == 1
              ? 'Current leader: ${leaders.first.name}'
              : 'The election is tied', style: const TextStyle(color: darkPurple, fontWeight: FontWeight.bold))),
          ]))),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: onReset, icon: const Icon(Icons.restart_alt), label: const Text('Reset election votes')),
      ],
    ]);
  }
}
