import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/candidate_card.dart';
import '../widgets/empty_state.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({
    super.key,
    required this.candidates,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin = false,
    this.electionStatus = 'draft',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Candidate> candidates;
  final VoidCallback onAdd;
  final void Function(Candidate) onEdit;
  final void Function(Candidate) onDelete;

  final bool isAdmin;
  final String electionStatus;
  final bool isLoading;
  final String? errorMessage;

  bool get canManage => isAdmin && electionStatus == 'draft';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Candidates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explore candidates participating in the class election.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: lightPurple,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: primaryPurple,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  electionStatus == 'active'
                      ? 'Voting is currently open.'
                      : electionStatus == 'closed'
                      ? 'This election has ended.'
                      : 'Candidates are being prepared.',
                  style: const TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (canManage) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add new candidate'),
            ),
          ),
          const SizedBox(height: 20),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${candidates.length} candidate'
                    '${candidates.length == 1 ? '' : 's'} registered',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                  fontSize: 16,
                ),
              ),
            ),
            if (isAdmin)
              const Chip(
                label: Text('Admin'),
                avatar: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: primaryPurple,
                  size: 18,
                ),
                backgroundColor: lightPurple,
              ),
          ],
        ),

        const SizedBox(height: 16),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          )
        else if (candidates.isEmpty)
            EmptyState(
              icon: Icons.groups_outlined,
              title: 'No candidates registered',
              description: canManage
                  ? 'Add the first candidate before starting the election.'
                  : 'No candidates have been announced yet.',
              action: canManage
                  ? FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add candidate'),
              )
                  : null,
            )
          else
            ...candidates.map(
                  (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: CandidateCard(
                  candidate: candidate,
                  onEdit: canManage
                      ? () => onEdit(candidate)
                      : null,
                  onDelete: canManage
                      ? () => onDelete(candidate)
                      : null,
                ),
              ),
            ),

        if (isAdmin && electionStatus != 'draft') ...[
          const SizedBox(height: 16),
          const Text(
            'Candidate management is locked once voting begins.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
