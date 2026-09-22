import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/box_plan.dart';
import '../models/recipe_box.dart';
import '../services/box_store.dart';
import '../theme.dart';
import 'box_shop_screen.dart';

class BoxPlansScreen extends StatefulWidget {
  final VoidCallback onBasket;
  const BoxPlansScreen({super.key, required this.onBasket});
  @override
  State<BoxPlansScreen> createState() => _BoxPlansScreenState();
}

class _BoxPlansScreenState extends State<BoxPlansScreen> {
  BoxPlan selected = BoxPlan.weekly;
  List<String> meals = [
    'shawarma',
    'mujaddara',
    'machboos',
    'falafel',
    'maqluba',
  ];
  bool saving = false;
  void select(BoxPlan plan) => setState(() {
    selected = plan;
    meals = switch (plan) {
      BoxPlan.single => ['shawarma'],
      BoxPlan.day => ['oats', 'machboos', 'falafel'],
      _ => ['shawarma', 'mujaddara', 'machboos', 'falafel', 'maqluba'],
    };
  });
  @override
  Widget build(BuildContext context) {
    final repeats = selected == BoxPlan.monthly ? 4 : 1;
    final subtotal =
        meals.fold<int>(
          0,
          (sum, id) =>
              sum + recipeBoxes.firstWhere((b) => b.id == id).priceFils,
        ) *
        repeats;
    final quote = BoxQuote(
      plan: selected,
      count: selected.boxes,
      subtotal: subtotal,
    );
    final discount = quote.discount;
    final delivery = quote.delivery;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'على قد يومك، وعلى ذوقك.',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'ابدأ بوجبة أو رتّب أسبوعك. كل بوكس يحتوي مقادير تكفي شخصين، والوصفات تختارها أنت.',
                style: TextStyle(fontSize: 16, height: 1.7),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, c) {
                  final columns = c.maxWidth >= 760
                      ? 4
                      : c.maxWidth >= 460
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final plan in BoxPlan.values)
                        SizedBox(
                          width: (c.maxWidth - 12 * (columns - 1)) / columns,
                          child: Semantics(
                            selected: selected == plan,
                            child: Card(
                              color: selected == plan
                                  ? context.palette.primary
                                  : context.palette.bgCard,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: saving ? null : () => select(plan),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        selected == plan
                                            ? Icons.check_circle
                                            : Icons.inventory_2_outlined,
                                        color: selected == plan
                                            ? Colors.white
                                            : context.palette.primary,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        plan.title,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: selected == plan
                                              ? Colors.white
                                              : context.palette.textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        plan.subtitle,
                                        style: TextStyle(
                                          height: 1.6,
                                          color: selected == plan
                                              ? Colors.white
                                              : context.palette.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        plan.discountPercent == 0
                                            ? 'بدون التزام'
                                            : 'خصم تجريبي ${plan.discountPercent}٪',
                                        style: TextStyle(
                                          color: selected == plan
                                              ? const Color(0xFFEBC397)
                                              : context.palette.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                'اختَر وصفات ${selected.title}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selected == BoxPlan.monthly
                    ? '٥ بوكسات كل أسبوع لمدة ٤ أسابيع. تتكرر اختياراتك أسبوعيًا، بإجمالي ٢٠ بوكس و٤ توصيلات.'
                    : '${selected.boxes} بوكس • ${selected.boxes * 2} حصة • توصيل واحد',
              ),
              if (selected.isSubscription)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'الباقة الأسبوعية والشهرية تغطي وجبة واحدة يوميًا، ٥ أيام بالأسبوع. لا يوجد تجديد أو خصم تلقائي في النسخة التجريبية.',
                  ),
                ),
              const SizedBox(height: 20),
              for (var i = 0; i < meals.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('${selected.name}-$i'),
                    initialValue: meals[i],
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: selected == BoxPlan.day
                          ? ['الفطور', 'الغداء', 'العشاء'][i]
                          : 'الوجبة ${i + 1}',
                    ),
                    items: [
                      for (final box in recipeBoxes)
                        DropdownMenuItem(
                          value: box.id,
                          child: Text(
                            '${box.arabicName} · ${money(box.priceFils)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: saving
                        ? null
                        : (value) => setState(() => meals[i] = value!),
                  ),
                ),
              const KitchenKitCard(),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      _line('المقادير والوصفات', money(subtotal)),
                      if (discount > 0)
                        _line(
                          'خصم الباقة ${selected.discountPercent}٪',
                          '− ${money(discount)}',
                        ),
                      _line(
                        'التوصيل (${selected.deliveries})',
                        money(delivery),
                      ),
                      const Divider(),
                      _line('إجمالي الباقة', money(quote.total)),
                      const SizedBox(height: 12),
                      const Text(
                        'أسعار تجريبية. طقم البداية مشمول بلا تكلفة إضافية عند اختياره. لا يتم تحصيل مبالغ.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final store = context.read<BoxStore>();
                          if (store.count > 0) {
                            final replace = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('استبدال محتويات السلة؟'),
                                content: const Text(
                                  'ستحل وصفات الباقة الجديدة محل الوجبات الموجودة في سلتك.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('رجوع'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text('استبدال'),
                                  ),
                                ],
                              ),
                            );
                            if (replace != true || !mounted) return;
                          }
                          setState(() => saving = true);
                          final saved = await saveAction(
                            context,
                            store.configurePlan(selected, List.of(meals)),
                          );
                          if (!mounted) return;
                          setState(() => saving = false);
                          if (saved) widget.onBasket();
                        },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(saving ? 'جارٍ الحفظ…' : 'راجع الباقة في السلة'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class KitchenKitCard extends StatelessWidget {
  const KitchenKitCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
    color: context.palette.bgInput,
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أول مرة تطبخ؟ عدّتك علينا.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(kitchenKitDescription, style: TextStyle(height: 1.7)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in kitchenKit)
                Chip(
                  avatar: const Icon(Icons.check, size: 16),
                  label: Text(item),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'المقادير موزونة لكل وصفة. تحتاج في البيت أدوات الطبخ الأساسية المذكورة في الوصفة.',
          ),
        ],
      ),
    ),
  );
}
