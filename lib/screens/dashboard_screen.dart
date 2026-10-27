import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/candidate_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.candidates, required this.hasVoted,
    required this.onVote, required this.onCandidates, required this.onResults});
  final List<Candidate> candidates;
  final bool hasVoted;
  final VoidCallback onVote;
  final VoidCallback onCandidates;
  final VoidCallback onResults;

  @override
  Widget build(BuildContext context) {
    final totalVotes = candidates.fold<int>(0, (sum, c) => sum + c.votes);
    return ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR VOICE MATTERS', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text('Choose your\nclass leader.', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Explore the candidates and make your vote count.', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: onVote, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryPurple),
              icon: const Icon(Icons.how_to_vote), label: Text(hasVoted ? 'View election' : 'Vote now')),
        ]),
      ),
      const SizedBox(height: 24),
      const Text('Election overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkPurple)),
      const SizedBox(height: 12),
      Row(children: [
        StatCard(label: 'Candidates', value: '${candidates.length}', icon: Icons.groups),
        const SizedBox(width: 10),
        StatCard(label: 'Votes cast', value: '$totalVotes', icon: Icons.how_to_vote, color: const Color(0xFF14866D)),
      ]),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Meet the candidates', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: darkPurple)),
        TextButton(onPressed: onCandidates, child: const Text('View all')),
      ]),
      if (candidates.isEmpty)
        EmptyState(icon: Icons.groups_outlined, title: 'No candidates yet',
            description: 'Add candidates to get your class election started.',
            action: FilledButton(onPressed: onCandidates, child: const Text('Manage candidates')))
      else
        ...candidates.take(3).map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: CandidateCard(candidate: c, compact: true))),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: onResults, icon: const Icon(Icons.bar_chart), label: const Text('View election results')),
    ]);
  }
}
