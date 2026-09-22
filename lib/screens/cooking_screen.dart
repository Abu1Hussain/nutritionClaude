import 'package:flutter/material.dart';

import '../models/recipe_box.dart';
import '../theme.dart';

class CookingScreen extends StatefulWidget {
  final RecipeBox box;
  const CookingScreen({super.key, required this.box});
  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final Set<int> ready = {};
  int step = -1;
  @override
  Widget build(BuildContext context) {
    final box = widget.box;
    final finished = step == box.steps.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(box.arabicName)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  finished
                      ? 'بالعافية عليك!'
                      : step < 0
                      ? 'جهّز مقاديرك أولًا'
                      : 'خطوة ${step + 1} من ${box.steps.length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (step + 1) / (box.steps.length + 1),
                ),
                const SizedBox(height: 24),
                if (step < 0) ...[
                  Text(
                    'وقت الوصفة التقريبي ${box.minutes} دقيقة • حصتان. ضع علامة على كل مكوّن عندما يكون جاهزًا.',
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < box.ingredients.length; i++)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: ready.contains(i),
                      title: Text(box.ingredients[i]),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          ready.add(i);
                        } else {
                          ready.remove(i);
                        }
                      }),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'راجع مسببات الحساسية وتعليمات العبوة قبل البدء. هذه وصفة توضيحية؛ اتّبع تعليمات المنتج المعتمدة عند توفره.',
                  ),
                ] else if (!finished)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 40,
                            color: context.palette.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            box.steps[step],
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(fontSize: 24, height: 1.7),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    Icons.task_alt,
                    size: 90,
                    color: context.palette.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'قسّم الوجبة إلى حصتين. القيم الغذائية المعروضة في صفحة الوصفة محسوبة للحصة الواحدة.',
                    style: TextStyle(fontSize: 20, height: 1.7),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: step < 0 && ready.length != box.ingredients.length
                      ? null
                      : () {
                          if (finished) {
                            Navigator.pop(context);
                          } else {
                            setState(() => step++);
                          }
                        },
                  child: Text(
                    finished
                        ? 'العودة للوصفة'
                        : step < 0
                        ? 'جاهز، نبدأ الطبخ'
                        : step == box.steps.length - 1
                        ? 'أنهيت الوصفة'
                        : 'الخطوة التالية',
                  ),
                ),
                if (step >= 0)
                  TextButton(
                    onPressed: () => setState(() => step--),
                    child: const Text('الخطوة السابقة'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
