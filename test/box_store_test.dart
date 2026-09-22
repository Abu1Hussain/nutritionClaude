import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/models/recipe_box.dart';
import 'package:nutrition_app/services/box_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('basket quantities, delivery boundary and persistence', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = BoxStore(prefs);
    expect(store.total, 0);
    await store.setQuantity('machboos', 2);
    expect(store.subtotal, 6900);
    expect(store.total, 7900);
    await store.setQuantity('machboos', 6);
    expect(store.delivery, 0);
    await store.toggleFavorite('machboos');
    final restored = BoxStore(prefs);
    expect(restored.count, 6);
    expect(restored.isFavorite('machboos'), isTrue);
    await store.setQuantity('machboos', 0);
    expect(store.total, 0);
  });
  test('demo order snapshots basket and survives reload', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = BoxStore(prefs);
    await store.setQuantity('mujaddara', 2);
    final id = await store.placeDemoOrder('Manama', 'Tomorrow · 4–7 PM');
    expect(store.count, 0);
    final restored = BoxStore(prefs);
    expect(restored.orders.single['id'], id);
    expect(restored.orders.single['total'], 5900);
    expect(restored.orders.single['items'], {'mujaddara': 2});
    await expectLater(store.placeDemoOrder('Manama', 'Tomorrow'), throwsStateError);
  });
  test('invalid local data and quantity limits are handled', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sufra_store_v1', 'broken json');
    final store = BoxStore(prefs);
    await store.setQuantity('unknown', 3);
    expect(store.count, 0);
    await store.setQuantity('falafel', 500);
    expect(store.count, 20);
    await store.setQuantity('falafel', -1);
    expect(store.count, 0);
  });
  test('catalog has unique IDs, complete recipes and coherent energy', () {
    expect(recipeBoxes.map((b) => b.id).toSet().length, recipeBoxes.length);
    for (final box in recipeBoxes) {
      expect(box.calories, box.protein * 4 + box.carbs * 4 + box.fat * 9);
      expect(box.ingredients, isNotEmpty);
      expect(box.steps, isNotEmpty);
      expect(box.priceFils, greaterThan(0));
    }
  });
}
