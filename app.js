// ============================================================
//  NutriVision -- app.js
//  Sections: Navigation | Calculator | BMI Gauge | Meal Plan | Share | Foods
// ============================================================

'use strict';

const APP_NAME = 'NutriVision';
const STORAGE_KEY = 'nutrivision_state_v1';
const DAILY_STEP_TARGET = 5000;
const STEPS_PER_COIN = 1000;

const GOAL_LABELS = { lose: 'Lose fat', maintain: 'Maintain weight', gain: 'Gain muscle' };

const state = {
  target: null,          // last successfully calculated nutrition target object
  lastSnapshot: null,    // JSON string of form inputs at the time of the last successful calculation
  lastFormRaw: null,     // raw form values at the time of the last successful calculation (for persistence)
  foods: (typeof FOODS_DATA !== 'undefined' && Array.isArray(FOODS_DATA)) ? FOODS_DATA : [],
  filteredFoods: [],
  foodsPage: 1,
  FOODS_PER_PAGE: 18,
  dessertEnabled: false,
  currentMeals: [],
  stepsLog: {},           // { 'YYYY-MM-DD': steps }
  redemptions: [],        // [{ id, rewardId, name, cost, timestamp }]
  notificationsEnabled: false
};

const FOOD_BY_ID = {};
state.foods.forEach(function (f) { FOOD_BY_ID[f.id] = f; });

const REWARDS_CATALOG = [
  { id: 'amzn-10', name: 'Amazon Gift Card $10', category: 'Gift Cards', cost: 100, icon: '🛒' },
  { id: 'amzn-25', name: 'Amazon Gift Card $25', category: 'Gift Cards', cost: 240, icon: '🛒' },
  { id: 'amzn-50', name: 'Amazon Gift Card $50', category: 'Gift Cards', cost: 460, icon: '🛒' },
  { id: 'amzn-100', name: 'Amazon Gift Card $100', category: 'Gift Cards', cost: 900, icon: '🛒' },
  { id: 'psn-10', name: 'PlayStation Store Card $10', category: 'Gaming', cost: 100, icon: '🎮' },
  { id: 'psn-25', name: 'PlayStation Store Card $25', category: 'Gaming', cost: 240, icon: '🎮' },
  { id: 'psn-50', name: 'PlayStation Store Card $50', category: 'Gaming', cost: 460, icon: '🎮' },
  { id: 'xbox-10', name: 'Xbox Gift Card $10', category: 'Gaming', cost: 100, icon: '🎮' },
  { id: 'xbox-25', name: 'Xbox Gift Card $25', category: 'Gaming', cost: 240, icon: '🎮' },
  { id: 'xbox-50', name: 'Xbox Gift Card $50', category: 'Gaming', cost: 460, icon: '🎮' },
  { id: 'steam-10', name: 'Steam Wallet Card $10', category: 'Gaming', cost: 100, icon: '🎮' },
  { id: 'steam-25', name: 'Steam Wallet Card $25', category: 'Gaming', cost: 240, icon: '🎮' },
  { id: 'steam-50', name: 'Steam Wallet Card $50', category: 'Gaming', cost: 460, icon: '🎮' },
  { id: 'steam-100', name: 'Steam Wallet Card $100', category: 'Gaming', cost: 900, icon: '🎮' },
  { id: 'spotify-1', name: 'Spotify Premium - 1 month', category: 'Subscriptions', cost: 90, icon: '🎵' },
  { id: 'spotify-3', name: 'Spotify Premium - 3 months', category: 'Subscriptions', cost: 250, icon: '🎵' },
  { id: 'spotify-12', name: 'Spotify Premium - 12 months', category: 'Subscriptions', cost: 900, icon: '🎵' },
  { id: 'netflix-25', name: 'Netflix Gift Card $25', category: 'Subscriptions', cost: 240, icon: '🎬' },
  { id: 'apple-music-3', name: 'Apple Music - 3 months', category: 'Subscriptions', cost: 250, icon: '🎶' },
  { id: 'yt-premium-1', name: 'YouTube Premium - 1 month', category: 'Subscriptions', cost: 90, icon: '▶️' },
  { id: 'disney-3', name: 'Disney+ - 3 months', category: 'Subscriptions', cost: 260, icon: '✨' },
  { id: 'kindle-3', name: 'Kindle Unlimited - 3 months', category: 'Subscriptions', cost: 300, icon: '📚' },
  { id: 'gym-1', name: 'Gym Membership - 1 month', category: 'Fitness', cost: 500, icon: '🏋️' },
  { id: 'gym-3', name: 'Gym Membership - 3 months', category: 'Fitness', cost: 1400, icon: '🏋️' },
  { id: 'gym-12', name: 'Gym Membership - 12 months', category: 'Fitness', cost: 5000, icon: '🏋️' },
  { id: 'yoga-10', name: 'Yoga Studio Pack - 10 classes', category: 'Fitness', cost: 600, icon: '🧘' },
  { id: 'apple-watch-se', name: 'Apple Watch SE', category: 'Fitness', cost: 6000, icon: '⌚' },
  { id: 'apple-watch-series', name: 'Apple Watch Series 10', category: 'Fitness', cost: 9000, icon: '⌚' },
  { id: 'fitbit-charge', name: 'Fitbit Charge', category: 'Fitness', cost: 3500, icon: '⌚' },
  { id: 'airpods-pro', name: 'AirPods Pro', category: 'Tech', cost: 5500, icon: '🎧' },
  { id: 'gplay-10', name: 'Google Play Gift Card $10', category: 'Gift Cards', cost: 100, icon: '📱' },
  { id: 'gplay-25', name: 'Google Play Gift Card $25', category: 'Gift Cards', cost: 240, icon: '📱' },
  { id: 'nike-25', name: 'Nike Gift Card $25', category: 'Shopping', cost: 240, icon: '👟' },
  { id: 'adidas-25', name: 'Adidas Gift Card $25', category: 'Shopping', cost: 240, icon: '👟' },
  { id: 'starbucks-10', name: 'Starbucks Gift Card $10', category: 'Shopping', cost: 100, icon: '☕' },
  { id: 'ubereats-15', name: 'Uber Eats Gift Card $15', category: 'Shopping', cost: 150, icon: '🍟' }
];

// ====================================================================
//  UTILITIES
// ====================================================================

