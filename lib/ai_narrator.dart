import 'dart:convert';

import 'package:http/http.dart' as http;

import 'experience_data.dart';

// Pass the key at launch with --dart-define=CODEX_LB_API_KEY=...
// API_KEY remains accepted for existing local run configurations.
const String apiKey = String.fromEnvironment(
  'CODEX_LB_API_KEY',
  defaultValue: String.fromEnvironment('API_KEY'),
);
const String _endpoint = 'https://codex.sale/v1/responses';
const String _model = 'gpt-4o';

class AiNarrator {
  const AiNarrator();

  bool get isConfigured => apiKey.isNotEmpty;

  Future<String> consequence({
    required Dilemma dilemma,
    required DecisionOption choice,
    required bool wasHistoricalChoice,
    String language = 'en',
  }) async {
    if (!isConfigured) return choice.outcome;
    try {
      return await _generate(
        instructions:
            'You write a short field note for a historical decision game. '
            'Return ONLY JSON with one string field named "text". '
            'Write one vivid second-person sentence, at most 35 words. '
            'Use only the verified historical fact supplied. '
            'If the choice differs from history, frame any outcome as an '
            'imagined possibility, never as something that actually happened. '
            'Do not invent dates, battles, deaths, or quotes.',
        language: language,
        input:
            'Scenario: ${dilemma.year}, ${dilemma.place}. '
            'Situation: ${dilemma.setup} '
            'Choice: ${choice.label}. '
            'This was Hannibal’s actual choice: $wasHistoricalChoice. '
            'Verified fact: ${dilemma.historicalTruth} '
            'Game outcome to personalize: ${choice.outcome}',
      );
    } catch (_) {
      // A failed network request must never block the next game card.
      return choice.outcome;
    }
  }

  Future<String> wrappedDescription({
    required WrappedResult result,
    required List<String> decisions,
    String language = 'en',
  }) async {
    if (!isConfigured) return result.match.fallbackDescription;
    try {
      return await _generate(
        instructions:
            'You write the personalized closing line for Hannibal Wrapped. '
            'Return ONLY JSON with one string field named "text". '
            'Write exactly two playful, sharp sentences in second person, '
            'at most 48 words total. Reflect the supplied game choices and '
            'traits. This is a personality game, not a factual biography. '
            'Do not invent historical events, dates, or quotes.',
        language: language,
        input:
            'Match: ${result.match.name} (${result.percentage}%). '
            'Traits: strategy ${result.strategy}, audacity ${result.audacity}, '
            'diplomacy ${result.diplomacy}, resolve ${result.resolve}. '
            'Decisions: ${decisions.isEmpty ? 'none yet' : decisions.join('; ')}. '
            'Fatal flaw: ${result.match.fatalFlaw}',
      );
    } catch (_) {
      return result.match.fallbackDescription;
    }
  }

  Future<String> _generate({
    required String instructions,
    required String input,
    required String language,
  }) async {
    final languageInstruction = switch (language) {
      'fr' => 'Write the JSON text value entirely in French.',
      'ar' =>
        'Write the JSON text value entirely in Modern Standard Arabic using Arabic script.',
      _ => 'Write the JSON text value in English.',
    };
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'instructions': '$instructions $languageInstruction',
            'input': input,
            'max_output_tokens': 130,
            'text': {
              'format': {'type': 'json_object'},
            },
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Narrator request failed: ${response.statusCode}');
    }
    final envelope = jsonDecode(utf8.decode(response.bodyBytes));
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Invalid narrator response.');
    }
    final decoded = jsonDecode(_extractText(envelope));
    if (decoded is! Map || decoded['text'] is! String) {
      throw const FormatException('Narrator JSON has no text.');
    }
    final text = (decoded['text'] as String).trim();
    if (text.isEmpty) throw const FormatException('Narrator text is empty.');
    return text;
  }

  String _extractText(Map<String, dynamic> envelope) {
    final direct = envelope['output_text'];
    if (direct is String && direct.isNotEmpty) return direct;

    final output = envelope['output'];
    if (output is List) {
      final parts = <String>[];
      for (final item in output) {
        if (item is! Map || item['content'] is! List) continue;
        for (final block in item['content'] as List) {
          if (block is Map && block['text'] is String) {
            parts.add(block['text'] as String);
          }
        }
      }
      if (parts.isNotEmpty) return parts.join();
    }

    final choices = envelope['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final message = (choices.first as Map)['message'];
      if (message is Map && message['content'] is String) {
        return message['content'] as String;
      }
    }
    throw const FormatException('Narrator produced no text.');
  }
}
