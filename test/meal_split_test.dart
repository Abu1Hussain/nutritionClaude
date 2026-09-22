import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutrition_app/data/app_data.dart';
import 'package:nutrition_app/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  double sumOf(Map<String, double> m) => m.values.fold(0.0, (a, b) => a + b);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to the built-in split when nothing has been edited', () {
    final appState = AppState();
    expect(appState.currentMealPercentages(), mealPctNoDessert);
    expect(appState.hasCustomMealSplit, isFalse);
  });

  test('editing one meal rebalances the others proportionally and sums to 1.0', () {
    final appState = AppState();
    // Defaults: breakfast 0.30, lunch 0.38, dinner 0.32.
    appState.setMealPercentage('lunch', 0.50);

    final result = appState.currentMealPercentages();
    expect(sumOf(result), closeTo(1.0, 1e-9));
    expect(result['lunch'], closeTo(0.50, 1e-9));

    // breakfast:dinner were 0.30:0.32 (ratio preserved) sharing the remaining 0.50.
    const remaining = 0.50;
    const otherSum = 0.30 + 0.32;
    expect(result['breakfast'], closeTo(0.30 / otherSum * remaining, 1e-9));
    expect(result['dinner'], closeTo(0.32 / otherSum * remaining, 1e-9));
    expect(appState.hasCustomMealSplit, isTrue);
  });

  test('clamps an out-of-range request to the 5%-80% band', () {
    final appState = AppState();
    appState.setMealPercentage('breakfast', 0.95);
    expect(appState.currentMealPercentages()['breakfast'], closeTo(0.80, 1e-9));

    appState.resetMealPercentages();
    appState.setMealPercentage('breakfast', 0.01);
    expect(appState.currentMealPercentages()['breakfast'], closeTo(0.05, 1e-9));
  });

  test('resetMealPercentages reverts to the default split', () {
    final appState = AppState();
    appState.setMealPercentage('dinner', 0.6);
    expect(appState.hasCustomMealSplit, isTrue);

    appState.resetMealPercentages();
    expect(appState.hasCustomMealSplit, isFalse);
    expect(appState.currentMealPercentages(), mealPctNoDessert);
  });

  test('toggling dessert clears a custom split (the meal set changed)', () {
    final appState = AppState();
    appState.setMealPercentage('lunch', 0.5);
    expect(appState.hasCustomMealSplit, isTrue);

    appState.setDessertEnabled(true);
    expect(appState.hasCustomMealSplit, isFalse);
    expect(appState.currentMealPercentages(), mealPctWithDessert);
  });

  test('editing a meal with dessert enabled rebalances across all four meals', () {
    final appState = AppState();
    appState.setDessertEnabled(true);
    appState.setMealPercentage('dessert', 0.20);

    final result = appState.currentMealPercentages();
    expect(sumOf(result), closeTo(1.0, 1e-9));
    expect(result.keys.toSet(), {'breakfast', 'lunch', 'dinner', 'dessert'});
    expect(result['dessert'], closeTo(0.20, 1e-9));
  });
}
