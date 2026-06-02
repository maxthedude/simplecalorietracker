import 'package:flutter_test/flutter_test.dart';
import 'package:simplecalorietracker/features/nutrition/application/calorie_tracker_controller.dart';
import 'package:simplecalorietracker/features/nutrition/domain/nutrition_result.dart';
import 'package:simplecalorietracker/features/nutrition/domain/tracked_meal_item.dart';
import 'package:simplecalorietracker/features/recognition/domain/recognized_food.dart';

void main() {
  group('CalorieTrackerState macro totals', () {
    TrackedMealItem _item({
      required String name,
      required double grams,
      required double calories,
      required double protein,
      required double carbs,
      required double fat,
    }) {
      return TrackedMealItem(
        food: RecognizedFood(foodName: name, estimatedGrams: grams),
        nutrition: NutritionResult(
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
        ),
      );
    }

    test('returns zero totals for empty items', () {
      const state = CalorieTrackerState();

      expect(state.totalCalories, 0.0);
      expect(state.totalProtein, 0.0);
      expect(state.totalCarbs, 0.0);
      expect(state.totalFat, 0.0);
    });

    test('sums macros correctly across multiple items', () {
      final state = CalorieTrackerState(
        items: [
          _item(
            name: 'Chicken',
            grams: 200,
            calories: 330,
            protein: 62,
            carbs: 0,
            fat: 7,
          ),
          _item(
            name: 'Rice',
            grams: 150,
            calories: 195,
            protein: 4,
            carbs: 43,
            fat: 0.5,
          ),
        ],
      );

      expect(state.totalCalories, closeTo(525, 0.001));
      expect(state.totalProtein, closeTo(66, 0.001));
      expect(state.totalCarbs, closeTo(43, 0.001));
      expect(state.totalFat, closeTo(7.5, 0.001));
    });

    test('kDailyKcalGoal is 2300', () {
      expect(kDailyKcalGoal, 2300.0);
    });
  });
}
