import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camera/data/image_picker_service.dart';
import '../../recognition/data/gemini_food_recognition_service.dart';
import '../data/fatsecret_api_client.dart';
import '../domain/tracked_meal_item.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => ImagePickerService(),
);

final geminiServiceProvider = Provider<GeminiFoodRecognitionService>(
  (ref) => GeminiFoodRecognitionService(
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
  ),
);

final fatSecretClientProvider = Provider<FatSecretApiClient>(
  (ref) => FatSecretApiClient(
    clientId: const String.fromEnvironment('FATSECRET_CLIENT_ID'),
    clientSecret: const String.fromEnvironment('FATSECRET_CLIENT_SECRET'),
  ),
);

final calorieTrackerControllerProvider =
    StateNotifierProvider<CalorieTrackerController, CalorieTrackerState>(
  (ref) => CalorieTrackerController(
    geminiService: ref.watch(geminiServiceProvider),
    fatSecretClient: ref.watch(fatSecretClientProvider),
  ),
);

class CalorieTrackerState {
  const CalorieTrackerState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  final bool isLoading;
  final String? error;
  final List<TrackedMealItem> items;

  CalorieTrackerState copyWith({
    bool? isLoading,
    String? error,
    List<TrackedMealItem>? items,
  }) {
    return CalorieTrackerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class CalorieTrackerController extends StateNotifier<CalorieTrackerState> {
  CalorieTrackerController({
    required GeminiFoodRecognitionService geminiService,
    required FatSecretApiClient fatSecretClient,
  })  : _geminiService = geminiService,
        _fatSecretClient = fatSecretClient,
        super(const CalorieTrackerState());

  final GeminiFoodRecognitionService _geminiService;
  final FatSecretApiClient _fatSecretClient;

  Future<void> analyzeMealImage(Uint8List imageBytes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final foods = await _geminiService.recognizeFoodsFromImage(imageBytes);
      final items = <TrackedMealItem>[];

      for (final food in foods) {
        final nutrition = await _fatSecretClient.fetchNutritionForFood(food.foodName);
        items.add(TrackedMealItem(food: food, nutrition: nutrition));
      }

      state = state.copyWith(isLoading: false, items: items, error: null);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to analyze meal. Please try again.',
      );
    }
  }
}
