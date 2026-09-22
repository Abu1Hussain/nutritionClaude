import 'package:flutter_test/flutter_test.dart';
import 'package:nutrition_app/services/nutrition_calculator.dart';

void main() {
  group('runCalculation', () {
    test('25yo male, 175cm, 70kg, moderately active, maintain matches acceptance figures', () {
      final outcome = runCalculation(
        age: 25,
        sex: 'male',
        heightCm: 175,
        weightKg: 70,
        activityFactor: 1.55,
        goal: 'maintain',
        weeklyRateKg: 0,
      );

      expect(outcome.ok, isTrue);
      expect(double.parse(outcome.bmi.toStringAsFixed(1)), 22.9);
      expect(outcome.bmr.round(), 1674);
      expect(outcome.tdee.round(), 2594);
      expect(outcome.calories, 2594);
    });

    test('macro calories approximately equal target calories', () {
      final outcome = runCalculation(
        age: 25,
        sex: 'male',
        heightCm: 175,
        weightKg: 70,
        activityFactor: 1.55,
        goal: 'maintain',
        weeklyRateKg: 0,
      );
      final macroCalories =
          outcome.proteinGrams * 4 + outcome.carbohydrateGrams * 4 + outcome.fatGrams * 9;
      expect((macroCalories - outcome.calories).abs(), lessThan(10));
    });

    test('0.25, 0.5, and 0.75 kg/week all work for both losing and gaining weight', () {
      for (final rate in [0.25, 0.5, 0.75]) {
        for (final goal in ['lose', 'gain']) {
          final outcome = runCalculation(
            age: 30,
            sex: 'male',
            heightCm: 180,
            weightKg: 85,
            activityFactor: 1.55,
            goal: goal,
            weeklyRateKg: rate,
          );
          expect(outcome.ok, isTrue, reason: '$goal at $rate kg/week should succeed for this body size');
          expect(outcome.calories, greaterThan(0));
        }
      }
    });

    test('0.75 kg/week is not blocked merely for being aggressive', () {
      final outcome = runCalculation(
        age: 30,
        sex: 'female',
        heightCm: 165,
        weightKg: 70,
        activityFactor: 1.55,
        goal: 'lose',
        weeklyRateKg: 0.75,
      );
      expect(outcome.ok, isTrue);
    });

    test('non-positive calorie result produces an error, never a negative plan', () {
      // runCalculation accepts any rate (the UI only offers 0.25/0.5/0.75);
      // a larger rate is used here to reliably force a non-positive result.
      final outcome = runCalculation(
        age: 20,
        sex: 'female',
        heightCm: 120,
        weightKg: 35,
        activityFactor: 1.2,
        goal: 'lose',
        weeklyRateKg: 2.0,
      );
      expect(outcome.ok, isFalse);
      expect(outcome.errorMessage, contains('non-positive'));
      expect(outcome.calories, 0);
    });

    test('weight loss below BMI 18.5 is blocked with a specific message', () {
      final outcome = runCalculation(
        age: 25,
        sex: 'male',
        heightCm: 175,
        weightKg: 45, // BMI ~14.7
        activityFactor: 1.375,
        goal: 'lose',
        weeklyRateKg: 0.5,
      );
      expect(outcome.ok, isFalse);
      expect(outcome.errorMessage, contains('BMI reference range'));
    });

    test('weekly calorie adjustment matches the 7,700 kcal/kg approximation', () {
      final maintain = runCalculation(
        age: 30, sex: 'male', heightCm: 180, weightKg: 85, activityFactor: 1.55,
        goal: 'maintain', weeklyRateKg: 0,
      );
      final losing = runCalculation(
        age: 30, sex: 'male', heightCm: 180, weightKg: 85, activityFactor: 1.55,
        goal: 'lose', weeklyRateKg: 0.5,
      );
      expect(maintain.calories - losing.calories, 550); // 7700 * 0.5 / 7
    });
  });

  group('BMI helpers', () {
    test('computeBmi matches weight / height(m)^2', () {
      expect(computeBmi(70, 175), closeTo(22.857, 0.001));
    });

    test('computeRefWeightRange matches 18.5-24.9 band for the given height', () {
      final range = computeRefWeightRange(175);
      expect(range.min, closeTo(56.66, 0.05));
      expect(range.max, closeTo(76.27, 0.05));
    });
  });
}
