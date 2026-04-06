// database helper — manages sqlite database for challenges and completions
// handles all crud operations and provides query methods for statistics

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/challenge.dart';
import '../models/completion.dart';

class DatabaseHelper {
  // singleton pattern — one database instance for the whole app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // get or create the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_challenge.db');
    return _database!;
  }

  // initialize the database with our schema
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // create tables for challenges and completions
  Future<void> _createDB(Database db, int version) async {
    // challenges table stores all user-created challenges
    await db.execute('''
      CREATE TABLE challenges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        frequency TEXT DEFAULT 'Daily',
        goal INTEGER DEFAULT 1,
        category TEXT DEFAULT 'Other',
        createdAt TEXT NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // completions table tracks each time a challenge is completed
    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        challengeId INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        notes TEXT DEFAULT '',
        FOREIGN KEY (challengeId) REFERENCES challenges (id) ON DELETE CASCADE
      )
    ''');
  }

  

  // insert a new challenge into the database
  Future<int> insertChallenge(Challenge challenge) async {
    final db = await database;
    return await db.insert('challenges', challenge.toMap());
  }

  // get all challenges (optionally filter by active status)
  Future<List<Challenge>> getChallenges({bool? activeOnly}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (activeOnly == true) {
      maps = await db.query('challenges',
          where: 'isActive = ?', whereArgs: [1], orderBy: 'createdAt DESC');
    } else {
      maps = await db.query('challenges', orderBy: 'createdAt DESC');
    }

    return maps.map((map) => Challenge.fromMap(map)).toList();
  }

  // get a single challenge by id
  Future<Challenge?> getChallenge(int id) async {
    final db = await database;
    final maps = await db.query('challenges', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Challenge.fromMap(maps.first);
    }
    return null;
  }

  // update an existing challenge
  Future<int> updateChallenge(Challenge challenge) async {
    final db = await database;
    return await db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  // delete a challenge and its completions
  Future<int> deleteChallenge(int id) async {
    final db = await database;
    // delete related completions first
    await db.delete('completions', where: 'challengeId = ?', whereArgs: [id]);
    return await db.delete('challenges', where: 'id = ?', whereArgs: [id]);
  }

  

  // record a completion for a challenge
  Future<int> insertCompletion(Completion completion) async {
    final db = await database;
    return await db.insert('completions', completion.toMap());
  }

  // get all completions for a specific challenge
  Future<List<Completion>> getCompletions(int challengeId) async {
    final db = await database;
    final maps = await db.query(
      'completions',
      where: 'challengeId = ?',
      whereArgs: [challengeId],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => Completion.fromMap(map)).toList();
  }

  // get completions for a challenge within a date range
  Future<List<Completion>> getCompletionsInRange(
      int challengeId, DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'completions',
      where: 'challengeId = ? AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [challengeId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => Completion.fromMap(map)).toList();
  }

  // check if a challenge was completed today
  Future<bool> isCompletedToday(int challengeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final completions =
        await getCompletionsInRange(challengeId, startOfDay, endOfDay);
    return completions.isNotEmpty;
  }

  // get the current streak for a challenge (consecutive days completed)
  Future<int> getStreak(int challengeId) async {
    final completions = await getCompletions(challengeId);
    if (completions.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    // check if completed today
    bool completedToday = await isCompletedToday(challengeId);
    if (!completedToday) {
      // if not completed today, start checking from yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // count consecutive days going backwards
    for (int i = 0; i < 365; i++) {
      final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayCompletions =
          await getCompletionsInRange(challengeId, dayStart, dayEnd);

      if (dayCompletions.isNotEmpty) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // get total completions count for a challenge
  Future<int> getTotalCompletions(int challengeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM completions WHERE challengeId = ?',
      [challengeId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // get completions per day for the last 7 days (for weekly chart)
  Future<Map<DateTime, int>> getWeeklyCompletions(int challengeId) async {
    final now = DateTime.now();
    final Map<DateTime, int> weeklyData = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));
      final completions =
          await getCompletionsInRange(challengeId, date, nextDate);
      weeklyData[date] = completions.length;
    }

    return weeklyData;
  }

  // get all completions across all challenges for the last 7 days
  Future<Map<DateTime, int>> getAllWeeklyCompletions() async {
    final now = DateTime.now();
    final db = await database;
    final Map<DateTime, int> weeklyData = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = date.add(const Duration(days: 1));
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM completions WHERE completedAt >= ? AND completedAt < ?',
        [date.toIso8601String(), nextDate.toIso8601String()],
      );
      weeklyData[date] = Sqflite.firstIntValue(result) ?? 0;
    }

    return weeklyData;
  }

  // get all completions (for export)
  Future<List<Completion>> getAllCompletions() async {
    final db = await database;
    final maps = await db.query('completions', orderBy: 'completedAt DESC');
    return maps.map((map) => Completion.fromMap(map)).toList();
  }

  // delete a completion
  Future<int> deleteCompletion(int id) async {
    final db = await database;
    return await db.delete('completions', where: 'id = ?', whereArgs: [id]);
  }

  // clear all data (for testing or reset)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('completions');
    await db.delete('challenges');
  }

  // close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
