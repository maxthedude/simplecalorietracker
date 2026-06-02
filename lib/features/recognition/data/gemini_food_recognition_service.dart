import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../domain/recognized_food.dart';

class GeminiFoodRecognitionService {
  GeminiFoodRecognitionService({required this.apiKey})
      : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final String apiKey;
  final GenerativeModel _model;

  static const _prompt =
      'Identify all foods in this meal photo and estimate each portion in grams. '
      'Return ONLY a strict JSON array. Each array item must contain exactly '
      'these keys: "food_name" and "estimated_grams".';

  Future<List<RecognizedFood>> recognizeFoodsFromImage(Uint8List imageBytes) async {
    try {
      final response = await _model.generateContent([
        Content.multi([
          TextPart(_prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);
      return parseFoodsResponse(response.text ?? '[]');
    } catch (e, stackTrace) {
      debugPrint('Gemini recognition failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  List<RecognizedFood> parseFoodsResponse(String rawText) {
    final cleaned = _cleanJsonResponse(rawText);
    final decoded = jsonDecode(cleaned);

    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RecognizedFood.fromJson)
        .where((item) => item.foodName.isNotEmpty)
        .toList(growable: false);
  }

  String _cleanJsonResponse(String value) {
    final withoutFence = value.replaceAll(RegExp(r'```json|```', caseSensitive: false), '');
    final start = withoutFence.indexOf('[');
    final end = withoutFence.lastIndexOf(']');

    if (start >= 0 && end > start) {
      return withoutFence.substring(start, end + 1).trim();
    }

    return '[]';
  }
}
