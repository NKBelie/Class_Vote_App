import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({
    super.key,
    required this.candidates,
    required this.hasVoted,
    required this.selectedCandidateId,
    required this.onSelect,
    required this.onConfirm,
    required this.onCandidates,
    this.electionStatus = 'active',
    this.isSubmitting = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Candidate> candidates;
  final bool hasVoted;
  final String? selectedCandidateId;

  final void Function(String) onSelect;
  final Future<void> Function() onConfirm;
  final VoidCallback onCandidates;

  final String electionStatus;
  final bool isSubmitting;
  final bool isLoading;
  final String? errorMessage;

  bool get canVote =>
      electionStatus == 'active' &&
          !hasVoted &&
          !isSubmitting &&
          !isLoading &&
          errorMessage == null;

  Future<void> _confirmVote(BuildContext context) async {
    if (!canVote || selectedCandidateId == null) {
      return;
    }

    Candidate? selectedCandidate;

    for (final candidate in candidates) {
      if (candidate.id == selectedCandidateId) {
        selectedCandidate = candidate;
        break;
      }
    }

    if (selectedCandidate == null) {
      return;
    }

    final candidateName = selectedCandidate.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm your vote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You are about to vote for:'),
              const SizedBox(height: 12),
              Text(
                candidateName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Once submitted, your vote cannot be changed.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Submit vote'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Cast your vote',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose one candidate to represent your class.',
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
              Icon(
                electionStatus == 'active'
                    ? Icons.verified_outlined
                    : Icons.lock_clock_outlined,
                color: primaryPurple,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  electionStatus == 'active'
                      ? 'Voting is open. Select one candidate.'
                      : electionStatus == 'closed'
                      ? 'Voting has ended.'
                      : 'Voting has not started yet.',
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

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (hasVoted)
            const EmptyState(
              icon: Icons.check_circle,
              title: 'Vote recorded!',
              description:
              'Thank you for participating. Your vote has '
                  'already been recorded for this election.',
            )
          else if (electionStatus != 'active')
              EmptyState(
                icon: Icons.lock_clock_outlined,
                title: 'Voting unavailable',
                description: electionStatus == 'closed'
                    ? 'This election has ended.'
                    : 'Please wait until voting officially begins.',
              )
            else if (candidates.isEmpty)
                EmptyState(
                  icon: Icons.how_to_vote_outlined,
                  title: 'No candidates available',
                  description:
                  'There are no candidates registered for this election.',
                  action: FilledButton(
                    onPressed: onCandidates,
                    child: const Text('View candidates'),
                  ),
                )
              else ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryPurple,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Select one candidate, review your choice, '
                                  'then confirm your vote.',
                              style: TextStyle(color: darkPurple),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ...candidates.map((candidate) {
                    final selected =
                        selectedCandidateId == candidate.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        color: selected ? lightPurple : Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: canVote
                              ? () => onSelect(candidate.id)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: selected
                                      ? primaryPurple
                                      : lightPurple,
                                  child: Icon(
                                    selected
                                        ? Icons.check
                                        : Icons.person_outline,
                                    color: selected
                                        ? Colors.white
                                        : primaryPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        candidate.manifesto,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: primaryPurple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canVote &&
                          selectedCandidateId != null
                          ? () => _confirmVote(context)
                          : null,
                      icon: isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.how_to_vote),
                      label: Text(
                        isSubmitting
                            ? 'Submitting vote...'
                            : 'Confirm my vote',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'You can vote only once per election. '
                        'Your selection cannot be changed after submission.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
      ],
    );
  }
}
