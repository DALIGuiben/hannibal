import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';
import 'settings_page.dart';

// ignore: constant_identifier_names
const String API_KEY = String.fromEnvironment('API_KEY');

const String _responsesEndpoint = 'https://codex.sale/v1/responses';
const String _model = 'gpt-6-luna';

/// Number of messages (user + assistant) sent to the model.
const int _memorySize = 10;

const Map<String, dynamic> _leaderReplySchema = {
  'type': 'object',
  'properties': {
    'replies': {
      'type': 'array',
      'minItems': 2,
      'maxItems': 3,
      'items': {
        'type': 'object',
        'properties': {
          'speaker': {
            'type': 'string',
            'enum': ['Hannibal', 'Scipio', 'Cato', 'Elissa', 'Hasdrubal'],
          },
          'text': {'type': 'string'},
        },
        'required': ['speaker', 'text'],
        'additionalProperties': false,
      },
    },
    'aura_change': {
      'type': 'integer',
      'enum': [0, 10],
    },
  },
  'required': ['replies', 'aura_change'],
  'additionalProperties': false,
};

// ignore: constant_identifier_names
const String SYSTEM_PROMPT = '''
You simulate a group chat with these characters: Hannibal Barca, Scipio Africanus, Cato the Elder, Elissa (Dido), and Hasdrubal. A Gen Z user has joined and sends messages.

Rules:
1. Each turn, 2 to 3 characters reply (not always all of them), in character, in short chat-style messages (1-2 sentences max).
2. They treat the user as a clueless Gen Z kid and never accept their claims at face value. They tease the user's slang, phone addiction, TikTok habits and short attention span.
3. Every roast must contain one REAL, accurate historical fact about Hannibal, Carthage, the Punic Wars, or Rome (examples: Cannae 216 BC, crossing the Alps with elephants, Zama 202 BC, Hannibal's exile, the founding of Carthage). Never invent facts.
4. If the user says something historically accurate and smart, one character admits it reluctantly ("...fine, the kid has a point") and set aura_change to 10. Otherwise aura_change is 0.
5. Personalities: Hannibal is dry and strategic. Scipio is smug and always mentions Zama. Cato ends EVERY message with "Carthage must be destroyed." Elissa is unimpressed and sarcastic. Hasdrubal is chaotic and misunderstands modern slang.
6. Occasionally mix in a few French or Tunisian Derja words.
7. Roast only the user's ideas and their Gen Z habits. Never mock their identity, religion, ethnicity, appearance, or politics. Keep it playful, never cruel or vulgar.
8. If the user asks something unrelated to history, the leaders mock it and steer the conversation back to Carthage and Rome.
9. Respond ONLY with valid JSON in this format: {"replies":[{"speaker":"Name","text":"..."}],"aura_change":0}
''';

/// System prompt + language block, rebuilt on every request.
String buildSystemPrompt(String lang) =>
    '${SYSTEM_PROMPT.trim()}\n\n${languageInstruction(lang)}';

const List<Map<String, dynamic>> _mockResponses = [
  {
    'replies': [
      {
        'speaker': 'Hasdrubal',
        'text':
            'Is “low-key” a Roman siege engine? Rome besieged Carthage for three years before taking it in 146 BC, ya weldi.',
      },
      {
        'speaker': 'Elissa',
        'text':
            'Your attention span would not survive a siege. Carthage was founded by Phoenician settlers from Tyre centuries before Rome became our rival.',
      },
    ],
    'aura_change': 0,
  },
  {
    'replies': [
      {
        'speaker': 'Hannibal',
        'text':
            'Put the phone down, recruit. At Cannae in 216 BC, we encircled a much larger Roman army; your strategy barely encircles a notification.',
      },
      {
        'speaker': 'Scipio',
        'text':
            'Adorable confidence. I defeated Hannibal at Zama in 202 BC without needing a fifteen-second tutorial.',
      },
      {
        'speaker': 'Cato',
        'text':
            'Your hot take cooled faster than Rome rebuilt its armies after Cannae. Carthage must be destroyed.',
      },
    ],
    'aura_change': 0,
  },
  {
    'replies': [
      {
        'speaker': 'Elissa',
        'text':
            'Béhi, another opinion with no sources. Ancient Carthage became a major Mediterranean trading power; your feed is not a primary document.',
      },
      {
        'speaker': 'Hannibal',
        'text':
            'We crossed the Alps in 218 BC with an army and elephants. You cannot cross a room without checking your battery.',
      },
    ],
    'aura_change': 0,
  },
];

