import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
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
              Text(
                context.tr('plans.headline'),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('plans.subtitle'),
                style: const TextStyle(fontSize: 16, height: 1.7),
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
                                            ? context.tr('plans.noCommitment')
                                            : context
                                                  .tr('plans.sampleDiscount')
                                                  .replaceAll('{pct}', '${plan.discountPercent}'),
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
                context.tr('plans.chooseRecipesFor').replaceAll('{plan}', selected.title),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selected == BoxPlan.monthly
                    ? context.tr('plans.monthlySummary')
                    : context.tr('plans.summary').replaceAll('{boxes}', '${selected.boxes}'),
              ),
              if (selected.isSubscription)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.tr('plans.subscriptionNote')),
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
                          ? [
                              context.tr('plans.breakfast'),
                              context.tr('plans.lunch'),
                              context.tr('plans.dinner'),
                            ][i]
                          : context.tr('plans.mealLabel').replaceAll('{n}', '${i + 1}'),
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
                      _line(context.tr('plans.lineIngredients'), money(subtotal)),
                      if (discount > 0)
                        _line(
                          context.tr('plans.discountPct').replaceAll('{pct}', '${selected.discountPercent}'),
                          '− ${money(discount)}',
                        ),
                      _line(
                        context.tr('plans.deliveryCount').replaceAll('{n}', '${selected.deliveries}'),
                        money(delivery),
                      ),
                      const Divider(),
                      _line(context.tr('plans.lineTotal'), money(quote.total)),
                      const SizedBox(height: 12),
                      Text(context.tr('plans.pricesNote')),
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
                                title: Text(context.tr('plans.replaceTitle')),
                                content: Text(context.tr('plans.replaceBody')),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: Text(context.tr('plans.back')),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text(context.tr('plans.replace')),
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
                  label: Text(saving ? context.tr('plans.saving') : context.tr('plans.reviewInBasket')),
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

const _kitItemKeys = ['kit.item.spoons', 'kit.item.scoop', 'kit.item.thermometer', 'kit.item.scale'];

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
          Text(
            context.tr('plans.kit.title'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(context.tr('kit.description'), style: const TextStyle(height: 1.7)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in _kitItemKeys)
                Chip(
                  avatar: const Icon(Icons.check, size: 16),
                  label: Text(context.tr(key)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.tr('plans.kit.note')),
        ],
      ),
    ),
  );
}