function fmtInt(v) {
  return (v == null || !isFinite(v)) ? '—' : Math.round(v).toLocaleString('en-US');
}
function fmtNum(v, decimals) {
  return (v == null || !isFinite(v)) ? '—' : Number(v).toFixed(decimals);
}
function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
}
function announce(msg) {
  const region = document.getElementById('aria-live-region');
  if (region) region.textContent = msg;
}
function byId(id) { return document.getElementById(id); }

// ====================================================================
//  NAVIGATION (SPA view switching)
// ====================================================================

function initNav() {
  document.querySelectorAll('.nav-btn').forEach(function (btn) {
    btn.addEventListener('click', function () { switchView(btn.dataset.view); });
  });
}

function switchView(view) {
  document.querySelectorAll('.nav-btn').forEach(function (b) {
    const active = b.dataset.view === view;
    b.classList.toggle('active', active);
    if (active) { b.setAttribute('aria-current', 'page'); } else { b.removeAttribute('aria-current'); }
  });
  document.querySelectorAll('.app-view').forEach(function (section) {
    section.classList.toggle('hidden', section.dataset.viewPanel !== view);
  });
  const panel = document.querySelector('.app-view[data-view-panel="' + view + '"]');
  if (panel) { panel.focus(); }

  if (view === 'home') { renderHome(); }
  if (view === 'targets') { renderTargets(); }
  if (view === 'rewards') { renderRewards(); }
}

function initViewLinkButtons() {
  document.querySelectorAll('[data-view-link]').forEach(function (btn) {
    btn.addEventListener('click', function () { switchView(btn.dataset.viewLink); });
  });
}

// ====================================================================
//  CALCULATOR - form helpers
// ====================================================================

function getFormValues() {
  const sexEl = document.querySelector('input[name="sex"]:checked');
  const goalEl = document.querySelector('input[name="goal"]:checked');
  const rateEl = document.querySelector('input[name="rate"]:checked');
  return {
    age: byId('input-age').value,
    sex: sexEl ? sexEl.value : '',
    height: byId('input-height').value,
    weight: byId('input-weight').value,
    activity: byId('input-activity').value,
    goal: goalEl ? goalEl.value : '',
    rate: rateEl ? rateEl.value : '',
    eligibility: byId('input-eligibility').checked
  };
}

function snapshotKey(values) { return JSON.stringify(values); }

function initGoalRateToggle() {
  const rateGroup = byId('rate-group');
  function update() {
    const goalEl = document.querySelector('input[name="goal"]:checked');
    const goal = goalEl ? goalEl.value : 'maintain';
    rateGroup.classList.toggle('hidden', goal === 'maintain');
  }
  document.querySelectorAll('input[name="goal"]').forEach(function (r) {
    r.addEventListener('change', update);
  });
  update();
}

function initSexEligibilityToggle() {
  const wrap = byId('eligibility-wrap');
  function update() {
    const sexEl = document.querySelector('input[name="sex"]:checked');
    const sex = sexEl ? sexEl.value : 'male';
    const isFemale = sex === 'female';
    wrap.classList.toggle('hidden', !isFemale);
    if (!isFemale) { byId('input-eligibility').checked = false; setFieldError('eligibility', ''); }
  }
  document.querySelectorAll('input[name="sex"]').forEach(function (r) {
    r.addEventListener('change', update);
  });
  update();
}

function initStaleWatcher() {
  const form = byId('calc-form');
  form.addEventListener('input', checkStale);
  form.addEventListener('change', checkStale);
}
function checkStale() {
  if (!state.target) return;
  const raw = getFormValues();
  if (snapshotKey(raw) !== state.lastSnapshot) { showStaleBanner(); } else { hideStaleBanner(); }
}
function showStaleBanner() { byId('stale-banner').classList.remove('hidden'); }
function hideStaleBanner() { byId('stale-banner').classList.add('hidden'); }

function clearFieldErrors() {
  ['age', 'height', 'weight', 'activity', 'goal', 'eligibility'].forEach(function (f) {
    const el = byId(f + '-error');
    if (el) el.textContent = '';
  });
  const banner = byId('form-error-banner');
  banner.classList.add('hidden');
  banner.textContent = '';
}
function setFieldError(field, msg) {
  const el = byId(field + '-error');
  if (el) el.textContent = msg;
}

// ====================================================================
//  CALCULATOR - core math
// ====================================================================

function computeBMI(weightKg, heightCm) {
  const h = heightCm / 100;
  return weightKg / (h * h);
}
function computeRefWeightRange(heightCm) {
  const h = heightCm / 100;
  return { min: 18.5 * h * h, max: 24.9 * h * h };
}
function computeBMR(sex, weightKg, heightCm, age) {
  const base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return sex === 'male' ? base + 5 : base - 161;
}
function bmiStatus(bmi) {
  if (bmi < 18.5) return 'Below reference';
  if (bmi < 25) return 'Healthy range';
  if (bmi < 30) return 'Above reference';
  if (bmi < 35) return 'Obesity — class 1';
  if (bmi < 40) return 'Obesity — class 2';
  return 'Obesity — class 3';
}

const VALID_ACTIVITIES = [1.2, 1.375, 1.55, 1.725, 1.9];

function validateForm(raw) {
  let ok = true;
  const errors = {};

  const age = parseFloat(raw.age);
  if (raw.age === '' || isNaN(age) || age < 20 || age > 100) {
    errors.age = 'Please enter an age between 20 and 100.';
    ok = false;
  }

  const height = parseFloat(raw.height);
  if (raw.height === '' || isNaN(height) || height < 120 || height > 230) {
    errors.height = 'Please enter a valid height between 120 and 230 cm.';
    ok = false;
  }

  const weight = parseFloat(raw.weight);
  if (raw.weight === '' || isNaN(weight) || weight < 35 || weight > 300) {
    errors.weight = 'Please enter a valid weight between 35 and 300 kg.';
    ok = false;
  }

  const activity = parseFloat(raw.activity);
  if (isNaN(activity) || VALID_ACTIVITIES.indexOf(activity) === -1) {
    errors.activity = 'Please select an activity level.';
    ok = false;
  }

  if (!raw.goal) {
    errors.goal = 'Please select a goal.';
    ok = false;
  }

  if (raw.sex === 'female' && !raw.eligibility) {
    errors.eligibility = 'This calculator is designed for adults 20 or older who are not pregnant or ' +
      'breastfeeding. Please confirm the statement above to continue.';
    ok = false;
  }

  return {
    ok: ok, errors: errors, age: age, height: height, weight: weight, activity: activity,
    sex: raw.sex || 'male', goal: raw.goal, rate: parseFloat(raw.rate) || 0.25
  };
}