const Map<String, dynamic> _accurateFactResponse = {
  'replies': [
    {
      'speaker': 'Hannibal',
      'text':
          'Fine, the kid has a point. That fact is sound—even if you learned it between two TikToks.',
    },
    {
      'speaker': 'Scipio',
      'text':
          'Do not let the aura go to your head. I still won at Zama in 202 BC.',
    },
    {
      'speaker': 'Cato',
      'text':
          'A correct fact from a glowing rectangle. Miracles happen. Carthage must be destroyed.',
    },
  ],
  'aura_change': 10,
};

/// AI boundary.
/// [history] already contains the current user message as its last item.
/// Items look like {"role": "user" | "assistant", "content": "..."}.
Future<Map<String, dynamic>> getLeadersReply(
  String userMessage,
  List<Map<String, String>> history,
  String lang,
) async {
  if (API_KEY.isEmpty) {
    return _getMockReply(userMessage, history);
  }

  // Memory: only the last [_memorySize] messages.
  final window = history.length > _memorySize
      ? history.sublist(history.length - _memorySize)
      : List<Map<String, String>>.of(history);
  // The conversation must start with a user message.
  while (window.isNotEmpty && window.first['role'] != 'user') {
    window.removeAt(0);
  }
  final messages = window
      .map((m) => {'role': m['role']!, 'content': m['content']!})
      .toList();

  final response = await http
      .post(
        Uri.parse(_responsesEndpoint),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'instructions': buildSystemPrompt(lang),
          'input': messages,
          'temperature': 0.9,
          'max_output_tokens': 600,
          'text': {
            'format': {
              'type': 'json_schema',
              'name': 'leaders_reply',
              'strict': true,
              'schema': _leaderReplySchema,
            },
          },
        }),
      )
      .timeout(const Duration(seconds: 30));

  final responseBody = utf8.decode(response.bodyBytes);
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'codex.sale returned ${response.statusCode}: '
      '${_readApiError(responseBody)}',
    );
  }

  final envelope = jsonDecode(responseBody);
  if (envelope is! Map<String, dynamic>) {
    throw const FormatException('codex.sale returned an invalid response.');
  }
  return _parseLeaderJson(_responseText(envelope), lang);
}

Future<Map<String, dynamic>> _getMockReply(
  String userMessage,
  List<Map<String, String>> history,
) async {
  if (_soundsHistoricallyAccurate(userMessage)) {
    return Map<String, dynamic>.from(_accurateFactResponse);
  }
  final index = Random().nextInt(_mockResponses.length);
  return Map<String, dynamic>.from(_mockResponses[index]);
}

String _contentAsText(dynamic content) {
  if (content is String) return content;
  if (content is List) {
    return content
        .whereType<Map>()
        .map((part) => part['text']?.toString() ?? '')
        .join();
  }
  throw const FormatException('The assistant response had no text content.');
}

String _responseText(Map<String, dynamic> envelope) {
  final directText = envelope['output_text'];
  if (directText is String && directText.isNotEmpty) return directText;

  final fragments = <String>[];
  final output = envelope['output'];
  if (output is List) {
    for (final item in output) {
      if (item is! Map || item['content'] is! List) continue;
      for (final block in item['content'] as List) {
        if (block is! Map) continue;
        if (block['type'] == 'refusal') {
          throw FormatException(
            block['refusal']?.toString() ?? 'The model refused the request.',
          );
        }
        final text = block['text'];
        if (text is String && text.isNotEmpty) fragments.add(text);
      }
    }
  }
  if (fragments.isNotEmpty) return fragments.join();

  final choices = envelope['choices'];
  if (choices is List && choices.isNotEmpty && choices.first is Map) {
    final message = (choices.first as Map)['message'];
    if (message is Map) return _contentAsText(message['content']);
  }
  throw const FormatException('The response contained no assistant text.');
}

