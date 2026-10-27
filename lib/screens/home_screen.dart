
import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/election_storage.dart';
import '../theme/app_theme.dart';

import 'dashboard_screen.dart';
import 'candidates_screen.dart';
import 'voting_screen.dart';
import 'results_screen.dart';

class ClassVoteHome extends StatefulWidget {
  const ClassVoteHome({super.key});

  @override
  State<ClassVoteHome> createState() => _ClassVoteHomeState();
}

class _ClassVoteHomeState extends State<ClassVoteHome> {
  int _currentIndex = 0;
  int _nextId = 5;
  int? _selectedCandidateId;

  bool _hasVoted = false;
  bool _loading = true;
  bool _saving = false;

  String? _loadError;

  List<Candidate> _candidates = [
    Candidate(
      id: 1,
      name: 'Aline Uwase',
      manifesto: 'Better communication and teamwork.',
    ),
    Candidate(
      id: 2,
      name: 'Eric Mugisha',
      manifesto: 'More student activities and inclusion.',
    ),
    Candidate(
      id: 3,
      name: 'Diane Ingabire',
      manifesto: 'A cleaner, more organized classroom.',
    ),
    Candidate(
      id: 4,
      name: 'Patrick Niyonzima',
      manifesto: 'Student ideas, action, and accountability.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadElection();
  }

  // Load election data when the application opens.
  Future<void> _loadElection() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final data = await ElectionStorage.load();

      if (!mounted) return;

      setState(() {
        if (data != null) {
          _candidates = data.candidates;
          _nextId = data.nextId;
          _hasVoted = data.hasVoted;
        }

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = 'Unable to load election data: $error';
        _loading = false;
      });
    }
  }

  // Save candidates, votes, and voting status.
  Future<bool> _saveElection() async {
    if (_saving) return false;

    setState(() {
      _saving = true;
    });

    try {
      await ElectionStorage.save(
        ElectionData(
          candidates: _candidates,
          nextId: _nextId,
          hasVoted: _hasVoted,
        ),
      );

      return true;
    } catch (error) {
      _showMessage('Unable to save data: $error');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // Add or edit a candidate.
  Future<void> _editCandidate([Candidate? candidate]) async {
    if (_saving) return;

    final nameController = TextEditingController(
      text: candidate?.name ?? '',
    );

    final manifestoController = TextEditingController(
      text: candidate?.manifesto ?? '',
    );

    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            candidate == null ? 'Add candidate' : 'Edit candidate',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Candidate name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      final name = value?.trim() ?? '';

                      if (name.length < 3) {
                        return 'Enter at least 3 characters.';
                      }

                      final duplicate = _candidates.any(
                            (item) =>
                        item.id != candidate?.id &&
                            item.name.toLowerCase() ==
                                name.toLowerCase(),
                      );

                      if (duplicate) {
                        return 'Candidate already exists.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: manifestoController,
                    maxLines: 3,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      labelText: 'Manifesto',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a manifesto.';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(
                candidate == null ? 'Add candidate' : 'Save changes',
              ),
            ),
          ],
        );
      },
    );

    final name = nameController.text.trim();
    final manifesto = manifestoController.text.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      manifestoController.dispose();
    });

    if (confirmed != true || !mounted) return;

    setState(() {
      if (candidate == null) {
        _candidates.add(
          Candidate(
            id: _nextId++,
            name: name,
            manifesto: manifesto,
          ),
        );
      } else {
        candidate.name = name;
        candidate.manifesto = manifesto;
      }
    });

    if (await _saveElection()) {
      _showMessage(
        candidate == null
            ? 'Candidate added successfully.'
            : 'Candidate updated successfully.',
      );
    }
  }

  // Delete a candidate.
  Future<void> _deleteCandidate(Candidate candidate) async {
    if (_saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete candidate?'),
          content: Text(
            'Are you sure you want to delete ${candidate.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _candidates.removeWhere(
            (item) => item.id == candidate.id,
      );

      if (_selectedCandidateId == candidate.id) {
        _selectedCandidateId = null;
      }
    });

    if (await _saveElection()) {
      _showMessage('Candidate deleted successfully.');
    }
  }

  // Cast a vote.
  Future<void> _castVote() async {
    if (_saving) return;

    if (_hasVoted) {
      _showMessage('You have already voted on this device.');
      return;
    }

    if (_selectedCandidateId == null) {
      _showMessage('Please select a candidate.');
      return;
    }

    final matches = _candidates.where(
          (item) => item.id == _selectedCandidateId,
    );

    if (matches.isEmpty) {
      _showMessage('Candidate not found.');
      return;
    }

    final candidate = matches.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm your vote'),
          content: Text(
            'Are you sure you want to vote for ${candidate.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm vote'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted || _hasVoted || _saving) {
      return;
    }

    setState(() {
      candidate.votes++;
      _hasVoted = true;
      _selectedCandidateId = null;
    });

    if (await _saveElection()) {
      _showMessage('Your vote has been recorded!');
    } else if (mounted) {
      setState(() {
        candidate.votes--;
        _hasVoted = false;
      });
    }
  }

  // Reset election votes.
  Future<void> _resetElection() async {
    if (_saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset election?'),
          content: const Text(
            'This will remove all votes but keep the candidates.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Reset votes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      for (final candidate in _candidates) {
        candidate.votes = 0;
      }

      _hasVoted = false;
      _selectedCandidateId = null;
    });

    if (await _saveElection()) {
      _showMessage('Election votes reset successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: primaryPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadElection,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final titles = [
      'ClassVote',
      'Candidates',
      'Cast your vote',
      'Election results',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Reset election',
            onPressed: _saving ? null : _resetElection,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),

      // Connect the four real ClassVote screens.
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              candidates: _candidates,
              hasVoted: _hasVoted,
              onVote: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              onCandidates: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              onResults: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),

            CandidatesScreen(
              candidates: _candidates,
              onAdd: () => _editCandidate(),
              onEdit: _editCandidate,
              onDelete: _deleteCandidate,
            ),

            VotingScreen(
              candidates: _candidates,
              hasVoted: _hasVoted,
              selectedCandidateId: _selectedCandidateId,
              onSelect: (id) {
                setState(() {
                  _selectedCandidateId = id;
                });
              },
              onConfirm: _castVote,
              onCandidates: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),

            ResultsScreen(
              candidates: _candidates,
              onReset: _resetElection,
              onCandidates: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: lightPurple,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Candidates',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_vote_outlined),
            selectedIcon: Icon(Icons.how_to_vote_rounded),
            label: 'Vote',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Results',
          ),
        ],
      ),
    );
  }
}
