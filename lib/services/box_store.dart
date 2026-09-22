import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe_box.dart';
import '../models/box_plan.dart';

class BoxStore extends ChangeNotifier {
  final SharedPreferences preferences;
  final Map<String, int> _cart = {};
  final Set<String> _favorites = {};
  final List<Map<String, dynamic>> _orders = [];
  BoxPlan _plan = BoxPlan.single;
  bool _includeKit = true;
  Future<void> _writes = Future.value();
  BoxStore(this.preferences) {
    try {
      final raw = jsonDecode(
        preferences.getString('sufra_store_v1') ?? '{}',
      ) as Map<String, dynamic>;
      final cart = Map<String, dynamic>.from(raw['cart'] as Map? ?? {});
      for (final box in recipeBoxes) {
        final value = cart[box.id];
        if (value is int && value > 0) _cart[box.id] = value.clamp(1, 20);
      }
      _favorites.addAll(
        (raw['favorites'] as List? ?? []).whereType<String>().where(
          (id) => recipeBoxes.any((b) => b.id == id),
        ),
      );
      _plan =
          BoxPlan.values.where((p) => p.name == raw['plan']).firstOrNull ??
          BoxPlan.single;
      _includeKit = raw['includeKit'] is bool
          ? raw['includeKit'] as bool
          : true;
      for (final item in (raw['orders'] as List? ?? [])) {
        if (item is Map && item['total'] is int && item['items'] is Map) {
          _orders.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (_) {
      /* Invalid local storage must not prevent startup. */
    }
  }
  Map<String, int> get cart => Map.unmodifiable(_cart);
  List<Map<String, dynamic>> get orders => List.unmodifiable(
    _orders.map(
      (o) => Map<String, dynamic>.unmodifiable({
        ...o,
        'items': Map.unmodifiable(o['items'] as Map),
      }),
    ),
  );
  BoxPlan get plan => _plan;
  bool get includeKit => _includeKit;
  BoxQuote get quote => BoxQuote(plan: _plan, count: count, subtotal: subtotal);
  bool get planComplete => quote.complete;
  bool isFavorite(String id) => _favorites.contains(id);
  int get count => _cart.values.fold(0, (a, b) => a + b);
  int get subtotal => recipeBoxes.fold(
    0,
    (sum, box) => sum + box.priceFils * (_cart[box.id] ?? 0),
  );
  int get discount => quote.discount;
  int get delivery => quote.delivery;
  int get total => quote.total;

  Map<String, dynamic> _data() => {
    'cart': Map<String, int>.from(_cart),
    'favorites': _favorites.toList(),
    'orders': List.of(_orders),
    'plan': _plan.name,
    'includeKit': _includeKit,
  };

  // Serialize mutations and persistence together so a failed write cannot
  // roll back a later successful user action or create duplicate orders.
  Future<T> _change<T>(T Function() action) {
    final result = _writes.then((_) async {
      final previous = _data();
      try {
        final value = action();
        if (!await preferences.setString(
          'sufra_store_v1',
          jsonEncode(_data()),
        )) {
          throw StateError('Could not save on this device.');
        }
        notifyListeners();
        return value;
      } catch (_) {
        _cart
          ..clear()
          ..addAll(previous['cart'] as Map<String, int>);
        _favorites
          ..clear()
          ..addAll(previous['favorites'] as List<String>);
        _orders
          ..clear()
          ..addAll(previous['orders'] as List<Map<String, dynamic>>);
        _plan = BoxPlan.values.byName(previous['plan'] as String);
        _includeKit = previous['includeKit'] as bool;
        notifyListeners();
        rethrow;
      }
    });
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> setQuantity(String id, int quantity) => _change(() {
    if (!recipeBoxes.any((b) => b.id == id)) return;
    if (quantity <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = quantity.clamp(1, 20);
    }
  });
  Future<void> toggleFavorite(String id) => _change(() {
    if (!recipeBoxes.any((b) => b.id == id)) return;
    if (!_favorites.remove(id)) _favorites.add(id);
  });
  Future<void> setIncludeKit(bool value) => _change(() => _includeKit = value);
  Future<void> useSinglePlan() => _change(() => _plan = BoxPlan.single);
  Future<void> configurePlan(BoxPlan plan, List<String> meals) => _change(() {
    if (meals.length != plan.slots ||
        meals.any((id) => !recipeBoxes.any((b) => b.id == id))) {
      throw ArgumentError('Choose a recipe for each slot.');
    }
    _cart.clear();
    for (final id in meals) {
      _cart[id] = (_cart[id] ?? 0) + (plan == BoxPlan.monthly ? 4 : 1);
    }
    _plan = plan;
  });
  Future<String> placeDemoOrder(String area, String slot) => _change(() {
    if (count == 0 || !planComplete)
      throw StateError('Complete your box selection first.');
    if (area.trim().length < 2 ||
        area.trim().length > 80 ||
        slot.trim().isEmpty)
      throw ArgumentError('A sample area and delivery window are required.');
    final id = 'SF-${DateTime.now().microsecondsSinceEpoch}';
    _orders.insert(0, {
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'area': area.trim(),
      'slot': slot,
      'total': total,
      'subtotal': subtotal,
      'discount': discount,
      'delivery': delivery,
      'plan': _plan.name,
      'planTitle': _plan.title,
      'deliveries': _plan.deliveries,
      'includeKit': _includeKit,
      'items': Map<String, int>.from(_cart),
    });
    _cart.clear();
    _plan = BoxPlan.single;
    _includeKit = false;
    return id;
  });
}
