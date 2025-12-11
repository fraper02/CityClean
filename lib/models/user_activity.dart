enum ActivityType { conferimento, missione, obiettivo, badge, premio, adminAdjustment }

class UserActivity {
  final String id;
  final ActivityType type;
  final DateTime date;
  final String description;
  final int? points;
  final String? badgeName;

  UserActivity({
    required this.id,
    required this.type,
    required this.date,
    required this.description,
    this.points,
    this.badgeName,
  });
}