Map<String, dynamic> _parseLeaderJson(String rawContent, String lang) {
  final firstBrace = rawContent.indexOf('{');
  final lastBrace = rawContent.lastIndexOf('}');
  if (firstBrace < 0 || lastBrace <= firstBrace) {
    throw const FormatException('The assistant did not return JSON.');
  }

  final decoded = jsonDecode(rawContent.substring(firstBrace, lastBrace + 1));
  if (decoded is! Map<String, dynamic> || decoded['replies'] is! List) {
    throw const FormatException('The assistant JSON has an invalid shape.');
  }

  // Only enforced for en/fr; Arabic and Derja wording varies too much.
  final catchphrase = kCatoPhrase[lang];

  final replies = <Map<String, String>>[];
  for (final rawReply in decoded['replies'] as List) {
    if (rawReply is! Map) continue;
    final speaker = rawReply['speaker']?.toString() ?? '';
    var text = rawReply['text']?.toString().trim() ?? '';
    if (!_leaders.containsKey(speaker) || text.isEmpty) continue;
    if (speaker == 'Cato' &&
        catchphrase != null &&
        !text.endsWith(catchphrase)) {
      text = '$text $catchphrase';
    }
    replies.add({'speaker': speaker, 'text': text});
    if (replies.length == 3) break;
  }
  if (replies.length < 2) {
    throw const FormatException(
      'The assistant returned fewer than two replies.',
    );
  }

  final rawAura = (decoded['aura_change'] as num?)?.toInt() ?? 0;
  return {'replies': replies, 'aura_change': rawAura == 10 ? 10 : 0};
}

String _readApiError(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map && decoded['error'] is Map) {
      return (decoded['error'] as Map)['message']?.toString() ??
          'Unknown API error';
    }
  } on FormatException {
    // An upstream proxy can occasionally return non-JSON error content.
  }
  return 'Unknown API error';
}

bool _soundsHistoricallyAccurate(String message) {
  final text = message.toLowerCase();
  return <RegExp>[
    RegExp(r'cannae.{0,24}216|216.{0,24}cannae'),
    RegExp(r'zama.{0,24}202|202.{0,24}zama'),
    RegExp(r'alps?.{0,30}elephant|elephant.{0,30}alps?'),
    RegExp(
      r'carthage.{0,30}(phoenician|tyre)|(phoenician|tyre).{0,30}carthage',
    ),
    RegExp(
      r'second punic war.{0,30}(218|201)|(218|201).{0,30}second punic war',
    ),
    RegExp(r'carthage.{0,30}146|146.{0,30}carthage'),
  ].any((fact) => fact.hasMatch(text));
}

class _Leader {
  const _Leader(this.name, this.emoji, this.color);
  final String name;
  final String emoji;
  final Color color;
}

const Map<String, _Leader> _leaders = {
  'Hannibal': _Leader('Hannibal Barca', '🐘', Color(0xFF273D51)),
  'Scipio': _Leader('Scipio Africanus', '🦅', Color(0xFF4B315C)),
  'Cato': _Leader('Cato the Elder', '📜', Color(0xFF55332F)),
  'Elissa': _Leader('Elissa (Dido)', '👑', Color(0xFF4E3D20)),
  'Hasdrubal': _Leader('Hasdrubal', '⚔️', Color(0xFF214844)),
};

class _Message {
  const _Message(this.speaker, this.text, this.time, {this.isUser = false});
  final String speaker;
  final String text;
  final DateTime time;
  final bool isUser;
}

class HannibalGroupChatPage extends StatefulWidget {
  const HannibalGroupChatPage({super.key, this.showWelcome = true});

  final bool showWelcome;

  @override
  State<HannibalGroupChatPage> createState() => _HannibalGroupChatPageState();
}

class _HannibalGroupChatPageState extends State<HannibalGroupChatPage> {
  static const _prefsKey = 'chat_lang';

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final List<_Message> _messages = [];

  /// Model memory: {"role": "user" | "assistant", "content": "..."}.
  /// Assistant content is the raw JSON string of the reply.
  final List<Map<String, String>> _history = [];

  bool _busy = true;
  bool _showAuraBonus = false;
  String? _typingSpeaker;
  int _aura = 0;
  String _lang = 'en';

  /// Incremented on "clear" so in-flight work from the old chat is dropped.
  int _epoch = 0;

