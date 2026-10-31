import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/election_service.dart';
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
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _service = ElectionService();

  // Set this to an actual Firestore election document ID.
  static const String electionId = 'class-election-2026';

  int _currentIndex = 0;
  String? _selectedCandidateId;
  bool _isAdmin = false;
  bool _hasVoted = false;
  bool _statusVerified = false;
  bool _busy = false;
  String? _statusError;
  String _electionStatus = 'draft';
  List<Candidate> _candidates = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _electionSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _candidateSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _resultsSub;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final token = await user.getIdTokenResult();
      if (!mounted) return;
      setState(() => _isAdmin = token.claims?['admin'] == true);
    } catch (e) {
      _message('Could not verify administrator permissions: $e');
    }

    _electionSub = _db
        .collection('elections')
        .doc(electionId)
        .snapshots()
        .listen((doc) {
          if (!mounted) return;
          final status = doc.data()?['status'] as String? ?? 'draft';
          setState(() => _electionStatus = status);
          if (status == 'closed') {
            _listenForResults();
          } else {
            _resultsSub?.cancel();
            _resultsSub = null;
            setState(() {
              for (final c in _candidates) {
                c.votes = 0;
              }
            });
          }
        }, onError: (Object e) => _message('Election loading failed: $e'));

    _candidateSub = _service.watchCandidates(electionId).listen((snapshot) {
      if (!mounted) return;
      final updated = snapshot.docs.map(Candidate.fromFirestore).toList();
      final previousVotes = {for (final c in _candidates) c.id: c.votes};
      for (final c in updated) {
        c.votes = _electionStatus == 'closed' ? (previousVotes[c.id] ?? 0) : 0;
      }
      setState(() {
        _candidates = updated;
        if (!_candidates.any((c) => c.id == _selectedCandidateId)) {
          _selectedCandidateId = null;
        }
      });
    }, onError: (Object e) => _message('Candidate loading failed: $e'));

    await _refreshVoteStatus();
  }

  void _listenForResults() {
    if (_resultsSub != null) return;
    _resultsSub = _service.watchResults(electionId).listen((snapshot) {
      if (!mounted) return;
      final totals = <String, int>{};
      for (final doc in snapshot.docs) {
        totals[doc.id] = (doc.data()['votes'] as num?)?.toInt() ?? 0;
      }
      setState(() {
        for (final candidate in _candidates) {
          candidate.votes = totals[candidate.id] ?? 0;
        }
      });
    }, onError: (Object e) => _message('Results loading failed: $e'));
  }

  Future<void> _refreshVoteStatus() async {
    if (mounted) {
      setState(() {
        _statusVerified = false;
        _statusError = null;
      });
    }
    try {
      // Trusted function checks votes/{request.auth.uid} on the server.
      final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getVoteStatus')
          .call<Map<String, dynamic>>({'electionId': electionId});
      if (!mounted) return;
      setState(() {
        _hasVoted = result.data['hasVoted'] == true;
        _statusVerified = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _statusError = 'Vote status unavailable. Voting is locked until verification succeeds.',
      );
    }
  }

  CollectionReference<Map<String, dynamic>> get _candidateCollection =>
      _db.collection('elections').doc(electionId).collection('candidates');

  bool get _canManage => _isAdmin && _electionStatus == 'draft';

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editCandidate([Candidate? candidate]) async {
    if (!_canManage || _busy) return;
    final nameController = TextEditingController(text: candidate?.name ?? '');
    final manifestoController = TextEditingController(
      text: candidate?.manifesto ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(candidate == null ? 'Add candidate' : 'Edit candidate'),
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
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.length < 3) return 'Enter at least 3 characters.';
                    if (_candidates.any(
                      (c) =>
                          c.id != candidate?.id &&
                          c.name.toLowerCase() == name.toLowerCase(),
                    )) {
                      return 'Candidate already exists.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: manifestoController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: const InputDecoration(labelText: 'Manifesto'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Enter a manifesto.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate())
                Navigator.pop(dialogContext, true);
            },
            child: Text(candidate == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
    final name = nameController.text.trim();
    final manifesto = manifestoController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      manifestoController.dispose();
    });
    if (accepted != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      if (candidate == null) {
        await _candidateCollection.add({
          'name': name,
          'manifesto': manifesto,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _candidateCollection.doc(candidate.id).update({
          'name': name,
          'manifesto': manifesto,
        });
      }
      _message(candidate == null ? 'Candidate added.' : 'Candidate updated.');
    } catch (e) {
      _message('Could not save candidate: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteCandidate(Candidate candidate) async {
    if (!_canManage || _busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete candidate?'),
        content: Text('Remove ${candidate.name} from this election?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _candidateCollection.doc(candidate.id).delete();
      _message('Candidate deleted.');
    } catch (e) {
      _message('Could not delete candidate: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _castVote() async {
    final String? id = _selectedCandidateId;

    if (_busy ||
        !_statusVerified ||
        _hasVoted ||
        _isAdmin ||
        _electionStatus != 'active' ||
        id == null) {
      return;
    }
    setState(() => _busy = true);
    try {
      await _service.castVote(electionId: electionId, candidateId: id);
      if (!mounted) return;
      setState(() {
        _hasVoted = true;
        _selectedCandidateId = null;
      });
      _message('Your vote has been recorded!');
    } on FirebaseException catch (e) {
      _message('Vote rejected: ${e.message ?? e.code}');
      await _refreshVoteStatus();
    } catch (e) {
      _message('Unable to submit vote: $e');
      await _refreshVoteStatus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _electionSub?.cancel();
    _candidateSub?.cancel();
    _resultsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'ClassVote',
      'Candidates',
      'Cast your vote',
      'Election results',
    ];
    final resultsReady = _electionStatus == 'closed';
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
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _busy ? null : () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              candidates: _candidates,
              hasVoted: _hasVoted,
              onVote: () => setState(() => _currentIndex = 2),
              onCandidates: () => setState(() => _currentIndex = 1),
              onResults: () => setState(() => _currentIndex = 3),
            ),
            CandidatesScreen(
              candidates: _candidates,
              isAdmin: _isAdmin,
              electionStatus: _electionStatus,
              onAdd: () => _editCandidate(),
              onEdit: (candidate) => _editCandidate(candidate),
              onDelete: _deleteCandidate,
            ),
            !_statusVerified && !_isAdmin
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_statusError ?? 'Checking voting eligibility...'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _refreshVoteStatus,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : VotingScreen(
                    candidates: _candidates,
                    hasVoted: _hasVoted,
                    selectedCandidateId: _selectedCandidateId,
                    onSelect: (id) => setState(() => _selectedCandidateId = id),
                    onConfirm: _castVote,
                    onCandidates: () => setState(() => _currentIndex = 1),
                    electionStatus: _isAdmin ? 'draft' : _electionStatus,
                    isSubmitting: _busy,
                  ),
            resultsReady
                ? ResultsScreen(
                    candidates: _candidates,
                    onReset: () => _message(
                      'Shared elections cannot be reset from the app.',
                    ),
                    onCandidates: () => setState(() => _currentIndex = 1),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Official results will be available after the election closes.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: lightPurple,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Candidates',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_vote_outlined),
            selectedIcon: Icon(Icons.how_to_vote),
            label: 'Vote',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
        ],
      ),
    );
  }
}
