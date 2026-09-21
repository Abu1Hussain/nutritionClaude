import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/food_repository.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FoodsScreen extends StatefulWidget {
  final FoodRepository repository;
  const FoodsScreen({super.key, required this.repository});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  static const int perPage = 18;

  final _searchCtrl = TextEditingController();
  String _category = '';
  int _page = 1;
  List<FoodItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.repository.allFoods;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _filtered = widget.repository.search(query: _searchCtrl.text, category: _category);
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final totalPages = (_filtered.length / perPage).ceil().clamp(1, 1 << 30);
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * perPage;
    final pageItems = _filtered.skip(start).take(perPage).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Food database', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Search a historical USDA reference dataset (SR Legacy) of ${widget.repository.allFoods.length} '
            'foods. All values are shown per 100 g.',
            style: TextStyle(color: p.textMuted),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            final search = TextField(
              controller: _searchCtrl,
              onChanged: (_) => _applyFilter(),
              decoration: const InputDecoration(
                hintText: 'Search foods, e.g. chicken, rice, apple',
                prefixIcon: Icon(Icons.search),
              ),
            );
            final categoryDropdown = DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(value: '', child: Text('All categories', overflow: TextOverflow.ellipsis)),
                for (final c in widget.repository.categories)
                  DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) {
                _category = v ?? '';
                _applyFilter();
              },
            );
            if (wide) {
              return Row(
                children: [
                  Expanded(flex: 2, child: search),
                  const SizedBox(width: 12),
                  Expanded(child: categoryDropdown),
                ],
              );
            }
            return Column(children: [search, const SizedBox(height: 12), categoryDropdown]);
          }),
          const SizedBox(height: 12),
          Text('${_filtered.length} ${_filtered.length == 1 ? 'food found' : 'foods found'}',
              style: TextStyle(color: p.textMuted, fontSize: 13)),
          const SizedBox(height: 4),
          Text('A dash means the nutrient was not reported; it does not mean zero.',
              style: TextStyle(color: p.textDim, fontSize: 11.5)),
          const SizedBox(height: 16),
          if (pageItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No foods match your search. Try a different term or category.',
                    style: TextStyle(color: p.textMuted)),
              ),
            )
          else
            LayoutBuilder(builder: (context, constraints) {
              final cols = responsiveColumns(constraints.maxWidth, desktop: 3, tablet: 2, mobile: 1);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.55,
                children: [for (final f in pageItems) _FoodCard(food: f)],
              );
            }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: page > 1 ? () => setState(() => _page = page - 1) : null,
                child: const Text('Previous'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Page $page of $totalPages', style: TextStyle(color: p.textMuted)),
              ),
              OutlinedButton(
                onPressed: page < totalPages ? () => setState(() => _page = page + 1) : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem food;
  const _FoodCard({required this.food});

  String _dash(double? v) => v == null ? '—' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(food.name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          if (food.category.isNotEmpty) Text(food.category, style: TextStyle(color: p.textDim, fontSize: 11)),
          const SizedBox(height: 4),
          Text('Per 100 g', style: TextStyle(color: p.textDim, fontSize: 10.5)),
          const Spacer(),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _nutrient(p, 'Cal', _dash(food.calories)),
              _nutrient(p, 'Prot', '${_dash(food.protein)}g'),
              _nutrient(p, 'Carb', '${_dash(food.carbs)}g'),
              _nutrient(p, 'Fat', '${_dash(food.fat)}g'),
              _nutrient(p, 'Sugar', '${_dash(food.sugar)}g'),
              _nutrient(p, 'Sat.', '${_dash(food.satFat)}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutrient(AppPalette p, String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        Text(label, style: TextStyle(color: p.textDim, fontSize: 9)),
      ],
    );
  }
}