function handleCalculateSubmit(e) {
  e.preventDefault();
  clearFieldErrors();
  const raw = getFormValues();
  const parsed = validateForm(raw);

  if (!parsed.ok) {
    Object.keys(parsed.errors).forEach(function (f) { setFieldError(f, parsed.errors[f]); });
    const banner = byId('form-error-banner');
    banner.textContent = 'Please correct the highlighted fields above.';
    banner.classList.remove('hidden');
    announce('There are errors in the form. Please review the highlighted fields.');
    return;
  }

  const bmi = computeBMI(parsed.weight, parsed.height);
  const refRange = computeRefWeightRange(parsed.height);
  const bmr = computeBMR(parsed.sex, parsed.weight, parsed.height, parsed.age);
  const tdee = bmr * parsed.activity;

  if (parsed.goal === 'lose' && bmi < 18.5) {
    showCalcError('Weight-loss targets are unavailable below the adult BMI reference range (18.5). If weight ' +
      'loss is still a goal, please speak with a qualified professional for personalized guidance.');
    return;
  }

  let adjustment = 0;
  if (parsed.goal !== 'maintain') {
    adjustment = 7700 * parsed.rate / 7;
  }

  let calories;
  if (parsed.goal === 'lose') { calories = tdee - adjustment; }
  else if (parsed.goal === 'gain') { calories = tdee + adjustment; }
  else { calories = tdee; }

  if (calories <= 0) {
    showCalcError('This rate produces a non-positive calorie estimate. Choose a slower rate or speak with a ' +
      'qualified professional.');
    return;
  }

  calories = Math.round(calories);
  const proteinGrams = Math.round(calories * 0.25 / 4);
  const carbohydrateGrams = Math.round(calories * 0.45 / 4);
  const fatGrams = Math.round(calories * 0.30 / 9);
  const addedSugarLimitGrams = Math.round(calories * 0.10 / 4);
  const saturatedFatLimitGrams = Math.round(calories * 0.10 / 9);

  state.target = {
    age: parsed.age, sex: parsed.sex, heightCm: parsed.height, weightKg: parsed.weight,
    activityFactor: parsed.activity, goal: parsed.goal,
    weeklyRateKg: parsed.goal === 'maintain' ? 0 : parsed.rate,
    bmi: bmi, bmr: Math.round(bmr), tdee: Math.round(tdee), calories: calories,
    proteinGrams: proteinGrams, carbohydrateGrams: carbohydrateGrams, fatGrams: fatGrams,
    addedSugarLimitGrams: addedSugarLimitGrams, saturatedFatLimitGrams: saturatedFatLimitGrams,
    refWeightMin: refRange.min, refWeightMax: refRange.max
  };
  state.lastSnapshot = snapshotKey(raw);
  state.lastFormRaw = raw;

  clearCalcError();
  hideStaleBanner();
  renderResults(state.target);
  renderMealPlanFromState();
  renderTargets();
  persistState();
  announce('Target calculated: ' + calories + ' kcal per day.');
}

function showCalcError(msg) {
  const el = byId('calc-error-notice');
  el.textContent = msg;
  el.classList.remove('hidden');
  announce(msg);
}
function clearCalcError() {
  const el = byId('calc-error-notice');
  el.textContent = '';
  el.classList.add('hidden');
}

// ====================================================================
//  CALCULATOR - rendering results
// ====================================================================

function renderResults(t) {
  byId('empty-results').classList.add('hidden');
  byId('results-content').classList.remove('hidden');
  renderGauge(t.bmi);
  renderRefWeightRange(t);
  renderStatsList(t);
  renderNotices(t);
  renderNutrientCards(t);
}

function renderRefWeightRange(t) {
  byId('ref-weight-range').textContent =
    'Reference weight range for your height: ' + fmtNum(t.refWeightMin, 1) + '–' +
    fmtNum(t.refWeightMax, 1) + ' kg';
}

function renderStatsList(t) {
  const rows = [
    ['BMI', t.bmi.toFixed(1)],
    ['BMI status', bmiStatus(t.bmi)],
    ['Resting energy', fmtInt(t.bmr) + ' kcal'],
    ['Daily expenditure', fmtInt(t.tdee) + ' kcal'],
    ['Target calories', fmtInt(t.calories) + ' kcal'],
    ['Selected goal', GOAL_LABELS[t.goal] || t.goal]
  ];
  if (t.goal !== 'maintain') {
    rows.push(['Selected weekly rate', t.weeklyRateKg + ' kg/week']);
  }
  byId('stats-list').innerHTML = rows.map(function (row) {
    return '<div class="stat-row"><dt>' + escapeHtml(row[0]) + '</dt><dd>' + escapeHtml(String(row[1])) +
      '</dd></div>';
  }).join('');
}

function renderNotices(t) {
  const goalNotice = byId('goal-notice');
  const aggNotice = byId('aggressive-notice');

  if (t.goal !== 'maintain') {
    goalNotice.textContent = 'Actual weight change is not guaranteed. This target is an estimate and may need ' +
      'adjustment over time.';
    goalNotice.classList.remove('hidden');
  } else {
    goalNotice.classList.add('hidden');
  }

  if (t.goal !== 'maintain' && t.weeklyRateKg === 0.75) {
    aggNotice.textContent = 'A 0.75 kg/week target is aggressive and may be unsuitable. Review this estimate with ' +
      'a qualified professional before following it.';
    aggNotice.classList.remove('hidden');
  } else {
    aggNotice.classList.add('hidden');
  }
}

function renderNutrientCards(t) {
  const cards = [
    { name: 'Calories', value: t.calories, unit: 'kcal', kind: 'Target' },
    { name: 'Protein', value: t.proteinGrams, unit: 'g', kind: 'Target' },
    { name: 'Carbohydrates', value: t.carbohydrateGrams, unit: 'g', kind: 'Target' },
    { name: 'Fat', value: t.fatGrams, unit: 'g', kind: 'Target' },
    { name: 'Added sugar', value: t.addedSugarLimitGrams, unit: 'g', kind: 'Upper limit' },
    { name: 'Saturated fat', value: t.saturatedFatLimitGrams, unit: 'g', kind: 'Upper limit' }
  ];
  byId('nutrient-cards-grid').innerHTML = cards.map(function (c) {
    return '<div class="nutrient-card">' +
      '<span class="nutrient-card-name">' + escapeHtml(c.name) + '</span>' +
      '<span class="nutrient-card-value">' + fmtInt(c.value) +
      '<span class="nutrient-card-unit">' + c.unit + '</span></span>' +
      '<span class="nutrient-card-kind nutrient-card-kind-' + (c.kind === 'Target' ? 'target' : 'limit') + '">' +
      c.kind + '</span></div>';
  }).join('');
}

