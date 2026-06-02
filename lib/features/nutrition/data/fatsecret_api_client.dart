import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/nutrition_result.dart';

class FatSecretApiClient {
  FatSecretApiClient({
    required this.clientId,
    required this.clientSecret,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String clientId;
  final String clientSecret;
  final http.Client _httpClient;

  Future<NutritionResult> fetchNutritionForFood(String searchExpression) async {
    try {
      final token = await _getAccessToken();
      final searchUri = Uri.parse('https://platform.fatsecret.com/rest/server.api');
      final searchResponse = await _httpClient.post(
        searchUri,
        headers: {'Authorization': 'Bearer ' + token},
        body: {
          'method': 'foods.search.v3',
          'format': 'json',
          'search_expression': searchExpression,
          'max_results': '1',
          'page_number': '0',
        },
      );

      if (searchResponse.statusCode != 200) {
        throw Exception('FatSecret food search failed: ${searchResponse.statusCode}');
      }

      final decoded = jsonDecode(searchResponse.body) as Map<String, dynamic>;
      return _extractNutrition(decoded);
    } catch (e, stackTrace) {
      debugPrint('FatSecret request failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<String> _getAccessToken() async {
    final auth = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final tokenUri = Uri.parse('https://oauth.fatsecret.com/connect/token');

    final tokenResponse = await _httpClient.post(
      tokenUri,
      headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'scope': 'basic',
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('FatSecret token request failed: ${tokenResponse.statusCode}');
    }

    final decoded = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    return decoded['access_token'] as String;
  }

  NutritionResult _extractNutrition(Map<String, dynamic> payload) {
    final foods = payload['foods'] as Map<String, dynamic>?;
    final foodNode = foods?['food'];

    final firstFood = switch (foodNode) {
      final List list when list.isNotEmpty => list.first,
      final Map<String, dynamic> map => map,
      _ => null,
    };

    if (firstFood is! Map<String, dynamic>) {
      return const NutritionResult.empty();
    }

    final servings = firstFood['servings'] as Map<String, dynamic>?;
    final servingNode = servings?['serving'];

    final firstServing = switch (servingNode) {
      final List list when list.isNotEmpty => list.first,
      final Map<String, dynamic> map => map,
      _ => null,
    };

    if (firstServing is! Map<String, dynamic>) {
      return const NutritionResult.empty();
    }

    double parseValue(String key) => double.tryParse('${firstServing[key] ?? '0'}') ?? 0;

    return NutritionResult(
      calories: parseValue('calories'),
      protein: parseValue('protein'),
      carbs: parseValue('carbohydrate'),
      fat: parseValue('fat'),
    );
  }
}
