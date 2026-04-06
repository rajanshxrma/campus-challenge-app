// completion model — records when a user completes a challenge
// tracks the date and optional notes for each completion

class Completion {
  final int? id;
  final int challengeId;
  final DateTime completedAt;
  final String notes;

  Completion({
    this.id,
    required this.challengeId,
    DateTime? completedAt,
    this.notes = '',
  }) : completedAt = completedAt ?? DateTime.now();

  // convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'challengeId': challengeId,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // create from database map
  factory Completion.fromMap(Map<String, dynamic> map) {
    return Completion(
      id: map['id'] as int?,
      challengeId: map['challengeId'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  // convert to json for export
  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
