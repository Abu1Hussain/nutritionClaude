import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../models/nutrition_target.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/common.dart';
import '../widgets/share_dialog.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _ageCtrl = TextEditingController(text: '25');
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '70');

  String _sex = 'male';
  double _activity = 1.375;
  String _goal = 'maintain';
  double _weeklyRate = 0.25;
  bool _eligibility = false;

  final Map<String, String> _fieldErrors = {};
  String? _formErrorBanner;
  String? _calcError;
  bool _stale = false;
  Map<String, Object?>? _lastSnapshot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromState());
  }

  void _restoreFromState() {
    final appState = context.read<AppState>();
    final t = appState.target;
    if (t == null) return;
    setState(() {
      _ageCtrl.text = t.age.toString();
      _heightCtrl.text = _trimNum(t.heightCm);
      _weightCtrl.text = _trimNum(t.weightKg);
      _sex = t.sex;
      _activity = t.activityFactor;
      _goal = t.goal;
      _weeklyRate = t.weeklyRateKg == 0 ? 0.25 : t.weeklyRateKg;
      _eligibility = t.sex == 'female';
      _lastSnapshot = _currentSnapshot();
    });
  }

  String _trimNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Map<String, Object?> _currentSnapshot() => {
        'age': _ageCtrl.text,
        'height': _heightCtrl.text,
        'weight': _weightCtrl.text,
        'sex': _sex,
        'activity': _activity,
        'goal': _goal,
        'rate': _weeklyRate,
        'eligibility': _eligibility,
      };

  void _onAnyFieldChanged() {
    final appState = context.read<AppState>();
    if (appState.target == null) return;
    final now = _currentSnapshot();
    final changed = _lastSnapshot == null || !_mapsEqual(now, _lastSnapshot!);
    if (changed != _stale) setState(() => _stale = changed);
  }

  bool _mapsEqual(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final appState = context.read<AppState>();
    _fieldErrors.clear();
    _formErrorBanner = null;

    final age = int.tryParse(_ageCtrl.text.trim());
    if (age == null || age < 20 || age > 100) {
      _fieldErrors['age'] = 'Please enter an age between 20 and 100.';
    }
    final height = double.tryParse(_heightCtrl.text.trim());
    if (height == null || height < 120 || height > 230) {
      _fieldErrors['height'] = 'Please enter a valid height between 120 and 230 cm.';
    }
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight < 35 || weight > 300) {
      _fieldErrors['weight'] = 'Please enter a valid weight between 35 and 300 kg.';
    }
    if (_sex == 'female' && !_eligibility) {
      _fieldErrors['eligibility'] = 'This calculator is designed for adults 20 or older who are not pregnant or '
          'breastfeeding. Please confirm the statement above to continue.';
    }

    if (_fieldErrors.isNotEmpty) {
      setState(() => _formErrorBanner = 'Please correct the highlighted fields above.');
      return;
    }

    final outcome = appState.calculate(
      age: age!,
      sex: _sex,
      heightCm: height!,
      weightKg: weight!,
      activityFactor: _activity,
      goal: _goal,
      weeklyRateKg: _weeklyRate,
    );

    setState(() {
      if (outcome.ok) {
        _calcError = null;
        _stale = false;
        _lastSnapshot = _currentSnapshot();
      } else {
        _calcError = outcome.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final inputs = _buildInputsColumn(p);
      final results = _buildResultsColumn();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimate your daily nutrition targets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Answer a few questions to get an estimated daily calorie and macronutrient target. This tool '
              'provides general wellness estimates, not medical advice.',
              style: TextStyle(color: p.textMuted),
            ),
            const SizedBox(height: 20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: inputs),
                  const SizedBox(width: 24),
                  Expanded(child: results),
                ],
              )
            else
              Column(children: [inputs, const SizedBox(height: 20), results]),
          ],
        ),
      );
    });
  }

  Widget _buildInputsColumn(AppPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => _onAnyFieldChanged(),
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  helperText: 'Supported range: 20-100. This calculator is designed for adults.',
                  errorText: _fieldErrors['age'],
                ),
              ),
              const SizedBox(height: 14),
              Text('Sex for calculation', style: TextStyle(color: p.textMuted, fontSize: 13)),
              const SizedBox(height: 6),
              Text('Used by the resting-energy (Mifflin-St Jeor) equation.',
                  style: TextStyle(color: p.textDim, fontSize: 11.5)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'male', label: Text('Male')),
                  ButtonSegment(value: 'female', label: Text('Female')),
                ],
                selected: {_sex},
                onSelectionChanged: (s) => setState(() {
                  _sex = s.first;
                  if (_sex != 'female') _eligibility = false;
                  _onAnyFieldChanged();
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _onAnyFieldChanged(),
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  helperText: 'Supported range: 120-230 cm.',
                  errorText: _fieldErrors['height'],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _onAnyFieldChanged(),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  helperText: 'Supported range: 35-300 kg.',
                  errorText: _fieldErrors['weight'],
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<double>(
                initialValue: _activity,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Activity level'),
                items: [
                  for (final a in activityLevels)
                    DropdownMenuItem(
                      value: a.factor,
                      child: Text('${a.label} – ${a.description}', overflow: TextOverflow.ellipsis),
                    )
                ],
                onChanged: (v) => setState(() {
                  _activity = v!;
                  _onAnyFieldChanged();
                }),
              ),
              const SizedBox(height: 6),
              Text('Consider movement at work and daily life, not only planned workouts.',
                  style: TextStyle(color: p.textDim, fontSize: 11.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _goalCard(p, 'lose', '↓', 'Lose fat'),
                  _goalCard(p, 'maintain', '→', 'Maintain weight'),
                  _goalCard(p, 'gain', '↑', 'Gain muscle'),
                ],
              ),
              if (_goal != 'maintain') ...[
                const SizedBox(height: 16),
                Text('Weekly rate', style: TextStyle(color: p.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 0.25, label: Text('0.25 kg/wk')),
                    ButtonSegment(value: 0.5, label: Text('0.5 kg/wk')),
                    ButtonSegment(value: 0.75, label: Text('0.75 kg/wk (aggressive)')),
                  ],
                  selected: {_weeklyRate},
                  onSelectionChanged: (s) => setState(() {
                    _weeklyRate = s.first;
                    _onAnyFieldChanged();
                  }),
                ),
              ],
            ],
          ),
        ),
        if (_sex == 'female') ...[
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: _eligibility,
                  onChanged: (v) => setState(() {
                    _eligibility = v ?? false;
                    _onAnyFieldChanged();
                  }),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text("I'm 20 or older and I'm not pregnant or breastfeeding."),
                ),
                if (_fieldErrors['eligibility'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(_fieldErrors['eligibility']!, style: TextStyle(color: p.error, fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text('Your inputs stay on this device. Nothing you enter here is sent to an external server.',
            style: TextStyle(color: p.textDim, fontSize: 11.5)),
        const SizedBox(height: 16),
        if (_formErrorBanner != null) NoticeBanner(text: _formErrorBanner!, kind: NoticeKind.error),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _submit, child: const Text('Calculate Target')),
        ),
        const SizedBox(height: 16),
        const ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text('How These Estimates Work', style: TextStyle(fontWeight: FontWeight.w700)),
          children: [
            _ExplainSection(
              title: 'Resting energy (Mifflin-St Jeor equation)',
              body: 'Resting energy is estimated with the Mifflin-St Jeor equation, based on weight, height, '
                  'age, and sex. It is a population-level estimate, not a measurement of your personal '
                  'metabolism.',
            ),
            _ExplainSection(
              title: 'Activity multiplication',
              body: 'Resting energy is multiplied by an activity factor (1.2 to 1.9) to approximate total daily '
                  'energy expenditure (TDEE).',
            ),
            _ExplainSection(
              title: 'Weight-change approximation',
              body: 'Weight change is approximated using 7,700 kcal per kilogram. This is a simplified estimate; '
                  'actual results vary by individual.',
            ),
            _ExplainSection(
              title: 'Macronutrient percentages',
              body: 'Protein, carbohydrate, and fat targets use a prototype split of 25% / 45% / 30% of total '
                  'calories -- one reasonable distribution among many.',
            ),
            _ExplainSection(
              title: 'Sugar and saturated-fat limits',
              body: 'Added-sugar and saturated-fat figures are upper limits (10% of calories each), not goals to '
                  'reach. Total sugar shown for foods/meals is a different measurement than an added-sugar limit.',
            ),
            _ExplainSection(
              title: 'Uncertainty of predictions',
              body: 'Any weekly rate is an estimate; results are not guaranteed. A 0.75 kg/week target is '
                  'aggressive and may be unsuitable for some people.',
            ),
            _ExplainSection(
              title: 'BMI limitations',
              body: 'BMI is a screening measure based on height and weight only. It does not directly measure '
                  'body fat or account for muscle mass.',
            ),
            _ExplainSection(
              title: 'Meal data limitations',
              body: 'Meal nutrient values come from a historical USDA reference dataset. Missing nutrients are '
                  'shown as unavailable rather than assumed to be zero.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _goalCard(AppPalette p, String value, String icon, String label) {
    final selected = _goal == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() {
        _goal = value;
        _onAnyFieldChanged();
      }),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.15) : p.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? p.accent : p.border),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 22, color: selected ? p.accent : p.textMuted)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? p.accent : p.textMuted,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsColumn() {
    return Consumer<AppState>(builder: (context, appState, _) {
      final p = context.palette;
      final t = appState.target;
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_calcError != null) NoticeBanner(text: _calcError!, kind: NoticeKind.error),
            if (t == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'Fill in the form and select Calculate Target to see your BMI gauge and daily nutrition '
                  'targets here.',
                  style: TextStyle(color: p.textMuted),
                ),
              )
            else
              _ResultsView(target: t, stale: _stale),
          ],
        ),
      );
    });
  }
}

