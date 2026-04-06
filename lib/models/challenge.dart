// challenge model — represents a daily challenge created by the user
// stores the challenge data and provides conversion to/from database maps

class Challenge {
  final int? id;
  final String name;
  final String description;
  final String frequency; // daily, weekly, custom
  final int goal; // target completions
  final String category; // study, fitness, social, wellness, other
  final DateTime createdAt;
  final bool isActive;

  Challenge({
    this.id,
    required this.name,
    this.description = '',
    this.frequency = 'Daily',
    this.goal = 1,
    this.category = 'Other',
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // convert challenge to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'goal': goal,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // create a challenge from a database map
  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'Daily',
      goal: map['goal'] as int? ?? 1,
      category: map['category'] as String? ?? 'Other',
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  // create a copy with updated fields
  Challenge copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    int? goal,
    String? category,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      goal: goal ?? this.goal,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // convert to json map for export
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'frequency': frequency,
      'goal': goal,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // create from json map for import
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'Daily',
      goal: json['goal'] as int? ?? 1,
      category: json['category'] as String? ?? 'Other',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