// ====================================================================
//  BMI GAUGE (semicircular SVG)
// ====================================================================

const GAUGE_MIN = 12;
const GAUGE_MAX = 45;
const GAUGE_BANDS = [
  { min: 12, max: 15, colorVar: '--gauge-yellow-4' },
  { min: 15, max: 16, colorVar: '--gauge-yellow-3' },
  { min: 16, max: 17, colorVar: '--gauge-yellow-2' },
  { min: 17, max: 18.5, colorVar: '--gauge-yellow-1' },
  { min: 18.5, max: 25, colorVar: '--gauge-green' },
  { min: 25, max: 30, colorVar: '--gauge-red-1' },
  { min: 30, max: 35, colorVar: '--gauge-red-2' },
  { min: 35, max: 40, colorVar: '--gauge-red-3' },
  { min: 40, max: 45, colorVar: '--gauge-red-4' }
];

function angleForValue(v) {
  const clamped = Math.max(GAUGE_MIN, Math.min(GAUGE_MAX, v));
  const frac = (clamped - GAUGE_MIN) / (GAUGE_MAX - GAUGE_MIN);
  return 180 * (1 - frac);
}
function polarPoint(cx, cy, r, angleDeg) {
  const rad = angleDeg * Math.PI / 180;
  return { x: cx + r * Math.cos(rad), y: cy - r * Math.sin(rad) };
}
function describeArc(cx, cy, r, angleStart, angleEnd) {
  const start = polarPoint(cx, cy, r, angleStart);
  const end = polarPoint(cx, cy, r, angleEnd);
  const largeArc = (angleStart - angleEnd) > 180 ? 1 : 0;
  return 'M ' + start.x.toFixed(2) + ' ' + start.y.toFixed(2) + ' A ' + r + ' ' + r + ' 0 ' + largeArc +
    ' 1 ' + end.x.toFixed(2) + ' ' + end.y.toFixed(2);
}

function renderGauge(bmi) {
  const cx = 150, cy = 152, r = 108, strokeWidth = 26;

  const bandsSvg = GAUGE_BANDS.map(function (b) {
    const d = describeArc(cx, cy, r, angleForValue(b.min), angleForValue(b.max));
    return '<path d="' + d + '" fill="none" style="stroke:var(' + b.colorVar + ')" stroke-width="' + strokeWidth +
      '"></path>';
  }).join('');

  const markerAngle = angleForValue(bmi);
  const markerOuter = polarPoint(cx, cy, r + strokeWidth / 2 + 9, markerAngle);
  const markerInner = polarPoint(cx, cy, r - strokeWidth / 2 - 3, markerAngle);
  const markerDot = polarPoint(cx, cy, r, markerAngle);

  const markerSvg =
    '<line x1="' + markerInner.x.toFixed(2) + '" y1="' + markerInner.y.toFixed(2) + '" x2="' +
    markerOuter.x.toFixed(2) + '" y2="' + markerOuter.y.toFixed(2) +
    '" style="stroke:var(--gauge-marker)" stroke-width="4" stroke-linecap="round"></line>' +
    '<circle cx="' + markerDot.x.toFixed(2) + '" cy="' + markerDot.y.toFixed(2) +
    '" r="7" style="fill:var(--gauge-marker);stroke:var(--bg-card)" stroke-width="2"></circle>';

  byId('gauge-wrap').innerHTML =
    '<svg viewBox="0 0 300 172" class="gauge-svg" role="img" ' +
    'aria-label="BMI gauge showing a value of ' + bmi.toFixed(1) + ', status: ' + bmiStatus(bmi) + '">' +
    bandsSvg + markerSvg + '</svg>';

  byId('gauge-text-alt').textContent = 'BMI ' + bmi.toFixed(1) + ' — ' + bmiStatus(bmi) + '.';
  byId('gauge-bmi-value').textContent = bmi.toFixed(1);
  byId('gauge-bmi-status').textContent = bmiStatus(bmi);
}

// ====================================================================
//  MEAL PLAN
// ====================================================================

const MEAL_TYPE_LABELS = { breakfast: 'Breakfast', lunch: 'Lunch', dinner: 'Dinner', dessert: 'Dessert' };

const MEAL_RECIPES = {
  breakfast: {
    name: 'Berry and almond oat bowl',
    ingredients: [
      { foodId: 170887, label: 'Plain skim yogurt', share: 0.25 },
      { foodId: 173904, label: 'Oats', share: 0.40 },
      { foodId: 171711, label: 'Blueberries', share: 0.15 },
      { foodId: 170567, label: 'Almonds', share: 0.20 }
    ]
  },
  lunch: {
    name: 'Chicken and brown-rice bowl',
    ingredients: [
      { foodId: 171477, label: 'Oven-roasted chicken', share: 0.40 },
      { foodId: 169704, label: 'Cooked brown rice', share: 0.35 },
      { foodId: 169967, label: 'Broccoli', share: 0.10 },
      { foodId: 170567, label: 'Almonds', share: 0.15 }
    ]
  },
  dinner: {
    name: 'Salmon and bulgur plate',
    ingredients: [
      { foodId: 175168, label: 'Cooked salmon', share: 0.45 },
      { foodId: 170287, label: 'Cooked bulgur', share: 0.30 },
      { foodId: 169967, label: 'Broccoli', share: 0.10 },
      { foodId: 170567, label: 'Almonds', share: 0.15 }
    ]
  },
  dessert: {
    name: 'Strawberry chocolate yogurt',
    ingredients: [
      { foodId: 170887, label: 'Plain skim yogurt', share: 0.45 },
      { foodId: 167762, label: 'Strawberries', share: 0.25 },
      { foodId: 170273, label: 'Dark chocolate', share: 0.30 }
    ]
  }
};

const MEAL_PCT_NO_DESSERT = { breakfast: 0.30, lunch: 0.38, dinner: 0.32 };
const MEAL_PCT_WITH_DESSERT = { breakfast: 0.25, lunch: 0.35, dinner: 0.30, dessert: 0.10 };

