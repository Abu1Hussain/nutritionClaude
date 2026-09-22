/// The result of one successful calculator run. Mirrors the web app's
/// nutrition target object exactly so the same numbers show up everywhere
/// (Calculator, Meal Plan, Targets, Share).
class NutritionTarget {
  final int age;
  final String sex; // 'male' | 'female'
  final double heightCm;
  final double weightKg;
  final double activityFactor;
  final String goal; // 'lose' | 'maintain' | 'gain'
  final double weeklyRateKg;
  final double bmi;
  final int bmr;
  final int tdee;
  final int calories;
  final int proteinGrams;
  final int carbohydrateGrams;
  final int fatGrams;
  final int addedSugarLimitGrams;
  final int saturatedFatLimitGrams;
  final double refWeightMin;
  final double refWeightMax;

  const NutritionTarget({
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activityFactor,
    required this.goal,
    required this.weeklyRateKg,
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.addedSugarLimitGrams,
    required this.saturatedFatLimitGrams,
    required this.refWeightMin,
    required this.refWeightMax,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'sex': sex,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activityFactor': activityFactor,
        'goal': goal,
        'weeklyRateKg': weeklyRateKg,
        'bmi': bmi,
        'bmr': bmr,
        'tdee': tdee,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbohydrateGrams': carbohydrateGrams,
        'fatGrams': fatGrams,
        'addedSugarLimitGrams': addedSugarLimitGrams,
        'saturatedFatLimitGrams': saturatedFatLimitGrams,
        'refWeightMin': refWeightMin,
        'refWeightMax': refWeightMax,
      };

  factory NutritionTarget.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v as num).toDouble();
    int i(dynamic v) => (v as num).toInt();
    return NutritionTarget(
      age: i(json['age']),
      sex: json['sex'] as String,
      heightCm: d(json['heightCm']),
      weightKg: d(json['weightKg']),
      activityFactor: d(json['activityFactor']),
      goal: json['goal'] as String,
      weeklyRateKg: d(json['weeklyRateKg']),
      bmi: d(json['bmi']),
      bmr: i(json['bmr']),
      tdee: i(json['tdee']),
      calories: i(json['calories']),
      proteinGrams: i(json['proteinGrams']),
      carbohydrateGrams: i(json['carbohydrateGrams']),
      fatGrams: i(json['fatGrams']),
      addedSugarLimitGrams: i(json['addedSugarLimitGrams']),
      saturatedFatLimitGrams: i(json['saturatedFatLimitGrams']),
      refWeightMin: d(json['refWeightMin']),
      refWeightMax: d(json['refWeightMax']),
    );
  }
}
