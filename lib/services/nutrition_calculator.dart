/// Pure calculation helpers. Mirrors the web app's verified formulas exactly
/// (Mifflin-St Jeor BMR, activity-factor TDEE, 7,700 kcal/kg weekly-rate
/// approximation, 25/45/30 macro split, 10%/10% sugar and sat-fat limits).
library nutrition_calculator;

class RefWeightRange {
  final double min;
  final double max;
  const RefWeightRange(this.min, this.max);
}

double computeBmi(double weightKg, double heightCm) {
  final h = heightCm / 100;
  return weightKg / (h * h);
}

RefWeightRange computeRefWeightRange(double heightCm) {
  final h = heightCm / 100;
  return RefWeightRange(18.5 * h * h, 24.9 * h * h);
}

double computeBmr(String sex, double weightKg, double heightCm, int age) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return sex == 'male' ? base + 5 : base - 161;
}

/// Result of attempting to build a nutrition target from validated inputs.
class CalculationOutcome {
  final bool ok;
  final String? errorMessage;
  final double bmi;
  final double bmr;
  final double tdee;
  final int calories;
  final int proteinGrams;
  final int carbohydrateGrams;
  final int fatGrams;
  final int addedSugarLimitGrams;
  final int saturatedFatLimitGrams;
  final RefWeightRange refWeightRange;

  const CalculationOutcome._({
    required this.ok,
    required this.errorMessage,
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.addedSugarLimitGrams,
    required this.saturatedFatLimitGrams,
    required this.refWeightRange,
  });

  factory CalculationOutcome.failure(String message, double bmi, double bmr, double tdee, RefWeightRange range) {
    return CalculationOutcome._(
      ok: false,
      errorMessage: message,
      bmi: bmi,
      bmr: bmr,
      tdee: tdee,
      calories: 0,
      proteinGrams: 0,
      carbohydrateGrams: 0,
      fatGrams: 0,
      addedSugarLimitGrams: 0,
      saturatedFatLimitGrams: 0,
      refWeightRange: range,
    );
  }

  factory CalculationOutcome.success({
    required double bmi,
    required double bmr,
    required double tdee,
    required int calories,
    required RefWeightRange refWeightRange,
  }) {
    final proteinGrams = (calories * 0.25 / 4).round();
    final carbohydrateGrams = (calories * 0.45 / 4).round();
    final fatGrams = (calories * 0.30 / 9).round();
    final addedSugarLimitGrams = (calories * 0.10 / 4).round();
    final saturatedFatLimitGrams = (calories * 0.10 / 9).round();
    return CalculationOutcome._(
      ok: true,
      errorMessage: null,
      bmi: bmi,
      bmr: bmr,
      tdee: tdee,
      calories: calories,
      proteinGrams: proteinGrams,
      carbohydrateGrams: carbohydrateGrams,
      fatGrams: fatGrams,
      addedSugarLimitGrams: addedSugarLimitGrams,
      saturatedFatLimitGrams: saturatedFatLimitGrams,
      refWeightRange: refWeightRange,
    );
  }
}

/// Runs the full calculation pipeline given already-range-validated inputs.
/// Returns a failure outcome (with a specific message) for the two
/// business-rule failures: losing weight below BMI 18.5, and a non-positive
/// calorie estimate. Never returns NaN/Infinity/negative calories.
CalculationOutcome runCalculation({
  required int age,
  required String sex,
  required double heightCm,
  required double weightKg,
  required double activityFactor,
  required String goal,
  required double weeklyRateKg,
}) {
  final bmi = computeBmi(weightKg, heightCm);
  final range = computeRefWeightRange(heightCm);
  final bmr = computeBmr(sex, weightKg, heightCm, age);
  final tdee = bmr * activityFactor;

  if (goal == 'lose' && bmi < 18.5) {
    return CalculationOutcome.failure(
      'Weight-loss targets are unavailable below the adult BMI reference range (18.5). If weight loss is still '
      'a goal, please speak with a qualified professional for personalized guidance.',
      bmi,
      bmr,
      tdee,
      range,
    );
  }

  double adjustment = 0;
  if (goal != 'maintain') {
    adjustment = 7700 * weeklyRateKg / 7;
  }

  double calories;
  if (goal == 'lose') {
    calories = tdee - adjustment;
  } else if (goal == 'gain') {
    calories = tdee + adjustment;
  } else {
    calories = tdee;
  }

  if (calories <= 0) {
    return CalculationOutcome.failure(
      'This rate produces a non-positive calorie estimate. Choose a slower rate or speak with a qualified '
      'professional.',
      bmi,
      bmr,
      tdee,
      range,
    );
  }

  return CalculationOutcome.success(
    bmi: bmi,
    bmr: bmr,
    tdee: tdee,
    calories: calories.round(),
    refWeightRange: range,
  );
}
