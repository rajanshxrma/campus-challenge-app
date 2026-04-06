// data export/import service — handles exporting and importing challenge data
// supports json format for backup and sharing between devices

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/challenge.dart';
import 'database_helper.dart';

class DataExportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // export all data to a json file and return the file path
  Future<String> exportToJson() async {
    // get all challenges and completions from the database
    final challenges = await _dbHelper.getChallenges();
    final completions = await _dbHelper.getAllCompletions();

    // build the export data structure
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'challenges': challenges.map((c) => c.toJson()).toList(),
      'completions': completions.map((c) => c.toJson()).toList(),
    };

    // write to file in the app's documents directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/campus_challenge_export_$timestamp.json');
    await file.writeAsString(jsonEncode(exportData));

    return file.path;
  }

  // import data from a json string
  Future<int> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    int importedCount = 0;

    // import challenges
    if (data.containsKey('challenges')) {
      final challengesList = data['challenges'] as List;
      for (final challengeJson in challengesList) {
        final challenge =
            Challenge.fromJson(challengeJson as Map<String, dynamic>);
        await _dbHelper.insertChallenge(challenge);
        importedCount++;
      }
    }

    return importedCount;
  }
}
