import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_data.dart';
import '../models/nutrition_target.dart';
import '../theme.dart';
import 'common.dart';

String buildShareText(NutritionTarget t) {
  return 'My $appName daily nutrition targets\n\n'
      'Calories: ${fmtInt(t.calories)} kcal\n'
      'Protein: ${fmtInt(t.proteinGrams)} g\n'
      'Carbohydrates: ${fmtInt(t.carbohydrateGrams)} g\n'
      'Fat: ${fmtInt(t.fatGrams)} g\n'
      'Added sugar: under ${fmtInt(t.addedSugarLimitGrams)} g\n'
      'Saturated fat: under ${fmtInt(t.saturatedFatLimitGrams)} g\n\n'
      'General wellness estimates, not medical advice.\n\n'
      'Calo menu: $caloMenuUrl';
}

/// Preview-then-share dialog. Shares only nutrition targets -- never age,
/// sex, height, weight, or BMI.
Future<void> showShareTargetsDialog(BuildContext context, NutritionTarget target) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ShareDialog(target: target),
  );
}

class _ShareDialog extends StatefulWidget {
  final NutritionTarget target;
  const _ShareDialog({required this.target});

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = buildShareText(widget.target);
    return AlertDialog(
      backgroundColor: p.bgCard,
      title: const Text('Share my targets'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This preview contains only your nutrition targets. Your age, sex, height, weight, and BMI '
              'are not included.',
              style: TextStyle(color: p.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.bgInput,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
            ),
            const SizedBox(height: 8),
            Text(_status, style: TextStyle(color: p.accent, fontSize: 12.5)),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (mounted) setState(() => _status = 'Copied to clipboard.');
              },
              child: const Text('Copy Targets'),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await SharePlus.instance.share(ShareParams(text: text, subject: '$appName targets'));
                  if (mounted) setState(() => _status = 'Shared.');
                } catch (_) {
                  if (mounted) {
                    setState(() => _status = 'Sharing is not available here. You can still copy the text above.');
                  }
                }
              },
              child: const Text('Share…'),
            ),
          ],
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