function sumIngredientNutrients(ingredients) {
  const fields = ['calories', 'protein', 'carbs', 'fat', 'sugar', 'satFat'];
  const totals = {};
  const missing = {};
  fields.forEach(function (f) { totals[f] = 0; missing[f] = false; });

  ingredients.forEach(function (ing) {
    const food = ing.food;
    const grams = ing.grams;
    fields.forEach(function (f) {
      if (!food || grams == null || food[f] == null) { missing[f] = true; return; }
      totals[f] += food[f] * grams / 100;
    });
  });

  fields.forEach(function (f) {
    totals[f] = missing[f] ? null : Math.round(totals[f] * 10) / 10;
  });
  return totals;
}

function buildMeal(type, mealCalories) {
  const recipe = MEAL_RECIPES[type];
  const ingredients = recipe.ingredients.map(function (ing) {
    const food = FOOD_BY_ID[ing.foodId] || null;
    const kcalPer100 = food ? food.calories : null;
    let grams = null;
    if (kcalPer100 != null && kcalPer100 > 0) {
      const targetKcal = mealCalories * ing.share;
      grams = Math.max(1, Math.round(targetKcal * 100 / kcalPer100));
    }
    return { foodId: ing.foodId, name: ing.label, grams: grams, food: food };
  });

  return { type: type, name: recipe.name, ingredients: ingredients, totals: sumIngredientNutrients(ingredients) };
}

function generateMealPlan(dailyCalories, includeDessert) {
  const pct = includeDessert ? MEAL_PCT_WITH_DESSERT : MEAL_PCT_NO_DESSERT;
  const order = includeDessert ? ['breakfast', 'lunch', 'dinner', 'dessert'] : ['breakfast', 'lunch', 'dinner'];
  return order.map(function (type) {
    const mealCalories = dailyCalories * pct[type];
    const meal = buildMeal(type, mealCalories);
    meal.dailyPercentage = pct[type];
    return meal;
  });
}

function renderMealPlanFromState() {
  const emptyEl = byId('mealplan-empty');
  const contentEl = byId('mealplan-content');
  if (!state.target) {
    emptyEl.classList.remove('hidden');
    contentEl.classList.add('hidden');
    return;
  }
  emptyEl.classList.add('hidden');
  contentEl.classList.remove('hidden');

  byId('mealplan-calorie-value').textContent = fmtInt(state.target.calories) + ' kcal';

  const meals = generateMealPlan(state.target.calories, state.dessertEnabled);
  state.currentMeals = meals;

  byId('meal-cards-grid').innerHTML = meals.map(buildMealCardHtml).join('');
  renderDayAtGlance(meals, state.target);
}

function nutValHtml(v, unit) {
  return v == null ? '<span class="unavailable">Not available</span>' : fmtNum(v, 1) + unit;
}

function buildMealCardHtml(meal) {
  const label = MEAL_TYPE_LABELS[meal.type];
  const pct = Math.round(meal.dailyPercentage * 100);
  const ingredientsHtml = meal.ingredients.map(function (ing) {
    return '<li><span class="ing-name">' + escapeHtml(ing.name) + '</span><span class="ing-grams">' +
      (ing.grams != null ? ing.grams + ' g' : 'Not available') + '</span></li>';
  }).join('');

  return '<article class="meal-card">' +
    '<div class="meal-card-top">' +
    '<span class="meal-type-badge">' + label + '</span>' +
    '<span class="meal-pct-badge">' + pct + '% of day</span>' +
    '</div>' +
    '<h3 class="meal-card-name">' + escapeHtml(meal.name) + '</h3>' +
    '<p class="meal-card-cal">' +
    (meal.totals.calories != null ? fmtInt(meal.totals.calories) + ' kcal' : 'Not available') + '</p>' +
    '<ul class="meal-ingredient-list">' + ingredientsHtml + '</ul>' +
    '<div class="meal-nutrient-grid">' +
    '<div><span>Protein</span><b>' + nutValHtml(meal.totals.protein, ' g') + '</b></div>' +
    '<div><span>Carbs</span><b>' + nutValHtml(meal.totals.carbs, ' g') + '</b></div>' +
    '<div><span>Fat</span><b>' + nutValHtml(meal.totals.fat, ' g') + '</b></div>' +
    '<div><span>Total sugar</span><b>' + nutValHtml(meal.totals.sugar, ' g') + '</b></div>' +
    '<div><span>Saturated fat</span><b>' + nutValHtml(meal.totals.satFat, ' g') + '</b></div>' +
    '</div></article>';
}

function renderDayAtGlance(meals, target) {
  const keys = ['calories', 'protein', 'carbs', 'fat', 'sugar', 'satFat'];
  const sums = {}; const missing = {};
  keys.forEach(function (k) { sums[k] = 0; missing[k] = false; });

  meals.forEach(function (m) {
    keys.forEach(function (k) {
      if (m.totals[k] == null) { missing[k] = true; } else { sums[k] += m.totals[k]; }
    });
  });
  keys.forEach(function (k) { sums[k] = missing[k] ? null : Math.round(sums[k] * 10) / 10; });

  const rows = [
    ['Calories', sums.calories, target.calories, 'kcal'],
    ['Protein', sums.protein, target.proteinGrams, 'g'],
    ['Carbohydrates', sums.carbs, target.carbohydrateGrams, 'g'],
    ['Fat', sums.fat, target.fatGrams, 'g'],
    ['Total sugar (from meals)', sums.sugar, null, 'g'],
    ['Saturated fat', sums.satFat, target.saturatedFatLimitGrams, 'g (limit)']
  ];

  byId('day-glance-table').innerHTML =
    '<div class="glance-row glance-head"><span>Nutrient</span><span>Meal total</span><span>Daily target</span></div>' +
    rows.map(function (row) {
      const label = row[0], actual = row[1], target2 = row[2], unit = row[3];
      return '<div class="glance-row">' +
        '<span>' + escapeHtml(label) + '</span>' +
        '<span>' + (actual == null ? 'Not available' : fmtNum(actual, 1) + ' ' + unit.replace(' (limit)', '')) +
        '</span>' +
        '<span>' + (target2 == null ? '—' : fmtInt(target2) + ' ' + unit) + '</span></div>';
    }).join('');
}

