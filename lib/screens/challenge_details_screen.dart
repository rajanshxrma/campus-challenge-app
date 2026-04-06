// challenge details screen — view, edit, delete a challenge
// shows completion history, weekly bar chart, and mark-as-completed button

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/challenge.dart';
import '../models/completion.dart';
import '../services/database_helper.dart';
import 'create_challenge_screen.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailsScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Challenge _challenge;
  List<Completion> _completions = [];
  Map<DateTime, int> _weeklyData = {};
  int _streak = 0;
  int _totalCompletions = 0;
  bool _isCompletedToday = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_challenge.id == null) return;

    setState(() => _isLoading = true);

    final completions = await _dbHelper.getCompletions(_challenge.id!);
    final weeklyData = await _dbHelper.getWeeklyCompletions(_challenge.id!);
    final streak = await _dbHelper.getStreak(_challenge.id!);
    final total = await _dbHelper.getTotalCompletions(_challenge.id!);
    final completedToday = await _dbHelper.isCompletedToday(_challenge.id!);

    if (!mounted) return;
    setState(() {
      _completions = completions;
      _weeklyData = weeklyData;
      _streak = streak;
      _totalCompletions = total;
      _isCompletedToday = completedToday;
      _isLoading = false;
    });
  }

  // mark the challenge as completed for today
  Future<void> _markCompleted() async {
    if (_challenge.id == null || _isCompletedToday) return;

    final completion = Completion(challengeId: _challenge.id!);
    await _dbHelper.insertCompletion(completion);
    await _loadData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Challenge completed! 🎉'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // navigate to edit screen
  void _editChallenge() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateChallengeScreen(challenge: _challenge),
      ),
    );
    // reload the challenge data after editing
    final updated = await _dbHelper.getChallenge(_challenge.id!);
    if (updated != null && mounted) {
      setState(() => _challenge = updated);
      _loadData();
    }
  }

  // confirm and delete the challenge
  void _deleteChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challenge'),
        content: Text(
            'Are you sure you want to delete "${_challenge.name}"?\nThis will also delete all completion history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _challenge.id != null) {
      await _dbHelper.deleteChallenge(_challenge.id!);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Challenge Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _editChallenge,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _deleteChallenge,
            tooltip: 'Delete',
            color: Colors.red,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // challenge info card
                  _buildInfoCard(theme),
                  const SizedBox(height: 16),

                  // stats row
                  _buildStatsRow(theme),
                  const SizedBox(height: 20),

                  // weekly chart
                  _buildWeeklyChart(theme),
                  const SizedBox(height: 20),

                  // mark as completed button
                  _buildCompleteButton(theme),
                  const SizedBox(height: 20),

                  // completion history
                  _buildHistory(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // challenge info card showing name, description, category, frequency
  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _challenge.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _challenge.category,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_challenge.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _challenge.description,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.repeat_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(_challenge.frequency,
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.flag_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Goal: ${_challenge.goal}',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // stats row showing streak, total completions, and progress
  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatCard(theme, Icons.local_fire_department_rounded,
            '$_streak', 'Day Streak', Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(theme, Icons.check_circle_rounded,
            '$_totalCompletions', 'Total Done', Colors.green),
        const SizedBox(width: 12),
        _buildStatCard(
            theme,
            Icons.trending_up_rounded,
            '${_totalCompletions > 0 ? ((_totalCompletions / (_challenge.goal * 7)) * 100).clamp(0, 100).toInt() : 0}%',
            'Weekly Goal',
            theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildStatCard(
      ThemeData theme, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  // weekly completion bar chart using fl_chart
  Widget _buildWeeklyChart(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final entries = _weeklyData.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_challenge.goal + 1).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < entries.length) {
                            final dayName = days[entries[idx].key.weekday - 1];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(dayName,
                                  style: const TextStyle(fontSize: 11)),
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
                          color: count > 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                          width: 20,
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

  // mark as completed button
  Widget _buildCompleteButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isCompletedToday ? null : _markCompleted,
        icon: Icon(
          _isCompletedToday
              ? Icons.check_circle_rounded
              : Icons.add_task_rounded,
        ),
        label: Text(
          _isCompletedToday ? 'Completed Today ✓' : 'Mark as Completed',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isCompletedToday ? Colors.green : theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // completion history list
  Widget _buildHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_completions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No completions yet.\nMark your first completion to start your streak!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          )
        else
          ...List.generate(
            _completions.length > 10 ? 10 : _completions.length,
            (index) {
              final completion = _completions[index];
              final dateStr =
                  DateFormat('MMM dd, yyyy').format(completion.completedAt);
              final timeStr =
                  DateFormat('h:mm a').format(completion.completedAt);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle_rounded,
                      color: Colors.green),
                  title: Text('Completed $dateStr'),
                  subtitle: Text(timeStr),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.withValues(alpha: 0.6), size: 20),
                    onPressed: () async {
                      if (completion.id != null) {
                        await _dbHelper.deleteCompletion(completion.id!);
                        _loadData();
                      }
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
