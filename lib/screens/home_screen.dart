
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ClassVoteHome extends StatefulWidget {
  const ClassVoteHome({super.key});

  @override
  State<ClassVoteHome> createState() => _ClassVoteHomeState();
}

class _ClassVoteHomeState extends State<ClassVoteHome> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'ClassVote',
    'Candidates',
    'Cast your vote',
    'Election results',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(child: Text('Dashboard')),
          Center(child: Text('Candidate Management')),
          Center(child: Text('Voting')),
          Center(child: Text('Election Results')),
        ],
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