function initDessertToggle() {
  byId('dessert-toggle').addEventListener('change', function (e) {
    state.dessertEnabled = e.target.checked;
    renderMealPlanFromState();
  });
}

// ====================================================================
//  SHARE
// ====================================================================

function buildShareText(t) {
  return 'My ' + APP_NAME + ' daily nutrition targets\n\n' +
    'Calories: ' + fmtInt(t.calories) + ' kcal\n' +
    'Protein: ' + fmtInt(t.proteinGrams) + ' g\n' +
    'Carbohydrates: ' + fmtInt(t.carbohydrateGrams) + ' g\n' +
    'Fat: ' + fmtInt(t.fatGrams) + ' g\n' +
    'Added sugar: under ' + fmtInt(t.addedSugarLimitGrams) + ' g\n' +
    'Saturated fat: under ' + fmtInt(t.saturatedFatLimitGrams) + ' g\n\n' +
    'General wellness estimates, not medical advice.\n\n' +
    'Calo menu: https://calo.app/en/menu';
}

async function copyToClipboard(text) {
  try {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch (e) { /* fall through to legacy method */ }
  try {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.focus();
    ta.select();
    const ok = document.execCommand('copy');
    document.body.removeChild(ta);
    return ok;
  } catch (e2) {
    return false;
  }
}

function initShareDialog() {
  const dialog = byId('share-dialog');
  const shareBtn = byId('share-btn');
  const copyBtn = byId('share-copy-btn');
  const nativeBtn = byId('share-native-btn');
  const statusEl = byId('share-status');
  const textarea = byId('share-preview-text');

  shareBtn.addEventListener('click', function () {
    if (!state.target) return;
    const text = buildShareText(state.target);
    textarea.value = text;
    statusEl.textContent = '';
    nativeBtn.classList.toggle('hidden', !navigator.share);
    if (typeof dialog.showModal === 'function') { dialog.showModal(); } else { dialog.setAttribute('open', ''); }
    textarea.focus();
  });

  copyBtn.addEventListener('click', async function () {
    const ok = await copyToClipboard(textarea.value);
    if (ok) {
      statusEl.textContent = 'Copied to clipboard.';
    } else {
      textarea.focus();
      textarea.select();
      statusEl.textContent = 'Automatic copy failed. The text is selected — press Ctrl+C (or Cmd+C) to copy it manually.';
    }
  });

  nativeBtn.addEventListener('click', async function () {
    if (!navigator.share) return;
    try {
      await navigator.share({ text: textarea.value, title: APP_NAME + ' targets' });
      statusEl.textContent = 'Shared.';
    } catch (err) {
      if (err && err.name !== 'AbortError') {
        statusEl.textContent = 'Sharing was not completed. You can still copy the text above.';
      }
    }
  });

  dialog.addEventListener('close', function () { statusEl.textContent = ''; });
}

function initCaloCopy() {
  byId('calo-copy-btn').addEventListener('click', async function () {
    if (!state.target) {
      announce('Calculate your target in the Calculator section first.');
      return;
    }
    const text = buildShareText(state.target);
    const ok = await copyToClipboard(text);
    announce(ok ? 'Targets copied to clipboard.' : 'Could not copy automatically. Please copy manually.');
  });
}

// ====================================================================
//  FOODS
// ====================================================================

function dash(v, unit) { return v == null ? '—' : fmtNum(v, 1) + (unit || ''); }

function buildFoodCardHtml(f) {
  return '<article class="food-card">' +
    '<div class="food-card-head">' +
    '<h3 class="food-card-name">' + escapeHtml(f.name) + '</h3>' +
    (f.category ? '<span class="food-card-cat">' + escapeHtml(f.category) + '</span>' : '') +
    '</div>' +
    '<p class="food-card-basis">Per 100 g</p>' +
    '<div class="food-card-grid">' +
    '<div><span>Calories</span><b>' + dash(f.calories) + '</b></div>' +
    '<div><span>Protein</span><b>' + dash(f.protein, ' g') + '</b></div>' +
    '<div><span>Carbs</span><b>' + dash(f.carbs, ' g') + '</b></div>' +
    '<div><span>Fat</span><b>' + dash(f.fat, ' g') + '</b></div>' +
    '<div><span>Sugar</span><b>' + dash(f.sugar, ' g') + '</b></div>' +
    '<div><span>Sat. fat</span><b>' + dash(f.satFat, ' g') + '</b></div>' +
    '</div></article>';
}

function renderFoodsPage(page) {
  const perPage = state.FOODS_PER_PAGE;
  const total = state.filteredFoods.length;
  const totalPages = Math.max(1, Math.ceil(total / perPage));
  const clamped = Math.min(Math.max(1, page), totalPages);
  state.foodsPage = clamped;

  const start = (clamped - 1) * perPage;
  const pageItems = state.filteredFoods.slice(start, start + perPage);

  const grid = byId('foods-grid');
  grid.innerHTML = pageItems.length
    ? pageItems.map(buildFoodCardHtml).join('')
    : '<p class="foods-empty">No foods match your search. Try a different term or category.</p>';

  byId('foods-result-count').textContent = total + (total === 1 ? ' food found' : ' foods found');

  const pager = byId('foods-pagination');
  pager.innerHTML =
    '<button type="button" class="page-btn" id="foods-prev-btn"' + (clamped <= 1 ? ' disabled' : '') +
    '>Previous</button>' +
    '<span class="page-info">Page ' + clamped + ' of ' + totalPages + '</span>' +
    '<button type="button" class="page-btn" id="foods-next-btn"' + (clamped >= totalPages ? ' disabled' : '') +
    '>Next</button>';

  const prevBtn = byId('foods-prev-btn');
  const nextBtn = byId('foods-next-btn');
  if (prevBtn) prevBtn.addEventListener('click', function () { renderFoodsPage(state.foodsPage - 1); });
  if (nextBtn) nextBtn.addEventListener('click', function () { renderFoodsPage(state.foodsPage + 1); });
}

function initFoods() {
  const categories = Array.from(new Set(state.foods.map(function (f) { return f.category; }).filter(Boolean)))
    .sort();
  const select = byId('food-category-select');
  categories.forEach(function (cat) {
    const opt = document.createElement('option');
    opt.value = cat;
    opt.textContent = cat;
    select.appendChild(opt);
  });

  state.filteredFoods = state.foods;
  renderFoodsPage(1);

  const searchInput = byId('food-search-input');
  let debounceTimer;

  function applyFilter() {
    const q = searchInput.value.trim().toLowerCase();
    const words = q.split(/\s+/).filter(Boolean);
    const cat = select.value;
    state.filteredFoods = state.foods.filter(function (f) {
      if (cat && f.category !== cat) return false;
      if (!words.length) return true;
      const name = f.name.toLowerCase();
      return words.every(function (w) { return name.indexOf(w) !== -1; });
    });
    renderFoodsPage(1);
  }

  searchInput.addEventListener('input', function () {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(applyFilter, 150);
  });
  select.addEventListener('change', applyFilter);
}

// ====================================================================
//  PERSISTENCE (device-local storage; nothing leaves the browser)
// ====================================================================

function persistState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({
      target: state.target,
      lastFormRaw: state.lastFormRaw,
      dessertEnabled: state.dessertEnabled,
      stepsLog: state.stepsLog,
      redemptions: state.redemptions,
      notificationsEnabled: state.notificationsEnabled
    }));
  } catch (e) { /* storage unavailable (private mode, quota, etc.) - fail silently */ }
}

