// Basic smoke test: the app boots, loads persisted state and the food
// database, and lands on the recipe-box storefront without throwing.
//
// Loading the bundled JSON asset does real file I/O, so the async setup is
// run via tester.runAsync() to escape flutter_test's fake-async zone.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nutrition_app/main.dart';
import 'package:nutrition_app/screens/calculator_screen.dart';
import 'package:nutrition_app/services/app_state.dart';

void main() {
  testWidgets('NutriVision boots and shows Arabic recipe boxes', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.runAsync(() async {
      await tester.pumpWidget(const NutriVisionRoot());
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.text('وش نطبخ اليوم؟'), findsOneWidget);
    expect(find.text('Chicken Machboos'), findsOneWidget);
  });

  testWidgets('the light/dark mode toggle button switches themes without error', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.runAsync(() async {
      await tester.pumpWidget(const NutriVisionRoot());
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    final toggle = find.byIcon(Icons.dark_mode_outlined);
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pump();

    expect(app().themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    // The screen should still render normally after the theme switch.
    expect(find.text('وش نطبخ اليوم؟'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pump();
    expect(app().themeMode, ThemeMode.light);
  });

  testWidgets('editing a meal rebalances the calorie split across the rest of the day',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.runAsync(() async {
      await tester.pumpWidget(const NutriVisionRoot());
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    await tester.tap(find.byTooltip('Nutrition tools'));
    await tester.pumpAndSettle();

    final appState = Provider.of<AppState>(find.byType(CalculatorScreen).evaluate().first, listen: false);
    appState.calculate(
      age: 25,
      sex: 'male',
      heightCm: 175,
      weightKg: 70,
      activityFactor: 1.55,
      goal: 'maintain',
      weeklyRateKg: 0,
    );
    // Skip the required meal-preferences step for this test (it's covered
    // separately) so the plan itself renders.
    appState.savePreferences(dislikes: const [], allergies: const {});
    await tester.pump();

    // Navigate to Meal Plan via its icon (labels are hidden for unselected
    // NavigationRail destinations at this test viewport width).
    await tester.tap(find.byIcon(Icons.restaurant_menu_outlined));
    await tester.pump();

    expect(find.text('30% of day'), findsOneWidget); // breakfast default
    expect(find.text('38% of day'), findsOneWidget); // lunch default
    expect(find.text('32% of day'), findsOneWidget); // dinner default
    expect(find.text('Reset to default meal split'), findsNothing);

    // Invoke the edit button's callback directly rather than tapping by
    // screen coordinates -- robust regardless of where the card scrolls to.
    final editButton = tester.widget<IconButton>(find.byKey(const Key('edit-meal-lunch')));
    editButton.onPressed!();
    await tester.pump();

    final dialogField = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
    expect(dialogField, findsOneWidget);
    await tester.enterText(dialogField, '1200');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pump();

    // 1200/2594 ~= 46.26% for lunch; breakfast/dinner rescale to keep their
    // 30:32 ratio over the remaining ~53.74%, per AppState.setMealPercentage.
    expect(find.text('46% of day'), findsOneWidget);
    expect(find.text('26% of day'), findsOneWidget);
    expect(find.text('28% of day'), findsOneWidget);
    expect(find.text('Reset to default meal split'), findsOneWidget);

    final resetButton = tester.widget<TextButton>(find.byKey(const Key('reset-meal-split')));
    resetButton.onPressed!();
    await tester.pump();

    expect(find.text('30% of day'), findsOneWidget);
    expect(find.text('38% of day'), findsOneWidget);
    expect(find.text('32% of day'), findsOneWidget);
  });
}
