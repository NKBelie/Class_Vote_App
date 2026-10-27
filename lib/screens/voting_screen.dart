import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key, required this.candidates, required this.hasVoted,
    required this.selectedCandidateId, required this.onSelect, required this.onConfirm,
    required this.onCandidates});
  final List<Candidate> candidates;
  final bool hasVoted;
  final int? selectedCandidateId;
  final void Function(int) onSelect;
  final VoidCallback onConfirm;
  final VoidCallback onCandidates;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Cast your vote', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkPurple)),
    const Text('Choose one candidate to lead your class.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    if (hasVoted)
      const EmptyState(icon: Icons.check_circle, title: 'Vote recorded!',
          description: 'Thank you for participating. You have already voted on this device.')
    else if (candidates.isEmpty)
      EmptyState(icon: Icons.how_to_vote_outlined, title: 'Voting is not available',
          description: 'Register candidates before voting.',
          action: FilledButton(onPressed: onCandidates, child: const Text('Manage candidates')))
    else ...[
      const Card(child: Padding(padding: EdgeInsets.all(16),
          child: Text('Select one candidate, then review your choice before confirming.',
              style: TextStyle(color: darkPurple)))),
      const SizedBox(height: 14),
      ...candidates.map((candidate) {
        final selected = selectedCandidateId == candidate.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            color: selected ? lightPurple : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelect(candidate.id),
              child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                CircleAvatar(backgroundColor: selected ? primaryPurple : lightPurple,
                  child: Icon(selected ? Icons.check : Icons.person_outline,
                      color: selected ? Colors.white : primaryPurple)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(candidate.name, style: const TextStyle(fontWeight: FontWeight.bold, color: darkPurple)),
                  const SizedBox(height: 4),
                  Text(candidate.manifesto, style: const TextStyle(color: Colors.black54)),
                ])),
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: primaryPurple),
              ])),
            ),
          ),
        );
      }),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: onConfirm, icon: const Icon(Icons.how_to_vote), label: const Text('Confirm my vote')),
    ],
  ]);
}
