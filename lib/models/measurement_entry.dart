/// The eight body parts tracked by the Body Measurements feature.
enum BodyPart { waist, arm, chest, thigh, shoulders, abdomen, calves, hips }

extension BodyPartLabel on BodyPart {
  String get label {
    switch (this) {
      case BodyPart.waist:
        return 'Waist';
      case BodyPart.arm:
        return 'Arm';
      case BodyPart.chest:
        return 'Chest';
      case BodyPart.thigh:
        return 'Thigh';
      case BodyPart.shoulders:
        return 'Shoulders';
      case BodyPart.abdomen:
        return 'Stomach/abdomen';
      case BodyPart.calves:
        return 'Calves';
      case BodyPart.hips:
        return 'Hips/glutes';
    }
  }
}

/// One dated set of body measurements. Every field is optional -- the user
/// does not have to fill in all eight on a given entry. Values are always
/// stored in centimeters; the cm/inch toggle is a display-only preference
/// applied when rendering.
class MeasurementEntry {
  final String id;
  final DateTime date;
  final Map<BodyPart, double> valuesCm;

  const MeasurementEntry({required this.id, required this.date, required this.valuesCm});

  double? operator [](BodyPart part) => valuesCm[part];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'values': valuesCm.map((k, v) => MapEntry(k.name, v)),
      };

  factory MeasurementEntry.fromJson(Map<String, dynamic> json) {
    final rawValues = (json['values'] as Map<String, dynamic>? ?? {});
    final values = <BodyPart, double>{};
    for (final part in BodyPart.values) {
      final v = rawValues[part.name];
      if (v != null) values[part] = (v as num).toDouble();
    }
    return MeasurementEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      valuesCm: values,
    );
  }
}
