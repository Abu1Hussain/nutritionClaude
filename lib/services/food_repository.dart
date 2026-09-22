import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/food_item.dart';

/// Loads the historical USDA SR Legacy reference dataset (7,793 foods,
/// values per 100 g) bundled as a JSON asset.
class FoodRepository {
  final List<FoodItem> allFoods;
  final Map<int, FoodItem> byId;
  final List<String> categories;

  FoodRepository._(this.allFoods, this.byId, this.categories);

  static Future<FoodRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/foods_data.json');
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final foods = decoded.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList(growable: false);
    final byId = <int, FoodItem>{for (final f in foods) f.id: f};
    final categories = foods.map((f) => f.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    return FoodRepository._(foods, byId, categories);
  }

  List<FoodItem> search({required String query, required String category}) {
    final words = query.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return allFoods.where((f) {
      if (category.isNotEmpty && f.category != category) return false;
      if (words.isEmpty) return true;
      final name = f.name.toLowerCase();
      return words.every((w) => name.contains(w));
    }).toList();
  }
}
