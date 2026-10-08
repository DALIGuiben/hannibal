// UI translations, language names, and the per-language AI instructions.

const List<String> kLanguageCodes = ['en', 'fr', 'ar', 'aeb'];

const Map<String, String> kLanguageNames = {
  'en': 'English',
  'fr': 'Français',
  'ar': 'العربية',
  'aeb': 'الدارجة التونسية',
};

bool isRtl(String lang) => lang == 'ar' || lang == 'aeb';

const Map<String, Map<String, String>> _t = {
  'en': {
    'title': "Hannibal's Group Chat",
    'online': '5 leaders online',
    'aura': 'Aura',
    'rank_recruit': 'Recruit',
    'rank_soldier': 'Soldier',
    'rank_general': 'General',
    'rank_barca': 'Barca',
    'divider': 'WAR COUNCIL · TODAY',
    'hint': 'Message the war council…',
    'send': 'Send',
    'typing': '{name} is typing…',
    'error': 'The messenger got lost near the Alps. Try again, recruit.',
    'settings': 'Settings',
    'chat_language': 'Chat language',
    'clear': 'Clear conversation',
    'clear_title': 'Clear conversation?',
    'clear_body': 'This deletes all messages and the leaders\' memory.',
    'cancel': 'Cancel',
    'confirm': 'Clear',
  },
  'fr': {
    'title': 'Le groupe de Hannibal',
    'online': '5 chefs en ligne',
    'aura': 'Aura',
    'rank_recruit': 'Recrue',
    'rank_soldier': 'Soldat',
    'rank_general': 'Général',
    'rank_barca': 'Barca',
    'divider': 'CONSEIL DE GUERRE · AUJOURD\'HUI',
    'hint': 'Écris au conseil de guerre…',
    'send': 'Envoyer',
    'typing': '{name} est en train d\'écrire…',
    'error': 'Le messager s\'est perdu près des Alpes. Réessaie, recrue.',
    'settings': 'Paramètres',
    'chat_language': 'Langue du chat',
    'clear': 'Effacer la conversation',
    'clear_title': 'Effacer la conversation ?',
    'clear_body': 'Cela supprime tous les messages et la mémoire des chefs.',
    'cancel': 'Annuler',
    'confirm': 'Effacer',
  },
  'ar': {
    'title': 'مجموعة حنبعل',
    'online': '5 قادة متصلون',
    'aura': 'هالة',
    'rank_recruit': 'مجنّد',
    'rank_soldier': 'جندي',
    'rank_general': 'جنرال',
    'rank_barca': 'برقة',
    'divider': 'مجلس الحرب · اليوم',
    'hint': 'اكتب إلى مجلس الحرب…',
    'send': 'إرسال',
    'typing': '{name} يكتب…',
    'error': 'ضلّ الرسول طريقه قرب جبال الألب. حاول مجددًا أيها المجنّد.',
    'settings': 'الإعدادات',
    'chat_language': 'لغة المحادثة',
    'clear': 'مسح المحادثة',
    'clear_title': 'مسح المحادثة؟',
    'clear_body': 'سيتم حذف كل الرسائل وذاكرة القادة.',
    'cancel': 'إلغاء',
    'confirm': 'مسح',
  },
  'aeb': {
    'title': 'قروب حنبعل',
    'online': '5 قادة أونلاين',
    'aura': 'أورا',
    'rank_recruit': 'مجنّد',
    'rank_soldier': 'عسكري',
    'rank_general': 'جنرال',
    'rank_barca': 'برقة',
    'divider': 'مجلس الحرب · اليوم',
    'hint': 'اكتب لمجلس الحرب…',
    'send': 'ابعث',
    'typing': '{name} يكتب…',
    'error': 'الرسول تاه حذا الألب. عاود جرّب يا مجنّد.',
    'settings': 'الإعدادات',
    'chat_language': 'لغة الدردشة',
    'clear': 'امسح المحادثة',
    'clear_title': 'تمسح المحادثة؟',
    'clear_body': 'باش تتمسح كل الرسائل وذاكرة القادة.',
    'cancel': 'إلغاء',
    'confirm': 'امسح',
  },
};