function loadPersistedState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return;
    const data = JSON.parse(raw);
    if (data.target) state.target = data.target;
    if (data.lastFormRaw) state.lastFormRaw = data.lastFormRaw;
    if (typeof data.dessertEnabled === 'boolean') state.dessertEnabled = data.dessertEnabled;
    if (data.stepsLog && typeof data.stepsLog === 'object') state.stepsLog = data.stepsLog;
    if (Array.isArray(data.redemptions)) state.redemptions = data.redemptions;
    if (typeof data.notificationsEnabled === 'boolean') state.notificationsEnabled = data.notificationsEnabled;
  } catch (e) { /* corrupt or unavailable storage - start fresh */ }
}

function applyFormSnapshot(raw) {
  if (!raw) return;
  if (raw.age) byId('input-age').value = raw.age;
  if (raw.height) byId('input-height').value = raw.height;
  if (raw.weight) byId('input-weight').value = raw.weight;
  if (raw.activity) byId('input-activity').value = raw.activity;
  if (raw.sex) {
    const sexEl = document.querySelector('input[name="sex"][value="' + raw.sex + '"]');
    if (sexEl) sexEl.checked = true;
  }
  if (raw.goal) {
    const goalEl = document.querySelector('input[name="goal"][value="' + raw.goal + '"]');
    if (goalEl) goalEl.checked = true;
  }
  if (raw.rate) {
    const rateEl = document.querySelector('input[name="rate"][value="' + raw.rate + '"]');
    if (rateEl) rateEl.checked = true;
  }
  byId('input-eligibility').checked = !!raw.eligibility;
}

function initResetDataButton() {
  byId('reset-data-btn').addEventListener('click', function () {
    const ok = window.confirm('Reset all saved NutriVision data on this device? This clears your saved ' +
      'target, logged steps, Fit Coin history, and redeemed rewards. This cannot be undone.');
    if (!ok) return;
    try { localStorage.removeItem(STORAGE_KEY); } catch (e) { /* ignore */ }
    window.location.reload();
  });
}

// ====================================================================
//  HOME - daily steps & Fit Coins
// ====================================================================

function todayKey() {
  const d = new Date();
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}
function getStepsForDate(dateKey) { return state.stepsLog[dateKey] || 0; }
function coinsForSteps(steps) { return Math.floor(steps / STEPS_PER_COIN); }
function totalEarnedCoins() {
  return Object.keys(state.stepsLog).reduce(function (sum, k) { return sum + coinsForSteps(state.stepsLog[k]); }, 0);
}
function totalSpentCoins() {
  return state.redemptions.reduce(function (sum, r) { return sum + r.cost; }, 0);
}
function coinBalance() { return totalEarnedCoins() - totalSpentCoins(); }

function renderHome() {
  const today = todayKey();
  const steps = getStepsForDate(today);
  const pct = Math.max(0, Math.min(100, Math.round(steps / DAILY_STEP_TARGET * 100)));

  byId('home-steps-value').textContent = steps.toLocaleString();
  byId('home-steps-target').textContent = DAILY_STEP_TARGET.toLocaleString();
  byId('home-steps-progress-bar').style.width = pct + '%';
  const progressbar = byId('home-steps-progressbar');
  progressbar.setAttribute('aria-valuenow', String(steps));

  byId('home-steps-remaining').textContent = steps >= DAILY_STEP_TARGET
    ? 'Daily step target reached — nice work!'
    : fmtInt(DAILY_STEP_TARGET - steps) + ' steps remaining today';

  byId('home-coins-today').textContent = coinsForSteps(steps).toLocaleString();
  byId('home-coins-balance').textContent = coinBalance().toLocaleString();

  const stepsInput = byId('steps-input');
  if (document.activeElement !== stepsInput) { stepsInput.value = steps || ''; }

  const reminderToggle = byId('reminder-toggle');
  reminderToggle.checked = state.notificationsEnabled;

  renderStepsHistory();
}

function renderStepsHistory() {
  const entries = Object.keys(state.stepsLog)
    .filter(function (k) { return k !== todayKey(); })
    .sort()
    .reverse()
    .slice(0, 7);

  const el = byId('steps-history-list');
  if (!entries.length) {
    el.innerHTML = '<p class="history-empty">No previous days logged yet.</p>';
    return;
  }
  el.innerHTML = entries.map(function (dateKey) {
    const steps = state.stepsLog[dateKey];
    return '<div class="history-row"><span>' + escapeHtml(dateKey) + '</span><span>' +
      fmtInt(steps) + ' steps</span><span>' + coinsForSteps(steps) + ' coins</span></div>';
  }).join('');
}

function initStepsLogger() {
  byId('steps-save-btn').addEventListener('click', function () {
    const input = byId('steps-input');
    const val = parseInt(input.value, 10);
    if (isNaN(val) || val < 0 || val > 200000) {
      announce('Please enter a valid number of steps between 0 and 200,000.');
      return;
    }
    state.stepsLog[todayKey()] = val;
    persistState();
    renderHome();
    announce('Steps saved: ' + val.toLocaleString() + '. Fit Coins earned today: ' + coinsForSteps(val) + '.');
  });
}

