import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

/// Shop-flow UI translations (home/shop, plans, basket, checkout, orders).
/// Recipe content (descriptions, ingredients, cooking steps) stays in its
/// original language for now; only the surrounding chrome is translated.
const Map<String, Map<AppLanguage, String>> _strings = {
  'app.title': {AppLanguage.en: 'NutriVision', AppLanguage.ar: 'NutriVision'},

  'nav.meals': {AppLanguage.en: 'Meals', AppLanguage.ar: 'الوجبات'},
  'nav.plans': {AppLanguage.en: 'Plans', AppLanguage.ar: 'الباقات'},
  'nav.favorites': {AppLanguage.en: 'Favorites', AppLanguage.ar: 'المفضلة'},
  'nav.basket': {AppLanguage.en: 'Basket', AppLanguage.ar: 'السلة'},
  'nav.orders': {AppLanguage.en: 'My Orders', AppLanguage.ar: 'طلباتي'},

  'appbar.nutritionTools': {AppLanguage.en: 'Nutrition tools', AppLanguage.ar: 'أدوات التغذية'},
  'appbar.switchToLight': {AppLanguage.en: 'Switch to light mode', AppLanguage.ar: 'التبديل إلى الوضع الفاتح'},
  'appbar.switchToDark': {AppLanguage.en: 'Switch to dark mode', AppLanguage.ar: 'التبديل إلى الوضع الداكن'},
  'appbar.basket': {AppLanguage.en: 'Basket', AppLanguage.ar: 'السلة'},
  'appbar.switchToArabic': {AppLanguage.en: 'Switch to Arabic', AppLanguage.ar: 'التبديل إلى العربية'},
  'appbar.switchToEnglish': {AppLanguage.en: 'Switch to English', AppLanguage.ar: 'التبديل إلى الإنجليزية'},

  'shop.errorSave': {
    AppLanguage.en: 'Could not save changes on this device. Try again.',
    AppLanguage.ar: 'تعذّر حفظ التغييرات على هذا الجهاز. حاول مرة أخرى.',
  },
  'shop.tagline': {
    AppLanguage.en: 'Ingredients ready. Cooked by your hand.',
    AppLanguage.ar: 'مقادير جاهزة. طبخة من يدك.',
  },
  'shop.headline': {
    AppLanguage.en: 'Healthy cooking,\neasier than you think.',
    AppLanguage.ar: 'طبخ صحي،\nأسهل مما تتخيّل.',
  },
  'shop.body': {
    AppLanguage.en:
        "Don't know how to cook? Busy day? We deliver weighed ingredients, a clear recipe, and a starter kit. Pick your meal and leave the rest to us.",
    AppLanguage.ar:
        'ما تعرف تطبخ؟ أو يومك مزدحم؟ نوصل لك المقادير الموزونة، وصفة واضحة، وعدّة البداية. اختَر وجبتك وخلّ الباقي علينا.',
  },
  'shop.chip.oneServing': {AppLanguage.en: '1 serving per box', AppLanguage.ar: 'حصة واحدة في كل بوكس'},
  'shop.chip.kit': {AppLanguage.en: 'Ingredients + recipe + tools', AppLanguage.ar: 'مقادير + وصفة + أدوات'},
  'shop.choosePlan': {AppLanguage.en: 'Choose your plan', AppLanguage.ar: 'اختَر باقتك'},
  'shop.promise.weighed': {AppLanguage.en: 'Weighed ingredients, no guesswork', AppLanguage.ar: 'مقادير موزونة بدون حيرة'},
  'shop.promise.nutrition': {AppLanguage.en: 'Calories & protein per serving', AppLanguage.ar: 'سعرات وبروتين لكل حصة'},
  'shop.promise.learn': {AppLanguage.en: 'Learn to cook step by step', AppLanguage.ar: 'نتعلّم الطبخ خطوة بخطوة'},
  'shop.title.favorites': {AppLanguage.en: 'Your favorite meals', AppLanguage.ar: 'وجباتك المفضلة'},
  'shop.title.today': {AppLanguage.en: 'What are we cooking today?', AppLanguage.ar: 'وش نطبخ اليوم؟'},
  'shop.subtitle': {
    AppLanguage.en: 'Flavors we love, options for your day • Sample prices in Bahraini dinar',
    AppLanguage.ar: 'نكهات نحبها، وخيارات تناسب يومك • أسعار تجريبية بالدينار البحريني',
  },

  'audience.all': {AppLanguage.en: 'All', AppLanguage.ar: 'الكل'},
  'audience.beginner': {AppLanguage.en: 'First time cooking', AppLanguage.ar: 'أول مرة أطبخ'},
  'audience.athletes': {AppLanguage.en: 'For athletes', AppLanguage.ar: 'للرياضيين'},
  'audience.family': {AppLanguage.en: 'Family table', AppLanguage.ar: 'سفرة العائلة'},
  'audience.balanced': {AppLanguage.en: 'Balanced meal', AppLanguage.ar: 'وجبة متوازنة'},
  'audience.desc.beginner': {
    AppLanguage.en: 'Recipes up to 30 minutes. Open the recipe and start step-by-step cooking mode.',
    AppLanguage.ar: 'وصفات حتى ٣٠ دقيقة. افتح الوصفة وابدأ وضع الطبخ خطوة بخطوة.',
  },
  'audience.desc.athletes': {
    AppLanguage.en: '35g protein or more per serving; choose what suits your needs.',
    AppLanguage.ar: '٣٥ غ بروتين أو أكثر للحصة؛ اختَر ما يناسب احتياجك.',
  },
  'audience.desc.family': {
    AppLanguage.en: 'Each box serves one person; increase the quantity in the basket based on your household size.',
    AppLanguage.ar: 'كل بوكس يكفي شخصًا واحدًا؛ زِد الكمية في السلة حسب عدد أفراد البيت.',
  },
  'audience.desc.balanced': {
    AppLanguage.en: '20g protein or more, up to 700 calories per serving. Values are estimates, not personal advice.',
    AppLanguage.ar: '٢٠ غ بروتين أو أكثر وحتى ٧٠٠ سعرة للحصة. القيم تقديرية وليست توصية شخصية.',
  },

  'shop.searchHint': {AppLanguage.en: 'Search for a meal or flavor you like…', AppLanguage.ar: 'ابحث عن وجبة أو نكهة تحبها…'},
  'category.all': {AppLanguage.en: 'All boxes', AppLanguage.ar: 'كل الوجبات'},
  'category.breakfast': {AppLanguage.en: 'Breakfast', AppLanguage.ar: 'فطور'},
  'category.chicken': {AppLanguage.en: 'Chicken', AppLanguage.ar: 'دجاج'},
  'category.meat': {AppLanguage.en: 'Meat', AppLanguage.ar: 'لحوم'},
  'category.plant': {AppLanguage.en: 'Plant-based', AppLanguage.ar: 'نباتي'},
  'shop.empty': {
    AppLanguage.en: "We couldn't find meals here. Try another search or add a meal to favorites.",
    AppLanguage.ar: 'ما لقينا وجبات هنا. جرّب بحثًا آخر أو أضف وجبة للمفضلة.',
  },
  'shop.disclaimer': {
    AppLanguage.en:
        'Nutrition values are illustrative estimates per serving. Photos are AI-generated serving suggestions. Final recipes, allergens and prices need supplier verification.',
    AppLanguage.ar:
        'القيم الغذائية تقديرات توضيحية لكل حصة. الصور مقترحات تقديم من الذكاء الاصطناعي. الوصفات والحساسية والأسعار النهائية تحتاج تحقق من المورد.',
  },
  'box.perBox': {AppLanguage.en: 'per box • 1 serving', AppLanguage.ar: 'للبوكس • حصة واحدة'},
  'box.viewRecipe': {AppLanguage.en: 'View recipe', AppLanguage.ar: 'شوف الوصفة'},

  'detail.perServingValues': {AppLanguage.en: 'Estimated values per serving', AppLanguage.ar: 'القيم التقديرية للحصة الواحدة'},
  'detail.ingredients': {AppLanguage.en: 'Box ingredients', AppLanguage.ar: 'مقادير البوكس'},
  'detail.startCooking': {AppLanguage.en: 'Start step-by-step cooking', AppLanguage.ar: 'ابدأ الطبخ خطوة بخطوة'},
  'detail.fromBoxToTable': {AppLanguage.en: 'From the box to the table', AppLanguage.ar: 'من البوكس إلى السفرة'},
  'detail.sampleGuidance': {
    AppLanguage.en: 'Sample recipe guidance and nutrition; verify final quantities and cooking instructions before commercial use.',
    AppLanguage.ar: 'إرشادات وصفة وقيم غذائية توضيحية؛ تحقق من الكميات النهائية وتعليمات الطبخ قبل الاستخدام التجاري.',
  },
  'detail.addToBasket': {AppLanguage.en: 'Add to basket', AppLanguage.ar: 'أضف للسلة'},

  'basket.title': {AppLanguage.en: 'Your basket, your way', AppLanguage.ar: 'سلتك، على ذوقك'},
  'basket.subtitle': {
    AppLanguage.en: 'Each box includes the ingredients and recipe for one person.',
    AppLanguage.ar: 'كل بوكس يشمل المقادير والوصفة لشخص واحد.',
  },
  'basket.empty': {
    AppLanguage.en: "Your basket is empty. Pick a meal you like and we'll prepare the ingredients.",
    AppLanguage.ar: 'سلتك فاضية. اختَر وجبة تعجبك ونجهّز مقاديرها.',
  },
  'basket.browse': {AppLanguage.en: 'Browse meals', AppLanguage.ar: 'تصفّح الوجبات'},
  'basket.includeKit': {AppLanguage.en: 'Add the starter kit for free', AppLanguage.ar: 'أضف طقم البداية مجانًا'},
  'basket.convertSingle': {AppLanguage.en: 'Convert to a single purchase', AppLanguage.ar: 'تحويل إلى شراء منفرد'},
  'basket.lineMeals': {AppLanguage.en: 'Meals', AppLanguage.ar: 'الوجبات'},
  'basket.planIncomplete': {
    AppLanguage.en: 'This plan requires {n} boxes. Adjust the quantity or convert the basket to a single purchase.',
    AppLanguage.ar: 'هذه الباقة تتطلب {n} بوكس. عدّل الكمية أو حوّل السلة إلى شراء منفرد.',
  },
  'basket.removeOne': {AppLanguage.en: 'Remove one', AppLanguage.ar: 'إزالة واحدة من'},
  'basket.addOne': {AppLanguage.en: 'Add one', AppLanguage.ar: 'إضافة واحدة من'},
  'basket.summary': {
    AppLanguage.en: '{count} box • {count} serving • {deliveries} delivery',
    AppLanguage.ar: '{count} بوكس • {count} حصة • {deliveries} توصيل',
  },
  'basket.lineDiscount': {AppLanguage.en: 'Plan discount', AppLanguage.ar: 'خصم الباقة'},
  'basket.lineDelivery': {AppLanguage.en: 'Delivery', AppLanguage.ar: 'التوصيل'},
  'basket.lineTotal': {AppLanguage.en: 'Total', AppLanguage.ar: 'الإجمالي'},
  'basket.deliveryNote': {
    AppLanguage.en: 'Sample delivery: 1 dinar per delivery, free for a plan once its total reaches 20 dinars before discount.',
    AppLanguage.ar: 'توصيل تجريبي: دينار لكل توصيل، مجانًا للباقة إذا بلغ مجموع وجباتها ٢٠ دينارًا قبل الخصم.',
  },
  'basket.checkoutCta': {AppLanguage.en: 'Continue sample order', AppLanguage.ar: 'متابعة الطلب التجريبي'},

  'checkout.title': {AppLanguage.en: 'Review your sample order', AppLanguage.ar: 'مراجعة الطلب التجريبي'},
  'checkout.headline': {AppLanguage.en: 'One step from your first experience', AppLanguage.ar: 'باقي خطوة على تجربتك الأولى'},
  'checkout.planLabel': {AppLanguage.en: 'Plan', AppLanguage.ar: 'الباقة'},
  'checkout.deliveryLine': {
    AppLanguage.en: '{count} box • {deliveries} delivery',
    AppLanguage.ar: '{count} بوكس • {deliveries} توصيل',
  },
  'checkout.total': {AppLanguage.en: 'Total', AppLanguage.ar: 'الإجمالي'},
  'checkout.disclaimer': {
    AppLanguage.en:
        "This is a sample order saved only on your device. No payment is taken, no order is sent, and no delivery is booked. Use a placeholder area; we don't need your personal data.",
    AppLanguage.ar:
        'هذا طلب تجريبي محفوظ على جهازك فقط. لا يتم الدفع أو إرسال الطلب أو حجز التوصيل. استخدم منطقة افتراضية؛ لا نحتاج بياناتك الشخصية.',
  },
  'checkout.areaLabel': {AppLanguage.en: 'Delivery area (sample)', AppLanguage.ar: 'منطقة التوصيل (تجريبية)'},
  'checkout.areaHint': {AppLanguage.en: 'e.g. Manama', AppLanguage.ar: 'مثال: المنامة'},
  'checkout.areaValidator': {AppLanguage.en: 'Enter a delivery area', AppLanguage.ar: 'أدخل منطقة التوصيل'},
  'checkout.slotLabel': {AppLanguage.en: 'First delivery time (sample)', AppLanguage.ar: 'موعد أول توصيل (تجريبي)'},
  'checkout.slot1': {AppLanguage.en: 'Tomorrow · 4–7 PM', AppLanguage.ar: 'غدًا · ٤–٧ مساءً'},
  'checkout.slot2': {AppLanguage.en: 'Tomorrow · 7–10 PM', AppLanguage.ar: 'غدًا · ٧–١٠ مساءً'},
  'checkout.slot3': {AppLanguage.en: 'In two days · 4–7 PM', AppLanguage.ar: 'بعد يومين · ٤–٧ مساءً'},
  'checkout.subscriptionNote': {
    AppLanguage.en:
        'Sample plan for a fixed period, no auto-renewal. The selected time is for the first delivery only; later scheduling needs a real delivery service.',
    AppLanguage.ar:
        'باقة تجريبية لمدة محددة، بدون تجديد تلقائي. الموعد المختار لأول توصيل؛ الجدولة اللاحقة تحتاج خدمة توصيل فعلية.',
  },
  'checkout.kitIncluded': {AppLanguage.en: 'Starter kit included with first delivery', AppLanguage.ar: 'طقم البداية مشمول في أول توصيل'},
  'checkout.kitNotIncluded': {AppLanguage.en: 'Without tool kit', AppLanguage.ar: 'بدون طقم أدوات'},
  'checkout.saving': {AppLanguage.en: 'Saving…', AppLanguage.ar: 'جارٍ الحفظ…'},
  'checkout.save': {AppLanguage.en: 'Save sample order', AppLanguage.ar: 'حفظ الطلب التجريبي'},
  'checkout.savedTitle': {AppLanguage.en: 'Sample order saved', AppLanguage.ar: 'تم حفظ الطلب التجريبي'},
  'checkout.savedBody': {
    AppLanguage.en: "You'll find the order under 'My Orders' on this device. No delivery was booked and no amount was charged.",
    AppLanguage.ar: 'ستجد الطلب في «طلباتي» على هذا الجهاز. لم يتم حجز توصيل أو تحصيل أي مبلغ.',
  },
  'checkout.done': {AppLanguage.en: 'Done', AppLanguage.ar: 'تم'},
  'checkout.errorSave': {
    AppLanguage.en: 'Could not save the order. Basket contents are intact; try again.',
    AppLanguage.ar: 'تعذّر حفظ الطلب. محتويات السلة موجودة؛ حاول مرة أخرى.',
  },

  'orders.title': {AppLanguage.en: 'Your orders', AppLanguage.ar: 'طلباتك'},
  'orders.subtitle': {
    AppLanguage.en: "Sample orders saved on this device; there's no real delivery tracking.",
    AppLanguage.ar: 'طلبات تجريبية محفوظة على هذا الجهاز؛ لا يوجد تتبّع توصيل فعلي.',
  },
  'orders.empty': {
    AppLanguage.en: 'Your first cooked meal starts here. Browse meals or choose your plan.',
    AppLanguage.ar: 'أول طبخة تبدأ من هنا. تصفّح الوجبات أو اختَر باقتك.',
  },
  'orders.sampleChip': {AppLanguage.en: 'Sample • saved on device', AppLanguage.ar: 'تجريبي • محفوظ على الجهاز'},
  'orders.singleMeals': {AppLanguage.en: 'Single meals', AppLanguage.ar: 'وجبات منفردة'},
  'orders.kitIncluded': {AppLanguage.en: 'Includes starter kit', AppLanguage.ar: 'يشمل طقم البداية'},

  'plans.headline': {AppLanguage.en: 'For your day, your way.', AppLanguage.ar: 'على قد يومك، وعلى ذوقك.'},
  'plans.subtitle': {
    AppLanguage.en: 'Start with a meal or plan your week. Each box has ingredients for one person, and you choose the recipes.',
    AppLanguage.ar: 'ابدأ بوجبة أو رتّب أسبوعك. كل بوكس يحتوي مقادير تكفي شخصًا واحدًا، والوصفات تختارها أنت.',
  },
  'plans.noCommitment': {AppLanguage.en: 'No commitment', AppLanguage.ar: 'بدون التزام'},
  'plans.sampleDiscount': {
    AppLanguage.en: 'Sample discount {pct}%',
    AppLanguage.ar: 'خصم تجريبي {pct}٪',
  },
  'plans.discountPct': {
    AppLanguage.en: 'Plan discount {pct}%',
    AppLanguage.ar: 'خصم الباقة {pct}٪',
  },
  'plans.deliveryCount': {
    AppLanguage.en: 'Delivery ({n})',
    AppLanguage.ar: 'التوصيل ({n})',
  },
  'plans.chooseRecipesFor': {
    AppLanguage.en: 'Choose recipes for {plan}',
    AppLanguage.ar: 'اختَر وصفات {plan}',
  },
  'plans.mealLabel': {
    AppLanguage.en: 'Meal {n}',
    AppLanguage.ar: 'الوجبة {n}',
  },
  'plans.summary': {
    AppLanguage.en: '{boxes} box • {boxes} serving • one delivery',
    AppLanguage.ar: '{boxes} بوكس • {boxes} حصة • توصيل واحد',
  },
  'plans.monthlySummary': {
    AppLanguage.en: '5 boxes every week for 4 weeks. Your choices repeat weekly, totaling 20 boxes and 4 deliveries.',
    AppLanguage.ar: '٥ بوكسات كل أسبوع لمدة ٤ أسابيع. تتكرر اختياراتك أسبوعيًا، بإجمالي ٢٠ بوكس و٤ توصيلات.',
  },
  'plans.subscriptionNote': {
    AppLanguage.en: 'Weekly and monthly plans cover one meal per day, 5 days a week. No auto-renewal or discount in the demo version.',
    AppLanguage.ar: 'الباقة الأسبوعية والشهرية تغطي وجبة واحدة يوميًا، ٥ أيام بالأسبوع. لا يوجد تجديد أو خصم تلقائي في النسخة التجريبية.',
  },
  'plans.breakfast': {AppLanguage.en: 'Breakfast', AppLanguage.ar: 'الفطور'},
  'plans.lunch': {AppLanguage.en: 'Lunch', AppLanguage.ar: 'الغداء'},
  'plans.dinner': {AppLanguage.en: 'Dinner', AppLanguage.ar: 'العشاء'},
  'plans.replaceTitle': {AppLanguage.en: 'Replace basket contents?', AppLanguage.ar: 'استبدال محتويات السلة؟'},
  'plans.replaceBody': {
    AppLanguage.en: "The new plan's recipes will replace the meals currently in your basket.",
    AppLanguage.ar: 'ستحل وصفات الباقة الجديدة محل الوجبات الموجودة في سلتك.',
  },
  'plans.back': {AppLanguage.en: 'Back', AppLanguage.ar: 'رجوع'},
  'plans.replace': {AppLanguage.en: 'Replace', AppLanguage.ar: 'استبدال'},
  'plans.lineIngredients': {AppLanguage.en: 'Ingredients & recipes', AppLanguage.ar: 'المقادير والوصفات'},
  'plans.lineTotal': {AppLanguage.en: 'Plan total', AppLanguage.ar: 'إجمالي الباقة'},
  'plans.pricesNote': {
    AppLanguage.en: 'Sample prices. Starter kit included at no extra cost when selected. No charges are made.',
    AppLanguage.ar: 'أسعار تجريبية. طقم البداية مشمول بلا تكلفة إضافية عند اختياره. لا يتم تحصيل مبالغ.',
  },
  'plans.saving': {AppLanguage.en: 'Saving…', AppLanguage.ar: 'جارٍ الحفظ…'},
  'plans.reviewInBasket': {AppLanguage.en: 'Review plan in basket', AppLanguage.ar: 'راجع الباقة في السلة'},
  'plans.kit.title': {AppLanguage.en: "First time cooking? We've got your gear.", AppLanguage.ar: 'أول مرة تطبخ؟ عدّتك علينا.'},
  'plans.kit.note': {
    AppLanguage.en: "Ingredients are weighed for each recipe. You'll need basic kitchen tools at home as mentioned in the recipe.",
    AppLanguage.ar: 'المقادير موزونة لكل وصفة. تحتاج في البيت أدوات الطبخ الأساسية المذكورة في الوصفة.',
  },
  'kit.description': {
    AppLanguage.en:
        'Starter kit includes measuring spoons, a scoop, a food thermometer and a food scale. Sent once with the first delivery of your plan.',
    AppLanguage.ar: 'طقم البداية يشمل ملاعق قياس، سكوب، ميزان حرارة للطعام وميزان طعام. يُرسل مرة واحدة مع أول توصيل في الباقة.',
  },
  'kit.item.spoons': {AppLanguage.en: 'Measuring spoons', AppLanguage.ar: 'ملاعق قياس'},
  'kit.item.scoop': {AppLanguage.en: 'Ingredient scoop', AppLanguage.ar: 'سكوب للمقادير'},
  'kit.item.thermometer': {AppLanguage.en: 'Food thermometer', AppLanguage.ar: 'ميزان حرارة للطعام'},
  'kit.item.scale': {AppLanguage.en: 'Food scale', AppLanguage.ar: 'ميزان طعام'},
};

extension Tr on BuildContext {
  /// Looks up [key] for the current language. Uses `read`, not `watch`: it's
  /// called from callbacks (validators, dialog builders, tap handlers) as
  /// often as from build methods, and `watch` throws outside of build.
  /// Screens that show a language toggle already `watch<AppState>()`
  /// themselves, which is what makes their build (and this lookup) re-run
  /// when the language changes.
  String tr(String key) {
    final lang = read<AppState>().language;
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[lang] ?? entry[AppLanguage.en] ?? key;
  }
}