  String get _rank => _aura >= 120
      ? tr(_lang, 'rank_barca')
      : _aura >= 70
      ? tr(_lang, 'rank_general')
      : _aura >= 30
      ? tr(_lang, 'rank_soldier')
      : tr(_lang, 'rank_recruit');

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && kLanguageCodes.contains(saved)) _lang = saved;
    } catch (error) {
      debugPrint('Could not load language: $error');
    }
    if (!mounted) return;
    setState(() {});
    if (widget.showWelcome) {
      await _welcome();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _setLanguage(String code) async {
    setState(() => _lang = code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (error) {
      debugPrint('Could not save language: $error');
    }
  }

  void _clearConversation() {
    _epoch++;
    setState(() {
      _messages.clear();
      _history.clear();
      _aura = 0;
      _showAuraBonus = false;
      _typingSpeaker = null;
      _busy = true;
    });
    unawaited(_welcome());
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          lang: _lang,
          onLanguageChanged: _setLanguage,
          onClear: _clearConversation,
        ),
      ),
    );
  }

  Future<void> _welcome() async {
    final epoch = _epoch;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted || epoch != _epoch) return;
    await _reveal({
      'replies': kWelcome[_lang] ?? kWelcome['en']!,
      'aura_change': 0,
    }, epoch);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    final epoch = _epoch;
    _input.clear();
    _add(_Message('User', text, DateTime.now(), isUser: true));
    _history.add({'role': 'user', 'content': text});
    setState(() => _busy = true);

    try {
      final result = await getLeadersReply(text, List.of(_history), _lang);
      if (!mounted || epoch != _epoch) return;
      _history.add({'role': 'assistant', 'content': jsonEncode(result)});
      await _reveal(result, epoch);
    } catch (error, stackTrace) {
      debugPrint('AI reply failed: $error\n$stackTrace');
      if (!mounted || epoch != _epoch) return;
      // Keep memory consistent: drop the user message that got no answer.
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      _add(_Message('Hannibal', tr(_lang, 'error'), DateTime.now()));
      setState(() {
        _busy = false;
        _typingSpeaker = null;
      });
    }
  }

  Future<void> _reveal(Map<String, dynamic> response, int epoch) async {
    final replies = response['replies'];
    if (replies is! List) throw const FormatException('Missing replies list.');

    for (final reply in replies) {
      if (reply is! Map) continue;
      final speaker = reply['speaker']?.toString() ?? 'Hannibal';
      final text = reply['text']?.toString() ?? '';
      if (text.isEmpty) continue;

      if (!mounted || epoch != _epoch) return;
      setState(() {
        _busy = true;
        _typingSpeaker = speaker;
      });
      _scrollDown();
      await Future<void>.delayed(
        Duration(milliseconds: 900 + Random().nextInt(250)),
      );
      if (!mounted || epoch != _epoch) return;
      _add(_Message(speaker, text, DateTime.now()));
      setState(() => _typingSpeaker = null);
      await Future<void>.delayed(
        Duration(milliseconds: 280 + Random().nextInt(180)),
      );
    }

    if (!mounted || epoch != _epoch) return;
    final auraChange = (response['aura_change'] as num?)?.toInt() ?? 0;
    setState(() {
      _aura += auraChange;
      _showAuraBonus = auraChange > 0;
      _busy = false;
      _typingSpeaker = null;
    });
    if (auraChange > 0) {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 1300), () {
          if (mounted) setState(() => _showAuraBonus = false);
        }),
      );
    }
    _focus.requestFocus();
  }

  /// Adds a bubble to the screen only. Memory is handled in _send.
  void _add(_Message message) {
    if (!mounted) return;
    setState(() => _messages.add(message));
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRtl(_lang) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [Color(0xFF241C10), Color(0xFF070A0F)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                return Center(
                  child: Container(
                    width: wide ? 760 : double.infinity,
                    margin: wide ? const EdgeInsets.all(20) : EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D131C),
                      borderRadius: BorderRadius.circular(wide ? 24 : 0),
                      border: wide
                          ? Border.all(
                              color: Colors.white.withValues(alpha: .1),
                            )
                          : null,
                      boxShadow: wide
                          ? const [
                              BoxShadow(
                                color: Color(0x88000000),
                                blurRadius: 60,
                                offset: Offset(0, 24),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        _Header(
                          lang: _lang,
                          aura: _aura,
                          rank: _rank,
                          showBonus: _showAuraBonus,
                          onSettings: _openSettings,
                        ),
                        Expanded(
                          child: _MessageList(
                            lang: _lang,
                            messages: _messages,
                            typingSpeaker: _typingSpeaker,
                            controller: _scroll,
                          ),
                        ),
                        _Composer(
                          lang: _lang,
                          input: _input,
                          focus: _focus,
                          enabled: !_busy,
                          onSend: _send,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.lang,
    required this.aura,
    required this.rank,
    required this.showBonus,
    required this.onSettings,
  });
  final String lang;
  final int aura;
  final String rank;
  final bool showBonus;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D131C),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B2D19), Color(0xFF171B22)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x55E0B25B)),
            ),
            child: const Text('🐘', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(lang, 'title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF49C995),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 7, height: 7),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tr(lang, 'online'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8F9BAB),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 78),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x12E0B25B),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0x38E0B25B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        '$aura ${tr(lang, 'aura')}',
                        key: ValueKey(aura),
                        style: const TextStyle(
                          color: Color(0xFFF4CC78),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      rank.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF8F9BAB),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -2,
                right: 4,
                child: AnimatedSlide(
                  offset: showBonus ? const Offset(0, -1.6) : Offset.zero,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedOpacity(
                    opacity: showBonus ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      '+10 ${tr(lang, 'aura')}',
                      style: const TextStyle(
                        color: Color(0xFFFFDC88),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: tr(lang, 'settings'),
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded),
            color: const Color(0xFFAAB3C0),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.lang,
    required this.messages,
    required this.typingSpeaker,
    required this.controller,
  });
  final String lang;
  final List<_Message> messages;
  final String? typingSpeaker;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final count = messages.length + (typingSpeaker == null ? 1 : 2);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1018), Color(0xFF090E15)],
        ),
      ),
      child: ListView.builder(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
        itemCount: count,
        itemBuilder: (context, index) {
          if (index == 0) return _DayDivider(lang: lang);
          final messageIndex = index - 1;
          if (messageIndex < messages.length) {
            return _Bubble(
              key: ValueKey(
                '${messages[messageIndex].time.microsecondsSinceEpoch}-$index',
              ),
              message: messages[messageIndex],
            );
          }
          return _Typing(lang: lang, speaker: typingSpeaker!);
        },
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.lang});
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF141B25),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Text(
          tr(lang, 'divider'),
          style: const TextStyle(
            color: Color(0xFFAAB3C0),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatefulWidget {
  const _Bubble({super.key, required this.message});
  final _Message message;

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fade = curve;
    _slide = Tween(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final leader = _leaders[message.speaker] ?? _leaders['Hannibal']!;
    final time =
        '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}';
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: message.isUser ? 54 : 0,
            end: message.isUser ? 0 : 30,
            bottom: 14,
          ),
          child: Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                _Avatar(leader),
                const SizedBox(width: 9),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!message.isUser)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 4,
                          bottom: 5,
                        ),
                        child: Text(
                          leader.name,
                          style: const TextStyle(
                            color: Color(0xFFBDC5D1),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        13,
                        10,
                        11,
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color(0xFF246B57)
                            : leader.color,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(message.isUser ? 17 : 7),
                          topEnd: Radius.circular(message.isUser ? 7 : 17),
                          bottomStart: const Radius.circular(17),
                          bottomEnd: const Radius.circular(17),
                        ),
                        border: Border.all(
                          color: message.isUser
                              ? const Color(0xFF388C74)
                              : Colors.white.withValues(alpha: .075),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29000000),
                            blurRadius: 18,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            message.text,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .48),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing({required this.lang, required this.speaker});
  final String lang;
  final String speaker;

  @override
  Widget build(BuildContext context) {
    final leader = _leaders[speaker] ?? _leaders['Hannibal']!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 30, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(leader),
          const SizedBox(width: 9),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF18202B),
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(7),
                  topEnd: Radius.circular(16),
                  bottomStart: Radius.circular(16),
                  bottomEnd: Radius.circular(16),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: .08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      tr(lang, 'typing', {'name': leader.name}),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFAAB4C1),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _TypingDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.leader);
  final _Leader leader;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF18202C),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Text(leader.emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final phase = (_controller.value - index * .16) % 1.0;
          final lift = sin(phase * pi * 2).clamp(0.0, 1.0) * 3;
          return Transform.translate(
            offset: Offset(0, -lift),
            child: Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: const BoxDecoration(
                color: Color(0xFFE0B25B),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.lang,
    required this.input,
    required this.focus,
    required this.enabled,
    required this.onSend,
  });
  final String lang;
  final TextEditingController input;
  final FocusNode focus;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : .58,
      duration: const Duration(milliseconds: 180),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        decoration: BoxDecoration(
          color: const Color(0xFF0D131C),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: .08)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: input,
                focusNode: focus,
                enabled: enabled,
                maxLength: 280,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: tr(lang, 'hint'),
                  hintStyle: const TextStyle(color: Color(0xFF768294)),
                  filled: true,
                  fillColor: const Color(0xFF151D28),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: .1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0x99E0B25B)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: .07),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: enabled ? onSend : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(tr(lang, 'send')),
                style: FilledButton.styleFrom(
                  foregroundColor: const Color(0xFF171108),
                  backgroundColor: const Color(0xFFE0B25B),
                  disabledBackgroundColor: const Color(0x66E0B25B),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}