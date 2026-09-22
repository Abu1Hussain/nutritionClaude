import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/models/box_plan.dart';
import 'package:nutrition_app/models/recipe_box.dart';
import 'package:nutrition_app/services/box_store.dart';
import 'package:nutrition_app/screens/box_plans_screen.dart';
import 'package:nutrition_app/screens/cooking_screen.dart';
import 'package:nutrition_app/theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'monthly plan prices twenty boxes and records kit and four deliveries',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final store = BoxStore(prefs);
      await store.configurePlan(BoxPlan.monthly, List.filled(5, 'shawarma'));
      expect(store.count, 20);
      expect(store.subtotal, 128000);
      expect(store.discount, 12800);
      expect(store.total, 115200);
      final restored = BoxStore(prefs);
      expect(restored.plan, BoxPlan.monthly);
      expect(restored.includeKit, isTrue);
      await restored.placeDemoOrder('Manama', 'Tomorrow');
      expect(restored.orders.single['total'], 115200);
      expect(restored.orders.single['deliveries'], 4);
      expect(restored.orders.single['includeKit'], isTrue);
      expect(restored.includeKit, isFalse);
      expect(restored.plan, BoxPlan.single);
    },
  );
  test('day plan and kit opt-out survive reload', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = BoxStore(prefs);
    await store.configurePlan(BoxPlan.day, ['oats', 'machboos', 'falafel']);
    await store.setIncludeKit(false);
    expect(store.total, 17000); // 3900 + 6900 + 5200 + 1000 delivery.
    expect(store.discount, 0);
    expect(BoxStore(prefs).includeKit, isFalse);
  });
  test('incomplete plans cannot receive discounts or be ordered', () async {
    final store = BoxStore(await SharedPreferences.getInstance());
    await store.configurePlan(BoxPlan.weekly, List.filled(5, 'shawarma'));
    expect(store.discount, 1600);
    await store.setQuantity('shawarma', 4);
    expect(store.planComplete, isFalse);
    expect(store.discount, 0);
    await expectLater(
      store.placeDemoOrder('Manama', 'Tomorrow'),
      throwsStateError,
    );
    await store.useSinglePlan();
    expect(store.planComplete, isTrue);
    expect(store.count, 4);
  });
  test('invalid replacement preserves basket and queued checkouts cannot duplicate', () async {
    final store = BoxStore(await SharedPreferences.getInstance());
    await store.setQuantity('machboos', 1);
    await expectLater(
      store.configurePlan(BoxPlan.day, ['bad']),
      throwsArgumentError,
    );
    expect(store.cart, {'machboos': 1});
    final first = store.placeDemoOrder('Manama', 'Tomorrow');
    final second = store.placeDemoOrder('Manama', 'Tomorrow');
    await expectLater(second, throwsStateError);
    await first;
    expect(store.orders.length, 1);
  });
  testWidgets('all plan choices fit a narrow RTL phone with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = BoxStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: BoxPlansScreen(onBasket: () {})),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('اشتراك شهري'), findsOneWidget);
    await tester.ensureVisible(find.text('يوم كامل'));
    await tester.tap(find.text('يوم كامل'));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
  testWidgets('cooking starts only after checking every ingredient', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: CookingScreen(box: recipeBoxes.first),
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    for (final checkbox in find.byType(CheckboxListTile).evaluate().toList()) {
      (checkbox.widget as CheckboxListTile).onChanged!(true);
    }
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('خطوة 1 من 4'), findsOneWidget);
  });
}
