import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../models/recipe_box.dart';
import '../services/app_state.dart';
import '../services/box_store.dart';
import '../theme.dart';
import '../models/box_plan.dart';
import 'box_plans_screen.dart';
import 'cooking_screen.dart';

Future<bool> saveAction(BuildContext context, Future<void> action) async {
  try {
    await action;
    return true;
  } catch (_) {
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('shop.errorSave'))),
      );
    return false;
  }
}

/// One bundled photography atlas; each meal displays its own tile offline.
class MealPhoto extends StatelessWidget {
  final RecipeBox box;
  const MealPhoto(this.box, {super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Illustrative photo of ${box.name}',
    image: true,
    child: box.photo < 0
        ? AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              color: context.palette.bgInput,
              child: Icon(
                Icons.breakfast_dining_outlined,
                size: 80,
                color: context.palette.primary,
              ),
            ),
          )
        : AspectRatio(
            aspectRatio: 1.5,
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, size) => OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: size.maxWidth * 3,
                  maxWidth: size.maxWidth * 3,
                  minHeight: size.maxHeight * 2,
                  maxHeight: size.maxHeight * 2,
                  child: Transform.translate(
                    offset: Offset(
                      -(box.photo % 3) * size.maxWidth,
                      -(box.photo ~/ 3) * size.maxHeight,
                    ),
                    child: Image.asset(
                      'assets/images/arabic_meals.png',
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
  );
}

class BoxShopScreen extends StatefulWidget {
  final bool favoritesOnly;
  final VoidCallback? onPlans;
  final VoidCallback? onAddedToCart;
  const BoxShopScreen({
    super.key,
    this.favoritesOnly = false,
    this.onPlans,
    this.onAddedToCart,
  });
  @override
  State<BoxShopScreen> createState() => _BoxShopScreenState();
}

class _BoxShopScreenState extends State<BoxShopScreen> {
  String query = '', category = 'All boxes', audience = 'الكل';
  @override
  Widget build(BuildContext context) {
    final store = context.watch<BoxStore>();
    final boxes = recipeBoxes
        .where(
          (b) =>
              (!widget.favoritesOnly || store.isFavorite(b.id)) &&
              (category == 'All boxes' || b.category == category) &&
              (audience != 'أول مرة أطبخ' || b.minutes <= 30) &&
              (audience != 'للرياضيين' || b.protein >= 35) &&
              (audience != 'وجبة متوازنة' ||
                  (b.protein >= 20 && b.calories <= 700)) &&
              '${b.name} ${b.arabicName} ${b.region}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.favoritesOnly) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF253E32),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final copy = Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('shop.tagline'),
                                style: const TextStyle(
                                  color: Color(0xFFEBC397),
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                context.tr('shop.headline'),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: c.maxWidth > 650 ? 44 : 34,
                                  height: 1.1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('shop.body'),
                                style: const TextStyle(
                                  color: Color(0xFFE0E6DC),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(label: Text(context.tr('shop.chip.oneServing'))),
                                  Chip(label: Text(context.tr('shop.chip.kit'))),
                                ],
                              ),
                              if (widget.onPlans != null) ...[
                                const SizedBox(height: 16),
                                FilledButton.tonalIcon(
                                  onPressed: widget.onPlans,
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(context.tr('shop.choosePlan')),
                                ),
                              ],
                            ],
                          ),
                        );
                        if (c.maxWidth < 650)
                          return Column(
                            children: [
                              copy,
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: ClipRect(
                                  child: OverflowBox(
                                    maxHeight: 400,
                                    child: MealPhoto(
                                      recipeBoxes.firstWhere(
                                        (b) => b.id == 'machboos',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        return Row(
                          children: [
                            Expanded(child: copy),
                            Expanded(
                              child: MealPhoto(
                                recipeBoxes.firstWhere(
                                  (b) => b.id == 'machboos',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _Promise(
                        Icons.shopping_basket_outlined,
                        context.tr('shop.promise.weighed'),
                      ),
                      _Promise(
                        Icons.monitor_heart_outlined,
                        context.tr('shop.promise.nutrition'),
                      ),
                      _Promise(
                        Icons.menu_book_outlined,
                        context.tr('shop.promise.learn'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                ],
                Text(
                  widget.favoritesOnly
                      ? context.tr('shop.title.favorites')
                      : context.tr('shop.title.today'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('shop.subtitle'),
                  style: TextStyle(color: context.palette.textMuted),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in [
                      'الكل',
                      'أول مرة أطبخ',
                      'للرياضيين',
                      'سفرة العائلة',
                      'وجبة متوازنة',
                    ])
                      ChoiceChip(
                        label: Text(context.tr(switch (a) {
                          'أول مرة أطبخ' => 'audience.beginner',
                          'للرياضيين' => 'audience.athletes',
                          'سفرة العائلة' => 'audience.family',
                          'وجبة متوازنة' => 'audience.balanced',
                          _ => 'audience.all',
                        })),
                        selected: audience == a,
                        onSelected: (_) => setState(() => audience = a),
                      ),
                  ],
                ),
                if (audience != 'الكل')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(context.tr(switch (audience) {
                      'أول مرة أطبخ' => 'audience.desc.beginner',
                      'للرياضيين' => 'audience.desc.athletes',
                      'سفرة العائلة' => 'audience.desc.family',
                      _ => 'audience.desc.balanced',
                    })),
                  ),
                const SizedBox(height: 22),
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.tr('shop.searchHint'),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in [
                      'All boxes',
                      'Breakfast',
                      'Chicken',
                      'Meat',
                      'Plant-based',
                    ])
                      ChoiceChip(
                        label: Text(
                          context.tr({
                            'All boxes': 'category.all',
                            'Breakfast': 'category.breakfast',
                            'Chicken': 'category.chicken',
                            'Meat': 'category.meat',
                            'Plant-based': 'category.plant',
                          }[c]!),
                        ),
                        selected: category == c,
                        onSelected: (_) => setState(() => category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (boxes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(context.tr('shop.empty')),
                  ),
                LayoutBuilder(
                  builder: (context, c) {
                    final columns = c.maxWidth >= 960
                        ? 3
                        : c.maxWidth >= 620
                        ? 2
                        : 1;
                    final width = (c.maxWidth - (columns - 1) * 20) / columns;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final box in boxes)
                          SizedBox(
                            width: width,
                            child: _BoxCard(box, onAddedToCart: widget.onAddedToCart),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (!widget.favoritesOnly) const KitchenKitCard(),
                const SizedBox(height: 24),
                Text(
                  context.tr('shop.disclaimer'),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Promise(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: context.palette.primary),
      const SizedBox(width: 8),
      Flexible(child: Text(text, style: const TextStyle(fontSize: 12))),
    ],
  );
}

class _BoxCard extends StatelessWidget {
  final RecipeBox box;
  final VoidCallback? onAddedToCart;
  const _BoxCard(this.box, {this.onAddedToCart});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<BoxStore>();
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () => _openDetails(context, box, onAddedToCart),
                child: MealPhoto(box),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Chip(label: Text(box.region)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filledTonal(
                  tooltip: store.isFavorite(box.id)
                      ? 'Remove favourite'
                      : 'Save favourite',
                  onPressed: () =>
                      saveAction(context, store.toggleFavorite(box.id)),
                  icon: Icon(
                    store.isFavorite(box.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${box.minutes} MIN  ·  ${box.category.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: context.palette.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  box.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    fontSize: 23,
                  ),
                ),
                Text(
                  box.arabicName,
                  style: TextStyle(
                    color: context.palette.textMuted,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                NutritionStrip(box),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            money(box.priceFils),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            context.tr('box.perBox'),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _openDetails(context, box, onAddedToCart),
                      child: Text(context.tr('box.viewRecipe')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionStrip extends StatelessWidget {
  final RecipeBox box;
  final int multiplier;
  const NutritionStrip(this.box, {super.key, this.multiplier = 1});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: context.palette.bgInput,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final stat in [
          ('${box.calories * multiplier}', 'kcal'),
          ('${box.protein * multiplier}g', 'protein'),
          ('${box.carbs * multiplier}g', 'carbs'),
          ('${box.fat * multiplier}g', 'fat'),
        ])
          Expanded(
            child: Column(
              children: [
                Text(
                  stat.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  stat.$2,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

void _openDetails(
  BuildContext context,
  RecipeBox box, [
  VoidCallback? onAddedToCart,
]) {
  final language = context.read<AppState>().language;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Directionality(
        textDirection: language == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
        child: BoxDetailScreen(box: box, onAddedToCart: onAddedToCart),
      ),
    ),
  );
}

class BoxDetailScreen extends StatelessWidget {
  final RecipeBox box;
  final VoidCallback? onAddedToCart;
  const BoxDetailScreen({super.key, required this.box, this.onAddedToCart});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(box.name)),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: MealPhoto(box),
                ),
                const SizedBox(height: 24),
                Text(
                  box.arabicName,
                  style: TextStyle(
                    color: context.palette.primary,
                    fontSize: 22,
                  ),
                ),
                Text(
                  box.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(box.description, style: const TextStyle(height: 1.7)),
                const SizedBox(height: 16),
                Text(
                  '${box.minutes} minutes • 1 serving • ${money(box.priceFils)} / box',
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('detail.perServingValues'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                NutritionStrip(box),
                const SizedBox(height: 24),
                Text(
                  context.tr('detail.ingredients'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                for (final ingredient in box.ingredients)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle_outline,
                      color: context.palette.primary,
                    ),
                    title: Text(ingredient),
                  ),
                Text(
                  'Allergens: ${box.allergens.isEmpty ? 'No declared allergens in this sample recipe' : box.allergens.join(', ')}. Check final packaging for allergens and cross-contact.',
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CookingScreen(box: box),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(context.tr('detail.startCooking')),
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('detail.fromBoxToTable'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                for (var i = 0; i < box.steps.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(box.steps[i]),
                  ),
                const SizedBox(height: 16),
                Text(
                  context.tr('detail.sampleGuidance'),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text('${context.tr('detail.addToBasket')} · ${money(box.priceFils)}'),
                    onPressed: () async {
                      final store = context.read<BoxStore>();
                      final saved = await saveAction(
                        context,
                        store.setQuantity(
                          box.id,
                          (store.cart[box.id] ?? 0) + 1,
                        ),
                      );
                      if (saved && context.mounted) {
                        Navigator.of(context).pop();
                        onAddedToCart?.call();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BasketScreen extends StatelessWidget {
  final VoidCallback onBrowse;
  const BasketScreen({super.key, required this.onBrowse});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<BoxStore>();
    final language = context.watch<AppState>().language;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('basket.title'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(context.tr('basket.subtitle')),
              const SizedBox(height: 24),
              if (store.count == 0) ...[
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(context.tr('basket.empty')),
                ),
                FilledButton(
                  onPressed: onBrowse,
                  child: Text(context.tr('basket.browse')),
                ),
              ],
              for (final box in recipeBoxes.where(
                (b) => store.cart.containsKey(b.id),
              ))
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MealPhoto(box),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    box.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    money(box.priceFils * store.cart[box.id]!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: '${context.tr('basket.removeOne')} ${box.name}',
                              onPressed: () => saveAction(
                                context,
                                store.setQuantity(
                                  box.id,
                                  store.cart[box.id]! - 1,
                                ),
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${store.cart[box.id]}'),
                            IconButton(
                              tooltip: '${context.tr('basket.addOne')} ${box.name}',
                              onPressed: store.cart[box.id]! >= 20
                                  ? null
                                  : () => saveAction(
                                      context,
                                      store.setQuantity(
                                        box.id,
                                        store.cart[box.id]! + 1,
                                      ),
                                    ),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (store.count > 0) ...[
                const SizedBox(height: 20),
                Text(
                  store.plan.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context
                      .tr('basket.summary')
                      .replaceAll('{count}', '${store.count}')
                      .replaceAll('{deliveries}', '${store.plan.deliveries}'),
                ),
                if (!store.planComplete) ...[
                  Text(
                    context.tr('basket.planIncomplete').replaceAll('{n}', '${store.plan.boxes}'),
                  ),
                  TextButton(
                    onPressed: () => saveAction(context, store.useSinglePlan()),
                    child: Text(context.tr('basket.convertSingle')),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('basket.includeKit')),
                  subtitle: Text(
                    language == AppLanguage.en ? context.tr('kit.description') : kitchenKitDescription,
                  ),
                  value: store.includeKit,
                  onChanged: (v) => saveAction(context, store.setIncludeKit(v)),
                ),
                _price('${context.tr('basket.lineMeals')} (${store.count})', store.subtotal),
                if (store.discount > 0) _price(context.tr('basket.lineDiscount'), -store.discount),
                _price(context.tr('basket.lineDelivery'), store.delivery),
                const Divider(),
                _price(context.tr('basket.lineTotal'), store.total),
                const SizedBox(height: 12),
                Text(context.tr('basket.deliveryNote')),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !store.planComplete
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => Directionality(
                                textDirection: language == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
                                child: const CheckoutScreen(),
                              ),
                            ),
                          ),
                    child: Text(context.tr('basket.checkoutCta')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _price(String label, int value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(money(value), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

const _checkoutSlots = ['slot1', 'slot2', 'slot3'];

String slotLabel(BuildContext context, String slot) =>
    _checkoutSlots.contains(slot) ? context.tr('checkout.$slot') : slot;

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  String area = '', slot = 'slot1';
  bool saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('checkout.title'))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('checkout.headline'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(context.tr('checkout.disclaimer')),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: context.tr('checkout.areaLabel'),
                    hintText: context.tr('checkout.areaHint'),
                  ),
                  maxLength: 80,
                  onSaved: (v) => area = v!.trim(),
                  validator: (v) =>
                      (v?.trim().length ?? 0) < 2 ? context.tr('checkout.areaValidator') : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: slot,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.tr('checkout.slotLabel'),
                  ),
                  items: [
                    for (final s in _checkoutSlots)
                      DropdownMenuItem(value: s, child: Text(slotLabel(context, s))),
                  ],
                  onChanged: (v) => setState(() => slot = v!),
                ),
                const SizedBox(height: 20),
                Text('${context.tr('checkout.planLabel')}: ${context.watch<BoxStore>().plan.title}'),
                Text(
                  context
                      .tr('checkout.deliveryLine')
                      .replaceAll('{count}', '${context.watch<BoxStore>().count}')
                      .replaceAll('{deliveries}', '${context.watch<BoxStore>().plan.deliveries}'),
                ),
                Text(
                  context.watch<BoxStore>().includeKit
                      ? context.tr('checkout.kitIncluded')
                      : context.tr('checkout.kitNotIncluded'),
                ),
                if (context.watch<BoxStore>().plan.isSubscription)
                  Text(context.tr('checkout.subscriptionNote')),
                const SizedBox(height: 24),
                Text(
                  '${context.tr('checkout.total')}: ${money(context.watch<BoxStore>().total)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      saving ||
                          context.watch<BoxStore>().count == 0 ||
                          !context.watch<BoxStore>().planComplete
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) return;
                          _form.currentState!.save();
                          setState(() => saving = true);
                          try {
                            await context.read<BoxStore>().placeDemoOrder(
                              area,
                              slot,
                            );
                            if (!context.mounted) return;
                            await showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (c) => AlertDialog(
                                title: Text(context.tr('checkout.savedTitle')),
                                content: Text(context.tr('checkout.savedBody')),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: Text(context.tr('checkout.done')),
                                  ),
                                ],
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                          } catch (_) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.tr('checkout.errorSave'))),
                              );
                          } finally {
                            if (mounted) setState(() => saving = false);
                          }
                        },
                  child: Text(saving ? context.tr('checkout.saving') : context.tr('checkout.save')),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BoxOrdersScreen extends StatelessWidget {
  const BoxOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = context.watch<BoxStore>().orders;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.tr('orders.title'),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(context.tr('orders.subtitle')),
        const SizedBox(height: 24),
        if (orders.isEmpty) Text(context.tr('orders.empty')),
        for (final order in orders)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(context.tr('orders.sampleChip'))),
                  Text(
                    '${order['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${order['date']}'.split('T').first),
                  const SizedBox(height: 12),
                  for (final box in recipeBoxes.where(
                    (b) => (order['items'] as Map).containsKey(b.id),
                  ))
                    Text('${(order['items'] as Map)[box.id]} × ${box.name}'),
                  Text(
                    '${order['planTitle'] ?? context.tr('orders.singleMeals')} • ${order['deliveries'] ?? 1}',
                  ),
                  if (order['includeKit'] == true)
                    Text(context.tr('orders.kitIncluded')),
                  const SizedBox(height: 12),
                  Text('${order['area']} • ${slotLabel(context, '${order['slot']}')}'),
                  Text(
                    money(order['total'] as int),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
