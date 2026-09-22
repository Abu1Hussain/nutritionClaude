import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_box.dart';
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
        const SnackBar(
          content: Text('تعذّر حفظ التغييرات على هذا الجهاز. حاول مرة أخرى.'),
        ),
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
  const BoxShopScreen({super.key, this.favoritesOnly = false, this.onPlans});
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
                              const Text(
                                'مقادير جاهزة. طبخة من يدك.',
                                style: TextStyle(
                                  color: Color(0xFFEBC397),
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'طبخ صحي،\nأسهل مما تتخيّل.',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: c.maxWidth > 650 ? 44 : 34,
                                  height: 1.1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ما تعرف تطبخ؟ أو يومك مزدحم؟ نوصل لك المقادير الموزونة، وصفة واضحة، وعدّة البداية. اختَر وجبتك وخلّ الباقي علينا.',
                                style: TextStyle(
                                  color: Color(0xFFE0E6DC),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(label: Text('حصتان في كل بوكس')),
                                  Chip(label: Text('مقادير + وصفة + أدوات')),
                                ],
                              ),
                              if (widget.onPlans != null) ...[
                                const SizedBox(height: 16),
                                FilledButton.tonalIcon(
                                  onPressed: widget.onPlans,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('اختَر باقتك'),
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
                  const Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _Promise(
                        Icons.shopping_basket_outlined,
                        'مقادير موزونة بدون حيرة',
                      ),
                      _Promise(
                        Icons.monitor_heart_outlined,
                        'سعرات وبروتين لكل حصة',
                      ),
                      _Promise(
                        Icons.menu_book_outlined,
                        'نتعلّم الطبخ خطوة بخطوة',
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                ],
                Text(
                  widget.favoritesOnly ? 'وجباتك المفضلة' : 'وش نطبخ اليوم؟',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نكهات نحبها، وخيارات تناسب يومك • أسعار تجريبية بالدينار البحريني',
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
                        label: Text(a),
                        selected: audience == a,
                        onSelected: (_) => setState(() => audience = a),
                      ),
                  ],
                ),
                if (audience != 'الكل')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(switch (audience) {
                      'أول مرة أطبخ' => 'وصفات حتى ٣٠ دقيقة. افتح الوصفة وابدأ وضع الطبخ خطوة بخطوة.',
                      'للرياضيين' =>
                        '٣٥ غ بروتين أو أكثر للحصة؛ اختَر ما يناسب احتياجك.',
                      'سفرة العائلة' => 'كل بوكس يكفي شخصين؛ زِد الكمية في السلة حسب عدد أفراد البيت.',
                      _ => '٢٠ غ بروتين أو أكثر وحتى ٧٠٠ سعرة للحصة. القيم تقديرية وليست توصية شخصية.',
                    }),
                  ),
                const SizedBox(height: 22),
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث عن وجبة أو نكهة تحبها…',
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
                          {
                            'All boxes': 'كل الوجبات',
                            'Breakfast': 'فطور',
                            'Chicken': 'دجاج',
                            'Meat': 'لحوم',
                            'Plant-based': 'نباتي',
                          }[c]!,
                        ),
                        selected: category == c,
                        onSelected: (_) => setState(() => category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (boxes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'ما لقينا وجبات هنا. جرّب بحثًا آخر أو أضف وجبة للمفضلة.',
                    ),
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
                          SizedBox(width: width, child: _BoxCard(box)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (!widget.favoritesOnly) const KitchenKitCard(),
                const SizedBox(height: 24),
                Text(
                  'Nutrition values are illustrative estimates per serving. Photos are AI-generated serving suggestions. Final recipes, allergens and prices need supplier verification.',
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
  const _BoxCard(this.box);
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
                onTap: () => _openDetails(context, box),
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
                          const Text(
                            'للبوكس • يكفي شخصين',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _openDetails(context, box),
                      child: const Text('شوف الوصفة'),
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

void _openDetails(BuildContext context, RecipeBox box) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: BoxDetailScreen(box: box),
        ),
      ),
    );

class BoxDetailScreen extends StatelessWidget {
  final RecipeBox box;
  const BoxDetailScreen({super.key, required this.box});
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
                  '${box.minutes} minutes • 2 servings • ${money(box.priceFils)} / box',
                ),
                const SizedBox(height: 24),
                const Text(
                  'القيم التقديرية للحصة الواحدة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                NutritionStrip(box),
                const SizedBox(height: 10),
                Text(
                  'Whole box: ${box.calories * 2} kcal • ${box.protein * 2}g protein • ${box.carbs * 2}g carbs • ${box.fat * 2}g fat',
                ),
                const SizedBox(height: 24),
                const Text(
                  'مقادير البوكس',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  label: const Text('ابدأ الطبخ خطوة بخطوة'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'من البوكس إلى السفرة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                for (var i = 0; i < box.steps.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(box.steps[i]),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Sample recipe guidance and nutrition; verify final quantities and cooking instructions before commercial use.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text('أضف للسلة · ${money(box.priceFils)}'),
                    onPressed: () async {
                      final store = context.read<BoxStore>();
                      final saved = await saveAction(
                        context,
                        store.setQuantity(
                          box.id,
                          (store.cart[box.id] ?? 0) + 1,
                        ),
                      );
                      if (saved && context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${box.name} is in your basket'),
                          ),
                        );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'سلتك، على ذوقك',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text('كل بوكس يشمل المقادير والوصفة لشخصين.'),
              const SizedBox(height: 24),
              if (store.count == 0) ...[
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('سلتك فاضية. اختَر وجبة تعجبك ونجهّز مقاديرها.'),
                ),
                FilledButton(
                  onPressed: onBrowse,
                  child: const Text('تصفّح الوجبات'),
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
                              tooltip: 'Remove one ${box.name}',
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
                              tooltip: 'Add one ${box.name}',
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
                  '${store.count} بوكس • ${store.count * 2} حصة • ${store.plan.deliveries} توصيل',
                ),
                if (!store.planComplete) ...[
                  Text(
                    'هذه الباقة تتطلب ${store.plan.boxes} بوكس. عدّل الكمية أو حوّل السلة إلى شراء منفرد.',
                  ),
                  TextButton(
                    onPressed: () => saveAction(context, store.useSinglePlan()),
                    child: const Text('تحويل إلى شراء منفرد'),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('أضف طقم البداية مجانًا'),
                  subtitle: const Text(kitchenKitDescription),
                  value: store.includeKit,
                  onChanged: (v) => saveAction(context, store.setIncludeKit(v)),
                ),
                _price('الوجبات (${store.count})', store.subtotal),
                if (store.discount > 0) _price('خصم الباقة', -store.discount),
                _price('التوصيل', store.delivery),
                const Divider(),
                _price('الإجمالي', store.total),
                const SizedBox(height: 12),
                const Text(
                  'توصيل تجريبي: دينار لكل توصيل، مجانًا للباقة إذا بلغ مجموع وجباتها ٢٠ دينارًا قبل الخصم.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !store.planComplete
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const Directionality(
                                textDirection: TextDirection.rtl,
                                child: CheckoutScreen(),
                              ),
                            ),
                          ),
                    child: const Text('متابعة الطلب التجريبي'),
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

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  String area = '', slot = 'غدًا · ٤–٧ مساءً';
  bool saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('مراجعة الطلب التجريبي')),
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
                const Text(
                  'باقي خطوة على تجربتك الأولى',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'هذا طلب تجريبي محفوظ على جهازك فقط. لا يتم الدفع أو إرسال الطلب أو حجز التوصيل. استخدم منطقة افتراضية؛ لا نحتاج بياناتك الشخصية.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'منطقة التوصيل (تجريبية)',
                    hintText: 'مثال: المنامة',
                  ),
                  maxLength: 80,
                  onSaved: (v) => area = v!.trim(),
                  validator: (v) =>
                      (v?.trim().length ?? 0) < 2 ? 'أدخل منطقة التوصيل' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: slot,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'موعد أول توصيل (تجريبي)',
                  ),
                  items: [
                    for (final s in [
                      'غدًا · ٤–٧ مساءً',
                      'غدًا · ٧–١٠ مساءً',
                      'بعد يومين · ٤–٧ مساءً',
                    ])
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) => setState(() => slot = v!),
                ),
                const SizedBox(height: 20),
                Text('الباقة: ${context.watch<BoxStore>().plan.title}'),
                Text(
                  '${context.watch<BoxStore>().count} بوكس • ${context.watch<BoxStore>().plan.deliveries} توصيل',
                ),
                Text(
                  context.watch<BoxStore>().includeKit
                      ? 'طقم البداية مشمول في أول توصيل'
                      : 'بدون طقم أدوات',
                ),
                if (context.watch<BoxStore>().plan.isSubscription)
                  const Text(
                    'باقة تجريبية لمدة محددة، بدون تجديد تلقائي. الموعد المختار لأول توصيل؛ الجدولة اللاحقة تحتاج خدمة توصيل فعلية.',
                  ),
                const SizedBox(height: 24),
                Text(
                  'الإجمالي: ${money(context.watch<BoxStore>().total)}',
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
                                title: const Text('تم حفظ الطلب التجريبي'),
                                content: const Text(
                                  'ستجد الطلب في «طلباتي» على هذا الجهاز. لم يتم حجز توصيل أو تحصيل أي مبلغ.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('تم'),
                                  ),
                                ],
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                          } catch (_) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تعذّر حفظ الطلب. محتويات السلة موجودة؛ حاول مرة أخرى.',
                                  ),
                                ),
                              );
                          } finally {
                            if (mounted) setState(() => saving = false);
                          }
                        },
                  child: Text(saving ? 'جارٍ الحفظ…' : 'حفظ الطلب التجريبي'),
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
        const Text(
          'طلباتك',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'طلبات تجريبية محفوظة على هذا الجهاز؛ لا يوجد تتبّع توصيل فعلي.',
        ),
        const SizedBox(height: 24),
        if (orders.isEmpty)
          const Text('أول طبخة تبدأ من هنا. تصفّح الوجبات أو اختَر باقتك.'),
        for (final order in orders)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Chip(label: Text('تجريبي • محفوظ على الجهاز')),
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
                    '${order['planTitle'] ?? 'وجبات منفردة'} • ${order['deliveries'] ?? 1} توصيل',
                  ),
                  if (order['includeKit'] == true)
                    const Text('يشمل طقم البداية'),
                  const SizedBox(height: 12),
                  Text('${order['area']} • ${order['slot']}'),
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
