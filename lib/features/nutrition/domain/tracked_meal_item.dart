import '../../recognition/domain/recognized_food.dart';
import 'nutrition_result.dart';

class TrackedMealItem {
  const TrackedMealItem({required this.food, required this.nutrition});

  final RecognizedFood food;
  final NutritionResult nutrition;
}
