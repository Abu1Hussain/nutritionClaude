/// A free-form meal log entry: a photo (optional), a description, and an
/// approximate quantity/weight. There is no on-device AI in this build to
/// estimate weight from a photo -- weight is always a value the user enters
/// or adjusts themselves, entered directly.
class LoggedMeal {
  final String id;
  final DateTime timestamp;
  final String description;
  final String quantityText; // e.g. "1 bowl", "2 pieces", "1.5 cups"
  final double? weightGrams;
  final String? photoPath; // local file path; null if no photo or on web

  const LoggedMeal({
    required this.id,
    required this.timestamp,
    required this.description,
    required this.quantityText,
    required this.weightGrams,
    required this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'quantityText': quantityText,
        'weightGrams': weightGrams,
        'photoPath': photoPath,
      };

  factory LoggedMeal.fromJson(Map<String, dynamic> json) => LoggedMeal(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        description: json['description'] as String,
        quantityText: json['quantityText'] as String? ?? '',
        weightGrams: (json['weightGrams'] as num?)?.toDouble(),
        photoPath: json['photoPath'] as String?,
      );
}
