class NutritionResult {
  const NutritionResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionResult.empty()
      : calories = 0,
        protein = 0,
        carbs = 0,
        fat = 0;
}
