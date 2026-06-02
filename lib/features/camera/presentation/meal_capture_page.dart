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
            if (state.items.isNotEmpty) ...[
              _MacroSummaryCard(state: state),
              const SizedBox(height: 8),
            ],
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

class _MacroSummaryCard extends StatelessWidget {
  const _MacroSummaryCard({required this.state});

  final CalorieTrackerState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalCal = state.totalCalories;
    final progress = (totalCal / kDailyKcalGoal).clamp(0.0, 1.0);
    final remaining = kDailyKcalGoal - totalCal;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Goal', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${totalCal.toStringAsFixed(0)} kcal',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/ ${kDailyKcalGoal.toStringAsFixed(0)} kcal',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              remaining >= 0
                  ? '${remaining.toStringAsFixed(0)} kcal remaining'
                  : '${(-remaining).toStringAsFixed(0)} kcal over goal',
              style: textTheme.bodySmall?.copyWith(
                color: remaining >= 0 ? colorScheme.onSurface : colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroChip(
                  label: 'Protein',
                  value: state.totalProtein,
                  unit: 'g',
                ),
                _MacroChip(
                  label: 'Carbs',
                  value: state.totalCarbs,
                  unit: 'g',
                ),
                _MacroChip(
                  label: 'Fat',
                  value: state.totalFat,
                  unit: 'g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.label, required this.value, required this.unit});

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}
