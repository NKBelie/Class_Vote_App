
import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import '../widgets/candidate_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.candidates,
    required this.hasVoted,
    required this.onVote,
    required this.onCandidates,
    required this.onResults,
  });

  final List<Candidate> candidates;
  final bool hasVoted;
  final VoidCallback onVote;
  final VoidCallback onCandidates;
  final VoidCallback onResults;

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weather;
  String? _weatherError;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
      _weather = null;
    });

    try {
      final weather =
      await WeatherService.getCurrentWeather();

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _weatherLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _weatherError = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _weatherLoading = false;
      });
    }
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_outlined,
                color: primaryPurple,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Kigali Live Weather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh weather',
                onPressed:
                _weatherLoading ? null : _loadWeather,
                icon: const Icon(
                  Icons.refresh,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_weatherLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_weatherError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  _weatherError!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loadWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            )
          else if (_weather != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weather!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wind speed: '
                        '${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),

          const SizedBox(height: 8),
          const Text(
            'Live data provided by Open-Meteo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.candidates.fold<int>(
      0,
          (sum, candidate) => sum + candidate.votes,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryPurple,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR VOICE MATTERS',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Choose your\nclass leader.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Explore the candidates and make '
                    'your vote count.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: widget.onVote,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryPurple,
                ),
                icon: const Icon(Icons.how_to_vote),
                label: Text(
                  widget.hasVoted
                      ? 'View election'
                      : 'Vote now',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Election overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkPurple,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            StatCard(
              label: 'Candidates',
              value: '${widget.candidates.length}',
              icon: Icons.groups,
            ),
            const SizedBox(width: 10),
            StatCard(
              label: 'Votes cast',
              value: '$totalVotes',
              icon: Icons.how_to_vote,
              color: const Color(0xFF14866D),
            ),
          ],
        ),

        const SizedBox(height: 24),
        _buildWeatherCard(),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meet the candidates',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
            TextButton(
              onPressed: widget.onCandidates,
              child: const Text('View all'),
            ),
          ],
        ),

        if (widget.candidates.isEmpty)
          EmptyState(
            icon: Icons.groups_outlined,
            title: 'No candidates yet',
            description:
            'Add candidates to get your class '
                'election started.',
            action: FilledButton(
              onPressed: widget.onCandidates,
              child: const Text('Manage candidates'),
            ),
          )
        else
          ...widget.candidates.take(3).map(
                (candidate) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CandidateCard(
                candidate: candidate,
                compact: true,
              ),
            ),
          ),

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.onResults,
          icon: const Icon(Icons.bar_chart),
          label: const Text('View election results'),
        ),
      ],
    );
  }
}
