import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/candidate_card.dart';
import '../widgets/empty_state.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key, required this.candidates, required this.onAdd, required this.onEdit, required this.onDelete});
  final List<Candidate> candidates;
  final VoidCallback onAdd;
  final void Function(Candidate) onEdit;
  final void Function(Candidate) onDelete;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Manage candidates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkPurple)),
    const Text('Add, update, and remove election candidates.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add new candidate')),
    const SizedBox(height: 20),
    Text('${candidates.length} candidate${candidates.length == 1 ? '' : 's'} registered',
        style: const TextStyle(fontWeight: FontWeight.bold, color: darkPurple)),
    const SizedBox(height: 14),
    if (candidates.isEmpty)
      EmptyState(icon: Icons.groups_outlined, title: 'No candidates registered',
          description: 'Add the first candidate before starting the election.',
          action: FilledButton(onPressed: onAdd, child: const Text('Add candidate')))
    else
      ...candidates.map((candidate) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: CandidateCard(candidate: candidate,
          onEdit: () => onEdit(candidate), onDelete: () => onDelete(candidate)),
      )),
  ]);
}
