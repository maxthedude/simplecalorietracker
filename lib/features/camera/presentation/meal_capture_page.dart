import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nutrition/application/calorie_tracker_controller.dart';
import '../../nutrition/domain/tracked_meal_item.dart';

class MealCapturePage extends ConsumerWidget {
  const MealCapturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calorieTrackerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final image =
                          await ref.read(imagePickerServiceProvider).captureMealImage();

                      if (image == null) {
                        return;
                      }

                      await ref
                          .read(calorieTrackerControllerProvider.notifier)
                          .analyzeMealImage(image);
                    },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Meal'),
            ),
            const SizedBox(height: 12),
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(child: _NutritionList(items: state.items)),
          ],
        ),
      ),
    );
  }
}

class _NutritionList extends StatelessWidget {
  const _NutritionList({required this.items});

  final List<TrackedMealItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Capture a meal photo to get started.'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _NutritionTile(item: item);
      },
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({required this.item});

  final TrackedMealItem item;

  @override
  Widget build(BuildContext context) {
    final nutrition = item.nutrition;

    return ListTile(
      title: Text(item.food.foodName),
      subtitle: Text('${item.food.estimatedGrams.toStringAsFixed(0)} g'),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${nutrition.calories.toStringAsFixed(0)} kcal'),
          Text(
            'P ${nutrition.protein.toStringAsFixed(1)} · C ${nutrition.carbs.toStringAsFixed(1)} · F ${nutrition.fat.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
