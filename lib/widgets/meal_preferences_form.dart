import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/meal.dart';
import '../theme.dart';
import 'common.dart';

/// The required meal-plan preferences step: foods the user dislikes
/// (free text, a soft preference) and allergies/intolerances (a fixed,
/// safety-critical list kept separate from dislikes). Saving always
/// succeeds, including with everything left empty ("no restrictions") --
/// "required" here means the step is always shown before the plan, not
/// that a restriction must be entered.
class MealPreferencesForm extends StatefulWidget {
  final List<String> initialDislikes;
  final Set<Allergen> initialAllergies;
  final void Function(List<String> dislikes, Set<Allergen> allergies) onSave;
  final VoidCallback? onCancel;

  const MealPreferencesForm({
    super.key,
    required this.initialDislikes,
    required this.initialAllergies,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<MealPreferencesForm> createState() => _MealPreferencesFormState();
}

class _MealPreferencesFormState extends State<MealPreferencesForm> {
  final List<String> _dislikes = [];
  final Set<Allergen> _allergies = {};

  @override
  void initState() {
    super.initState();
    _dislikes.addAll(widget.initialDislikes);
    _allergies.addAll(widget.initialAllergies);
  }
  final _dislikeCtrl = TextEditingController();

  @override
  void dispose() {
    _dislikeCtrl.dispose();
    super.dispose();
  }

  void _addDislike() {
    final text = _dislikeCtrl.text.trim();
    if (text.isEmpty || _dislikes.any((d) => d.toLowerCase() == text.toLowerCase())) return;
    setState(() {
      _dislikes.add(text);
      _dislikeCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Meal plan preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            "We'll skip any illustrative meal recipe that conflicts with what you list below before showing "
            'your plan.',
            style: TextStyle(color: p.textMuted, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          Text('Allergies or intolerances', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: p.textMain)),
          const SizedBox(height: 4),
          Text(
            'Safety-critical: matching recipes are automatically excluded, never just deprioritized.',
            style: TextStyle(color: p.textDim, fontSize: 11.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in allergenTaxonomy)
                FilterChip(
                  label: Text(a.label),
                  selected: _allergies.contains(a),
                  onSelected: (sel) => setState(() {
                    if (sel) {
                      _allergies.add(a);
                    } else {
                      _allergies.remove(a);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Foods you dislike', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: p.textMain)),
          const SizedBox(height: 4),
          Text(
            'A softer preference: we avoid these where a suitable alternative exists.',
            style: TextStyle(color: p.textDim, fontSize: 11.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dislikeCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. mushrooms'),
                  onSubmitted: (_) => _addDislike(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addDislike, child: const Text('Add')),
            ],
          ),
          if (_dislikes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in _dislikes)
                  Chip(
                    label: Text(d),
                    onDeleted: () => setState(() => _dislikes.remove(d)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onSave(_dislikes, _allergies),
                  child: const Text('Save preferences'),
                ),
              ),
              if (widget.onCancel != null) ...[
                const SizedBox(width: 10),
                TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
