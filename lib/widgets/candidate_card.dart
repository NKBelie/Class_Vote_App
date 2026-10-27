import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../theme/app_theme.dart';

class CandidateCard extends StatelessWidget {
  const CandidateCard({super.key, required this.candidate, this.onEdit, this.onDelete, this.compact = false});
  final Candidate candidate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final initials = candidate.name.trim().split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase()).join();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 25, backgroundColor: lightPurple,
            child: Text(initials, style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(candidate.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkPurple)),
            const SizedBox(height: 6),
            Text(candidate.manifesto, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Text('${candidate.votes} vote${candidate.votes == 1 ? '' : 's'}',
                style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.w600)),
            if (!compact) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: const Text('Edit')),
                TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red))),
              ]),
            ],
          ])),
        ]),
      ),
    );
  }
}
