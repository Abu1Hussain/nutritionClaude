class RecipeBox {
  final String id, name, arabicName, region, category, description;
  final int photo, minutes, priceFils, protein, carbs, fat;
  final List<String> ingredients, steps, allergens;
  const RecipeBox({required this.id, required this.name, required this.arabicName,
    required this.region, required this.category, required this.description,
    required this.photo, required this.minutes, required this.priceFils,
    required this.protein, required this.carbs, required this.fat,
    required this.ingredients, required this.steps, this.allergens = const []});
  int get calories => protein * 4 + carbs * 4 + fat * 9;
  static const servings = 2;
}

const recipeBoxes = <RecipeBox>[
  RecipeBox(id: 'machboos', name: 'Chicken Machboos', arabicName: 'مجبوس دجاج', region: 'Bahrain', category: 'Chicken', photo: 0, minutes: 45, priceFils: 6900, protein: 42, carbs: 76, fat: 18,
    description: 'A taste of home. Fragrant basmati rice, tender chicken and a warming blend of Gulf spices.',
    ingredients: ['Chicken · 400 g', 'Basmati rice · 180 g dry', 'Tomato & onion · 300 g', 'Machboos spice blend & dried lime', 'Measured oil · 20 ml'],
    steps: ['Rinse the rice. Chop the vegetables.', 'Sauté onion with the supplied oil, then add chicken, tomato, spices and dried lime.', 'Add water and simmer until the chicken is cooked through.', 'Add rice and cook covered until tender. Check chicken reaches 74°C in the thickest part. Divide into two servings.']),
  RecipeBox(id: 'maqluba', name: 'Chicken Maqluba', arabicName: 'مقلوبة', region: 'Palestine', category: 'Chicken', photo: 1, minutes: 55, priceFils: 7200, protein: 39, carbs: 81, fat: 20,
    description: 'The upside-down classic: layers of spiced rice, chicken and golden aubergine, made for sharing.',
    ingredients: ['Chicken · 360 g', 'Basmati rice · 180 g dry', 'Aubergine & cauliflower · 350 g', 'Maqluba spice blend', 'Measured oil · 25 ml'],
    steps: ['Roast the sliced vegetables with the supplied oil.', 'Sear chicken with spices and simmer in water.', 'Layer vegetables, chicken and rinsed rice in a pot. Add cooking liquid and cover.', 'Cook until rice is tender and chicken reaches 74°C. Rest, then carefully invert onto a plate.']),
  RecipeBox(id: 'mansaf', name: 'Lamb Mansaf', arabicName: 'منسف', region: 'Jordan', category: 'Meat', photo: 2, minutes: 70, priceFils: 8900, protein: 43, carbs: 72, fat: 28,
    description: 'A generous Jordanian favourite with tender lamb, creamy jameed sauce and fragrant rice.',
    ingredients: ['Lamb · 400 g', 'Rice · 170 g dry', 'Jameed yogurt sauce · 200 g', 'Flatbread · 60 g', 'Almond garnish · 15 g'], allergens: ['Milk', 'Wheat', 'Almonds'],
    steps: ['Simmer lamb with water and the supplied spices until tender.', 'Cook the rinsed rice separately.', 'Warm the yogurt sauce gently, stirring, then combine with the cooked lamb.', 'Layer bread, rice and lamb. Spoon over sauce and finish with almonds.']),
  RecipeBox(id: 'shawarma', name: 'Chicken Shawarma', arabicName: 'شاورما دجاج', region: 'Levant', category: 'Chicken', photo: 3, minutes: 30, priceFils: 6400, protein: 45, carbs: 54, fat: 19,
    description: 'Spiced chicken, crisp salad and garlic sauce. All the ingredients for your favourite wrap.',
    ingredients: ['Chicken strips · 400 g', 'Pita bread · 2 pieces', 'Tomato, cucumber & lettuce · 300 g', 'Garlic sauce · 40 g', 'Shawarma marinade'], allergens: ['Wheat', 'Milk'],
    steps: ['Coat chicken with the supplied marinade.', 'Pan-cook the chicken until browned and the thickest pieces reach 74°C.', 'Chop the salad and warm the pita.', 'Fill the pita with chicken, salad and garlic sauce.']),
  RecipeBox(id: 'mujaddara', name: 'Mujaddara', arabicName: 'مجدرة', region: 'Levant', category: 'Plant-based', photo: 4, minutes: 40, priceFils: 4900, protein: 19, carbs: 84, fat: 14,
    description: 'Simple ingredients, deep flavour. Lentils and rice topped with sweet caramelised onions.',
    ingredients: ['Brown lentils · 150 g dry', 'Rice · 120 g dry', 'Onions · 300 g', 'Cumin & spice blend', 'Olive oil · 25 ml'],
    steps: ['Rinse lentils and simmer until almost tender.', 'Thinly slice onions and slowly caramelise with the supplied oil.', 'Add rinsed rice and spices to the lentils, adding water as needed.', 'Cook covered until tender. Serve with the caramelised onions.']),
  RecipeBox(id: 'falafel', name: 'Falafel & Hummus', arabicName: 'فلافل وحمص', region: 'Levant', category: 'Plant-based', photo: 5, minutes: 30, priceFils: 5200, protein: 22, carbs: 66, fat: 21,
    description: 'Herby baked falafel, silky hummus and a bright chopped salad for a colourful table.',
    ingredients: ['Prepared falafel mix · 300 g', 'Hummus · 160 g', 'Pita bread · 2 pieces', 'Tomato & cucumber · 300 g', 'Tahini dressing · 30 g'], allergens: ['Sesame', 'Wheat'],
    steps: ['Heat the oven to 200°C. Shape the prepared mix into small falafel.', 'Bake on an oiled tray for 20–25 minutes, turning halfway, until cooked through.', 'Chop the vegetables and warm the pita.', 'Serve falafel with hummus, salad and tahini dressing.']),
];

String money(int fils) => 'BD ${(fils / 1000).toStringAsFixed(3)}';