function sendStepReminder(force) {
  if (!('Notification' in window) || Notification.permission !== 'granted') return;
  const steps = getStepsForDate(todayKey());
  const remaining = Math.max(0, DAILY_STEP_TARGET - steps);
  if (!force && remaining <= 0) return;
  try {
    new Notification(APP_NAME + ' step reminder', {
      body: remaining > 0
        ? 'You have ' + remaining.toLocaleString() + ' steps left to reach today’s ' +
          DAILY_STEP_TARGET.toLocaleString() + '-step target.'
        : 'Great job — you have already reached today’s step target!'
    });
  } catch (e) { /* Notification constructor unsupported in this context */ }
}

let reminderIntervalId = null;
function startReminderInterval() {
  if (reminderIntervalId) clearInterval(reminderIntervalId);
  reminderIntervalId = setInterval(function () {
    if (state.notificationsEnabled) sendStepReminder(false);
  }, 5 * 60 * 1000);
}

function initReminderToggle() {
  const toggle = byId('reminder-toggle');
  toggle.addEventListener('change', async function () {
    if (toggle.checked) {
      if (!('Notification' in window)) {
        announce('Notifications are not supported in this browser.');
        toggle.checked = false;
        return;
      }
      let permission = Notification.permission;
      if (permission === 'default') { permission = await Notification.requestPermission(); }
      if (permission !== 'granted') {
        announce('Notification permission was not granted, so reminders are off.');
        toggle.checked = false;
        state.notificationsEnabled = false;
        persistState();
        return;
      }
    }
    state.notificationsEnabled = toggle.checked;
    persistState();
    announce(state.notificationsEnabled ? 'Step-goal reminders turned on.' : 'Step-goal reminders turned off.');
  });

  byId('reminder-test-btn').addEventListener('click', function () {
    if (!('Notification' in window)) {
      announce('Notifications are not supported in this browser.');
      return;
    }
    if (Notification.permission === 'granted') {
      sendStepReminder(true);
    } else {
      announce('Enable step-goal reminders first to allow notifications.');
    }
  });
}

// ====================================================================
//  TARGETS
// ====================================================================

function renderTargets() {
  const t = state.target;
  const empty = byId('targets-empty');
  const content = byId('targets-content');
  if (!t) {
    empty.classList.remove('hidden');
    content.classList.add('hidden');
    return;
  }
  empty.classList.add('hidden');
  content.classList.remove('hidden');

  byId('targets-steps-value').textContent = DAILY_STEP_TARGET.toLocaleString() + ' steps/day';
  byId('targets-calories-value').textContent = fmtInt(t.calories) + ' kcal/day';

  let weeklyText;
  if (t.goal === 'maintain') {
    weeklyText = 'Maintain your current weight this week';
  } else if (t.goal === 'lose') {
    weeklyText = 'Lose ' + t.weeklyRateKg + ' kg this week (estimate)';
  } else {
    weeklyText = 'Gain ' + t.weeklyRateKg + ' kg this week (estimate)';
  }
  byId('targets-weekly-value').textContent = weeklyText;
}

// ====================================================================
//  REWARDS
// ====================================================================

function buildRewardCardHtml(r, balance) {
  const affordable = balance >= r.cost;
  return '<article class="reward-card' + (affordable ? '' : ' reward-card-locked') + '">' +
    '<span class="reward-icon" aria-hidden="true">' + r.icon + '</span>' +
    '<span class="reward-category">' + escapeHtml(r.category) + '</span>' +
    '<h3 class="reward-name">' + escapeHtml(r.name) + '</h3>' +
    '<span class="reward-cost">' + r.cost.toLocaleString() + ' <span>coins</span></span>' +
    '<button type="button" class="btn btn-outline reward-redeem-btn" data-reward-id="' + r.id + '"' +
    (affordable ? '' : ' disabled') + '>' + (affordable ? 'Redeem' : 'Not enough coins') + '</button>' +
    '</article>';
}

function renderRewards() {
  const balance = coinBalance();
  byId('rewards-balance-value').textContent = balance.toLocaleString();

  const grid = byId('rewards-grid');
  grid.innerHTML = REWARDS_CATALOG.map(function (r) { return buildRewardCardHtml(r, balance); }).join('');
  grid.querySelectorAll('.reward-redeem-btn').forEach(function (btn) {
    btn.addEventListener('click', function () { handleRedeem(btn.dataset.rewardId); });
  });

  renderMyRewards();
}

function handleRedeem(rewardId) {
  const reward = REWARDS_CATALOG.find(function (r) { return r.id === rewardId; });
  if (!reward) return;
  if (coinBalance() < reward.cost) {
    announce('Not enough Fit Coins for ' + reward.name + ' yet.');
    return;
  }
  state.redemptions.push({
    id: rewardId + '-' + Date.now(),
    rewardId: rewardId,
    name: reward.name,
    cost: reward.cost,
    timestamp: new Date().toISOString()
  });
  persistState();
  renderRewards();
  announce('Redeemed: ' + reward.name + ' for ' + reward.cost.toLocaleString() + ' Fit Coins.');
}

function renderMyRewards() {
  const list = byId('my-rewards-list');
  if (!state.redemptions.length) {
    list.innerHTML = '<p class="rewards-empty">You have not redeemed any rewards yet.</p>';
    return;
  }
  const sorted = state.redemptions.slice().sort(function (a, b) { return b.timestamp.localeCompare(a.timestamp); });
  list.innerHTML = sorted.map(function (r) {
    const d = new Date(r.timestamp);
    return '<div class="my-reward-row"><span>' + escapeHtml(r.name) + '</span><span>' +
      r.cost.toLocaleString() + ' coins</span><span>' + d.toLocaleDateString() + '</span></div>';
  }).join('');
}

// ====================================================================
//  BOOT
// ====================================================================

document.addEventListener('DOMContentLoaded', function () {
  loadPersistedState();

  if (state.lastFormRaw) {
    applyFormSnapshot(state.lastFormRaw);
    state.lastSnapshot = snapshotKey(state.lastFormRaw);
  }

  initNav();
  initGoalRateToggle();
  initSexEligibilityToggle();
  initStaleWatcher();
  byId('calc-form').addEventListener('submit', handleCalculateSubmit);
  initShareDialog();
  initCaloCopy();
  initDessertToggle();
  initFoods();
  initStepsLogger();
  initReminderToggle();
  initResetDataButton();
  initViewLinkButtons();

  if (state.target) {
    renderResults(state.target);
  }
  renderMealPlanFromState();

  if (state.notificationsEnabled && ('Notification' in window) && Notification.permission !== 'granted') {
    state.notificationsEnabled = false;
  }
  startReminderInterval();
});