class _ExplainSection extends StatelessWidget {
  final String title;
  final String body;
  const _ExplainSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 13.5)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final NutritionTarget target;
  final bool stale;
  const _ResultsView({required this.target, required this.stale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stale)
          const NoticeBanner(
            text: 'Inputs have changed. Select Calculate Target again to update your results.',
            kind: NoticeKind.warning,
          ),
        const Text('BMI reference gauge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ExcludeSemantics(child: BmiGauge(bmi: t.bmi)),
        const SizedBox(height: 6),
        Center(
          child: Column(
            children: [
              Text(t.bmi.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
              Text(bmiStatus(t.bmi), style: TextStyle(color: p.accent, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('BMI ${t.bmi.toStringAsFixed(1)} — ${bmiStatus(t.bmi)}.',
            semanticsLabel: 'BMI ${t.bmi.toStringAsFixed(1)}, status ${bmiStatus(t.bmi)}',
            style: TextStyle(color: p.textDim, fontSize: 12)),
        const SizedBox(height: 10),
        Text(
          'BMI is a screening estimate, not a diagnosis. It does not directly measure body fat or account for '
          'differences such as muscle mass. The four shaded bands on each side of the reference range are '
          'visual subdivisions used by this app, not four official clinical diagnoses.',
          style: TextStyle(color: p.textMuted, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        Text(
          'Reference weight range for your height: ${fmtNum1(t.refWeightMin)}–${fmtNum1(t.refWeightMax)} kg',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        Divider(height: 32, color: p.border),
        const Text('Energy summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        StatRow(label: 'BMI', value: t.bmi.toStringAsFixed(1)),
        StatRow(label: 'BMI status', value: bmiStatus(t.bmi)),
        StatRow(label: 'Resting energy', value: '${fmtInt(t.bmr)} kcal'),
        StatRow(label: 'Daily expenditure', value: '${fmtInt(t.tdee)} kcal'),
        StatRow(label: 'Target calories', value: '${fmtInt(t.calories)} kcal'),
        StatRow(label: 'Selected goal', value: goalLabels[t.goal] ?? t.goal),
        if (t.goal != 'maintain') StatRow(label: 'Selected weekly rate', value: '${t.weeklyRateKg} kg/week'),
        const SizedBox(height: 12),
        if (t.goal != 'maintain')
          const NoticeBanner(
            text: 'Actual weight change is not guaranteed. This target is an estimate and may need adjustment '
                'over time.',
          ),
        if (t.goal != 'maintain' && t.weeklyRateKg == 0.75)
          const NoticeBanner(
            text: 'A 0.75 kg/week target is aggressive and may be unsuitable. Review this estimate with a '
                'qualified professional before following it.',
            kind: NoticeKind.warning,
          ),
        Divider(height: 32, color: p.border),
        const Text('Daily nutrient targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth >= 500 ? 3 : 2;
          final cards = [
            NutrientCard(name: 'Calories', value: fmtInt(t.calories), unit: 'kcal', isLimit: false),
            NutrientCard(name: 'Protein', value: fmtInt(t.proteinGrams), unit: 'g', isLimit: false),
            NutrientCard(name: 'Carbohydrates', value: fmtInt(t.carbohydrateGrams), unit: 'g', isLimit: false),
            NutrientCard(name: 'Fat', value: fmtInt(t.fatGrams), unit: 'g', isLimit: false),
            NutrientCard(name: 'Added sugar', value: fmtInt(t.addedSugarLimitGrams), unit: 'g', isLimit: true),
            NutrientCard(name: 'Saturated fat', value: fmtInt(t.saturatedFatLimitGrams), unit: 'g', isLimit: true),
          ];
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: cards,
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => showShareTargetsDialog(context, t),
            child: const Text('Share My Targets'),
          ),
        ),
      ],
    );
  }
}
