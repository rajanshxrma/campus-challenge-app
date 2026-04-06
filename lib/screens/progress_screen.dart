// progress screen — shows overall progress statistics and history
// displays weekly completion chart, streak overview, and recent activity

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/challenge.dart';
import '../services/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<DateTime, int> _weeklyData = {};
  List<Challenge> _challenges = [];
  Map<int, int> _streaks = {};
  Map<int, int> _totals = {};
  Map<int, bool> _todayStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final challenges = await _dbHelper.getChallenges(activeOnly: true);
    final weeklyData = await _dbHelper.getAllWeeklyCompletions();

    final Map<int, int> streaks = {};
    final Map<int, int> totals = {};
    final Map<int, bool> todayStatus = {};

    for (final c in challenges) {
      if (c.id != null) {
        streaks[c.id!] = await _dbHelper.getStreak(c.id!);
        totals[c.id!] = await _dbHelper.getTotalCompletions(c.id!);
        todayStatus[c.id!] = await _dbHelper.isCompletedToday(c.id!);
      }
    }

    if (!mounted) return;
    setState(() {
      _challenges = challenges;
      _weeklyData = weeklyData;
      _streaks = streaks;
      _totals = totals;
      _todayStatus = todayStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCompletionsAll = _totals.values.fold(0, (a, b) => a + b);
    final longestStreak = _streaks.values.isNotEmpty
        ? _streaks.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final completedToday = _todayStatus.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // overall stats cards
                  Row(
                    children: [
                      _buildStatCard(theme, Icons.check_circle_rounded,
                          '$totalCompletionsAll', 'Total Done', Colors.green),
                      const SizedBox(width: 10),
                      _buildStatCard(
                          theme,
                          Icons.local_fire_department_rounded,
                          '$longestStreak',
                          'Best Streak',
                          Colors.orange),
                      const SizedBox(width: 10),
                      _buildStatCard(
                          theme,
                          Icons.today_rounded,
                          '$completedToday/${_challenges.length}',
                          'Today',
                          theme.colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // weekly progress chart
                  _buildWeeklyChart(theme),
                  const SizedBox(height: 20),

                  // weekly progress dots (visual indicator for each day)
                  _buildWeeklyDots(theme),
                  const SizedBox(height: 20),

                  // per-challenge progress
                  Text(
                    'Challenge Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_challenges.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No challenges yet.\nCreate a challenge to start tracking progress!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_challenges.length, (i) {
                      final c = _challenges[i];
                      final streak = _streaks[c.id] ?? 0;
                      final total = _totals[c.id] ?? 0;
                      final doneToday = _todayStatus[c.id] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: doneToday
                                ? Colors.green.withValues(alpha: 0.15)
                                : theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                            child: Icon(
                              doneToday
                                  ? Icons.check_rounded
                                  : Icons.pending_rounded,
                              color: doneToday
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(c.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  size: 14, color: Colors.orange[600]),
                              const SizedBox(width: 2),
                              Text('$streak days',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 12),
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text('$total total',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: doneToday
                              ? const Icon(Icons.check_circle_rounded,
                                  color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked_rounded,
                                  color: Colors.grey),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // recent completion history
                  _buildRecentHistory(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // weekly completion bar chart across all challenges
  Widget _buildWeeklyChart(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final entries = _weeklyData.entries.toList();
    final maxY = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble()
        : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + 1,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} done',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < entries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[entries[idx].key.weekday - 1],
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(entries.length, (i) {
                    final count = entries[i].value.toDouble();
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: count,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          width: 24,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // weekly dots — visual indicator showing completion for each day
  Widget _buildWeeklyDots(ThemeData theme) {
    final entries = _weeklyData.entries.toList();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(entries.length, (i) {
                final completed = entries[i].value > 0;
                final isToday = entries[i].key.day == DateTime.now().day &&
                    entries[i].key.month == DateTime.now().month;

                return Column(
                  children: [
                    Text(
                      days[entries[i].key.weekday - 1],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? Colors.green
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.1),
                        border: isToday
                            ? Border.all(
                                color: theme.colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: completed
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // recent completions across all challenges
  Widget _buildRecentHistory(ThemeData theme) {
    return FutureBuilder(
      future: _dbHelper.getAllCompletions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final completions = snapshot.data!;
        final recent = completions.take(8).toList();

        if (recent.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(recent.length, (i) {
              final c = recent[i];
              return FutureBuilder(
                future: _dbHelper.getChallenge(c.challengeId),
                builder: (ctx, snap) {
                  final name = snap.data?.name ?? 'Challenge';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 20),
                      title: Text(name,
                          style: const TextStyle(fontSize: 14)),
                      trailing: Text(
                        DateFormat('MMM dd').format(c.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}