String tr(String lang, String key, [Map<String, String> args = const {}]) {
  var s = _t[lang]?[key] ?? _t['en']![key] ?? key;
  args.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

/// Welcome messages shown at the start (in the selected language).
const Map<String, List<Map<String, String>>> kWelcome = {
  'en': [
    {
      'speaker': 'Hannibal',
      'text':
          'Who added this kid to the war council? Pay attention longer than our Alpine crossing in 218 BC.',
    },
    {
      'speaker': 'Cato',
      'text':
          'Another teenager with a glowing tablet. Romans used wax tablets and had better attention spans. Carthage must be destroyed.',
    },
  ],
  'fr': [
    {
      'speaker': 'Hannibal',
      'text':
          'Qui a ajouté ce gamin au conseil de guerre ? Concentre-toi plus longtemps que notre traversée des Alpes en 218 av. J.-C.',
    },
    {
      'speaker': 'Cato',
      'text':
          'Encore un ado avec une tablette lumineuse. Les Romains avaient des tablettes de cire et une meilleure concentration. Carthage doit être détruite.',
    },
  ],
  'ar': [
    {
      'speaker': 'Hannibal',
      'text':
          'من أضاف هذا الفتى إلى مجلس الحرب؟ ركّز مدةً أطول من عبورنا جبال الألب عام 218 ق.م.',
    },
    {
      'speaker': 'Cato',
      'text':
          'مراهق آخر بلوح مضيء. كان الرومان يستخدمون ألواح الشمع وكانوا أكثر تركيزًا. يجب أن تُدمَّر قرطاج.',
    },
  ],
  'aeb': [
    {
      'speaker': 'Hannibal',
      'text':
          'شكون زاد الصغير هذا في مجلس الحرب؟ ركّز أكثر من عبورنا للألب في 218 ق.م.',
    },
    {
      'speaker': 'Cato',
      'text':
          'مرة أخرى مراهق بتابلات تضوّي. الرومان كانو يستعملو في ألواح الشمع وتركيزهم أحسن. قرطاج لازم تتهدم.',
    },
  ],
};

/// Cato's catchphrase per language (the app appends it only for en/fr).
const Map<String, String> kCatoPhrase = {
  'en': 'Carthage must be destroyed.',
  'fr': 'Carthage doit être détruite.',
};

const Map<String, String> _languageBlocks = {
  'en':
      'LANGUAGE: Reply in English. Occasionally sprinkle a few French or Tunisian words.',
  'fr':
      'LANGUAGE: Reply entirely in French, with a playful, youthful tone. Translate Cato\'s catchphrase as « Carthage doit être détruite. »',
  'ar':
      'LANGUAGE: Reply entirely in Modern Standard Arabic (Arabic script). Keep it short and witty. Translate Cato\'s catchphrase as «يجب أن تُدمَّر قرطاج.»',
  'aeb':
      'LANGUAGE: Reply entirely in Tunisian Derja (Tunisian Arabic dialect), written in Arabic script, as a young Tunisian would text. Mix in the occasional French word as Tunisians naturally do. Translate Cato\'s catchphrase into Derja, for example «قرطاج لازم تتهدم.»',
};

const String _languageRules = '''
LANGUAGE RULES (these override any earlier rule about language, French/Derja mixing or Cato's catchphrase wording):
- The JSON keys and the "speaker" values must stay in English and unchanged ("Hannibal", "Scipio", "Cato", "Elissa", "Hasdrubal"). Only the "text" values are translated.
- Historical facts must remain accurate in every language.
- Always reply in the language above, even if earlier messages in the conversation were in another language. If the user switches language, switch immediately.
- Keep roasts playful: never mock identity, religion, ethnicity, appearance or politics.
''';

String languageInstruction(String lang) =>
    '${_languageBlocks[lang] ?? _languageBlocks['en']!}\n\n$_languageRules';