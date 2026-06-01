class RecognizedFood {
  const RecognizedFood({required this.foodName, required this.estimatedGrams});

  final String foodName;
  final double estimatedGrams;

  factory RecognizedFood.fromJson(Map<String, dynamic> json) {
    return RecognizedFood(
      foodName: (json['food_name'] as String? ?? '').trim(),
      estimatedGrams: (json['estimated_grams'] as num?)?.toDouble() ?? 0,
    );
  }
}
