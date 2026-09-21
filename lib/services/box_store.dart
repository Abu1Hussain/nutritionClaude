import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_box.dart';

class BoxStore extends ChangeNotifier {
  final SharedPreferences preferences;
  final Map<String, int> _cart = {};
  final Set<String> _favorites = {};
  final List<Map<String, dynamic>> _orders = [];
  Future<void> _writes = Future.value();
  BoxStore(this.preferences) {
    try {
      final raw = jsonDecode(preferences.getString('sufra_store_v1') ?? '{}') as Map<String, dynamic>;
      final cart = Map<String, dynamic>.from(raw['cart'] as Map? ?? {});
      for (final box in recipeBoxes) {
        final value = cart[box.id];
        if (value is int && value > 0) _cart[box.id] = value.clamp(1, 20);
      }
      _favorites.addAll((raw['favorites'] as List? ?? []).whereType<String>());
      _orders.addAll((raw['orders'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) { /* Keep a usable empty store if older local data is invalid. */ }
  }
  Map<String, int> get cart => Map.unmodifiable(_cart);
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  bool isFavorite(String id) => _favorites.contains(id);
  int get count => _cart.values.fold(0, (a, b) => a + b);
  int get subtotal => recipeBoxes.fold(0, (sum, box) => sum + box.priceFils * (_cart[box.id] ?? 0));
  int get delivery => count == 0 || subtotal >= 20000 ? 0 : 1000;
  int get total => subtotal + delivery;
  Future<void> _save() {
    final data = jsonEncode({'cart': _cart, 'favorites': _favorites.toList(), 'orders': _orders});
    final result = _writes.then((_) async {
      if (!await preferences.setString('sufra_store_v1', data)) throw StateError('Could not save on this device.');
    });
    _writes = result.catchError((Object _) {});
    return result;
  }
  Future<void> setQuantity(String id, int quantity) async {
    if (!recipeBoxes.any((b) => b.id == id)) return;
    if (quantity <= 0) { _cart.remove(id); } else { _cart[id] = quantity.clamp(1, 20); }
    notifyListeners();
    await _save();
  }
  Future<void> toggleFavorite(String id) async {
    if (!_favorites.remove(id)) _favorites.add(id);
    notifyListeners();
    await _save();
  }
  Future<String> placeDemoOrder(String area, String slot) async {
    if (count == 0) throw StateError('Your box is empty.');
    final id = 'SF-${DateTime.now().microsecondsSinceEpoch}';
    final previous = Map<String, int>.from(_cart);
    _orders.insert(0, {'id': id, 'date': DateTime.now().toIso8601String(), 'area': area,
      'slot': slot, 'total': total, 'items': Map<String, int>.from(_cart)});
    _cart.clear();
    try { await _save(); } catch (_) {
      _orders.removeAt(0); _cart.addAll(previous); rethrow;
    }
    notifyListeners();
    return id;
  }
}
