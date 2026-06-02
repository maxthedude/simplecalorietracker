import 'package:flutter_test/flutter_test.dart';
import 'package:simplecalorietracker/features/recognition/data/gemini_food_recognition_service.dart';

void main() {
  group('GeminiFoodRecognitionService.parseFoodsResponse', () {
    final service = GeminiFoodRecognitionService(apiKey: 'test-key');

    test('parses strict JSON array wrapped in markdown fences', () {
      const raw = '''
```json
[
  {"food_name": "Grilled Chicken", "estimated_grams": 180},
  {"food_name": "Rice", "estimated_grams": 120}
]
```
''';

      final result = service.parseFoodsResponse(raw);

      expect(result, hasLength(2));
      expect(result.first.foodName, 'Grilled Chicken');
      expect(result.first.estimatedGrams, 180);
      expect(result.last.foodName, 'Rice');
      expect(result.last.estimatedGrams, 120);
    });

    test('returns empty list when no JSON array can be extracted', () {
      const raw = 'Could not identify this image.';

      final result = service.parseFoodsResponse(raw);

      expect(result, isEmpty);
    });
  });
}
