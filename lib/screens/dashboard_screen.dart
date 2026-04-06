// dashboard screen — main screen showing active challenges and quick stats
// displays welcome message, today's progress, and list of challenges

import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import 'create_challenge_screen.dart';
import 'challenge_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PreferencesService _prefs = PreferencesService();
  List<Challenge> _challenges = [];
  Map<int, bool> _todayCompletions = {};
  Map<int, int> _streaks = {};
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // load all challenges and their completion status
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final name = await _prefs.getUserName();
    final challenges = await _dbHelper.getChallenges(activeOnly: true);

    // check today's completion status and streaks for each challenge
    final Map<int, bool> completions = {};
    final Map<int, int> streaks = {};
    for (final challenge in challenges) {
      if (challenge.id != null) {
        completions[challenge.id!] =
            await _dbHelper.isCompletedToday(challenge.id!);
        streaks[challenge.id!] = await _dbHelper.getStreak(challenge.id!);
      }
    }

    if (!mounted) return;
    setState(() {
      _userName = name;
      _challenges = challenges;
      _todayCompletions = completions;
      _streaks = streaks;
      _isLoading = false;
    });
  }

  // navigate to create challenge screen
  void _createChallenge() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateChallengeScreen()),
    );
    _loadData(); // refresh after creating
  }

  // navigate to challenge details
  void _viewChallenge(Challenge challenge) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallengeDetailsScreen(challenge: challenge),
      ),
    );
    _loadData(); // refresh after viewing/editing
  }

  // get an icon for the challenge category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return Icons.menu_book_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'wellness':
        return Icons.spa_rounded;
      case 'reading':
        return Icons.auto_stories_rounded;
      case 'coding':
        return Icons.code_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // get a color for the challenge category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return const Color(0xFF4CAF50);
      case 'fitness':
        return const Color(0xFFFF5722);
      case 'social':
        return const Color(0xFF2196F3);
      case 'wellness':
        return const Color(0xFF9C27B0);
      case 'reading':
        return const Color(0xFFFF9800);
      case 'coding':
        return const Color(0xFF00BCD4);
      case 'music':
        return const Color(0xFFE91E63);
      case 'sports':
        return const Color(0xFF8BC34A);
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedToday =
        _todayCompletions.values.where((v) => v).length;
    final totalChallenges = _challenges.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _createChallenge,
            tooltip: 'Create Challenge',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _challenges.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildChallengeList(theme, completedToday, totalChallenges),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChallenge,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // empty state — shown when no challenges exist yet
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 24),
              Text(
                'No Challenges Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to create your first challenge\nand start building better habits!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _createChallenge,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Challenge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // challenge list with header stats
  Widget _buildChallengeList(
      ThemeData theme, int completedToday, int totalChallenges) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // welcome message
        Text(
          'Welcome, $_userName',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // today's progress card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // progress circle
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: totalChallenges > 0
                            ? completedToday / totalChallenges
                            : 0,
                        strokeWidth: 6,
                        backgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      Center(
                        child: Text(
                          '$completedToday/$totalChallenges',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Progress",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completedToday == totalChallenges && totalChallenges > 0
                            ? 'All challenges completed! 🎉'
                            : '${totalChallenges - completedToday} remaining today',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // challenges section header
        Text(
          'Active Challenges',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // challenge cards
        ...List.generate(_challenges.length, (index) {
          final challenge = _challenges[index];
          final isCompleted = _todayCompletions[challenge.id] ?? false;
          final streak = _streaks[challenge.id] ?? 0;
          final color = _getCategoryColor(challenge.category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () => _viewChallenge(challenge),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // category icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(challenge.category),
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // challenge info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (streak > 0) ...[
                                  Icon(Icons.local_fire_department_rounded,
                                      size: 14, color: Colors.orange.shade600),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$streak-day streak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  challenge.frequency,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // completion status indicator
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 80), // space for FAB
      ],
    );
  }
}
