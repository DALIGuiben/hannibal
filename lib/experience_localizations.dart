import 'package:flutter/widgets.dart';

import 'experience_content_localizations.dart';

const supportedExperienceLanguages = <String, String>{
  'en': 'English',
  'fr': 'Français',
  'ar': 'العربية',
};

class ExperienceLanguage extends InheritedWidget {
  const ExperienceLanguage({
    super.key,
    required this.code,
    required super.child,
  });

  final String code;

  static String of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExperienceLanguage>()?.code ??
      'en';

  @override
  bool updateShouldNotify(ExperienceLanguage oldWidget) =>
      code != oldWidget.code;
}

String translated(String language, String english) {
  if (language == 'en') return english;
  final value =
      _translations[language]?[english] ??
      contentTranslations[english]?[language == 'fr' ? 0 : 1];
  assert(value != null, 'Missing $language translation: $english');
  return value ?? english;
}

String tx(BuildContext context, String english) =>
    translated(ExperienceLanguage.of(context), english);

String translatedYear(String language, String year) => year.replaceAll(
  'BC',
  language == 'fr'
      ? 'av. J.-C.'
      : language == 'ar'
      ? 'ق.م'
      : 'BC',
);

String translatedTemplate(
  String language,
  String english,
  Map<String, Object> values,
) {
  var result = translated(language, english);
  for (final entry in values.entries) {
    result = result.replaceAll('{${entry.key}}', '${entry.value}');
  }
  return result;
}

bool hasTranslation(String language, String english) =>
    language == 'en' ||
    _translations[language]?.containsKey(english) == true ||
    contentTranslations.containsKey(english);

const _translations = <String, Map<String, String>>{
  'fr': {
    'Home': 'Accueil',
    'Dilemma': 'Dilemme',
    'Wrapped': 'Portrait',
    'Language': 'Langue',
    'Choose the language for the whole app':
        'Choisissez la langue de toute l’application',
    'HANNIBAL / YOUR LEGACY': 'HANNIBAL / VOTRE HÉRITAGE',
    'History is decided\none choice at a time.':
        'L’histoire se joue\nun choix à la fois.',
    'Command the campaign. Then discover the ancient leader inside your decisions.':
        'Dirigez la campagne, puis découvrez le chef antique que révèlent vos décisions.',
    '01 / PLAY': '01 / JOUER',
    'Hannibal’s\nDilemma': 'Le dilemme\nd’Hannibal',
    'Swipe through real turning points. See the price of every move.':
        'Traversez de vrais tournants de l’histoire. Découvrez le prix de chaque décision.',
    '7 HISTORICAL DECISIONS · NEW ON REPLAY':
        '7 CHOIX HISTORIQUES · NOUVEAUX AU REPLAY',
    'CAMPAIGN COMPLETE': 'CAMPAGNE TERMINÉE',
    'CONTINUE {count} OF {total}': 'REPRENDRE : {count} SUR {total}',
    '02 / DISCOVER': '02 / DÉCOUVRIR',
    'Hannibal\nWrapped': 'Portrait\nd’Hannibal',
    'Seven fresh choices each run. One ancient alter ego. A result worth sharing.':
        'Sept nouveaux choix à chaque partie. Un alter ego antique à partager.',
    'YOUR CAMPAIGN CAN SHAPE THE RESULT':
        'VOTRE CAMPAGNE INFLUENCE LE RÉSULTAT',
    '{count} CAMPAIGN CHOICES INCLUDED':
        '{count} CHOIX DE CAMPAGNE PRIS EN COMPTE',
    'The choices are yours. The historical facts stay true.':
        'Les choix sont les vôtres. Les faits historiques restent vrais.',
    'HANNIBAL’S DILEMMA': 'LE DILEMME D’HANNIBAL',
    'THE DECISION IS YOURS': 'À VOUS DE DÉCIDER',
    'SWIPE THE CARD OR TAP A CHOICE': 'GLISSEZ LA CARTE OU TOUCHEZ UN CHOIX',
    'LEFT': 'GAUCHE',
    'RIGHT': 'DROITE',
    'YOU CHOSE HANNIBAL’S MOVE': 'VOUS AVEZ CHOISI COMME HANNIBAL',
    'A DIFFERENT TIMELINE': 'UNE AUTRE HISTOIRE',
    'RISK': 'RISQUE',
    'SURPRISE': 'SURPRISE',
    'ARMY': 'ARMÉE',
    'Game stats illustrate trade-offs; they are not historical measurements.':
        'Les statistiques illustrent les choix ; ce ne sont pas des mesures historiques.',
    'THE CONSEQUENCE': 'LA CONSÉQUENCE',
    'AI FIELD NOTE': 'NOTE DE L’IA',
    'CAMPAIGN NOTE': 'NOTE DE CAMPAGNE',
    'WHAT HANNIBAL DID': 'CE QU’HANNIBAL A FAIT',
    'Next decision': 'Choix suivant',
    'Finish campaign': 'Terminer la campagne',
    'THE CAMPAIGN IS COMPLETE': 'LA CAMPAGNE EST TERMINÉE',
    'You shaped\nthe war.': 'Vous avez changé\nla guerre.',
    'Your decisions now influence your Hannibal Wrapped result. Seven quick questions reveal your ancient alter ego.':
        'Vos décisions influencent maintenant votre portrait. Sept questions révèlent votre alter ego antique.',
    'History remembers Hannibal’s choices. Wrapped remembers yours.':
        'L’histoire retient les choix d’Hannibal. Le portrait retient les vôtres.',
    'Discover your alter ego': 'Découvrir mon alter ego',
    'Replay the campaign': 'Rejouer la campagne',
    'HANNIBAL WRAPPED': 'PORTRAIT D’HANNIBAL',
    'YOUR RESULT': 'VOTRE RÉSULTAT',
    'YOUR INSTINCTS, REVEALED': 'VOS INSTINCTS DÉVOILÉS',
    'Choose what you would actually do.':
        'Choisissez ce que vous feriez vraiment.',
    '{count} Dilemma decisions will shape your match too.':
        '{count} choix du Dilemme influenceront aussi votre profil.',
    'NO WRONG ANSWERS. JUST YOUR STORY.':
        'PAS DE MAUVAISE RÉPONSE. JUSTE VOTRE HISTOIRE.',
    'THE VERDICT IS IN': 'LE VERDICT EST TOMBÉ',
    'Share to Instagram Story': 'Partager en story Instagram',
    'Preparing your Story…': 'Préparation de votre story…',
    'Instagram opened. You choose whether to post your Story.':
        'Instagram est ouvert. Vous choisissez de publier ou non votre story.',
    'Instagram is not installed. Install it to share your Story.':
        'Instagram n’est pas installé. Installez-le pour partager votre story.',
    'Instagram Stories is available on Android only.':
        'Le partage en story Instagram est disponible sur Android uniquement.',
    'Could not open Instagram Stories. Please try again.':
        'Impossible d’ouvrir les stories Instagram. Réessayez.',
    'Replay Dilemma': 'Rejouer le Dilemme',
    'Play Dilemma': 'Jouer au Dilemme',
    'Retake the quiz': 'Refaire le quiz',
    'YOU ARE': 'VOUS ÊTES',
    'STRATEGIC': 'STRATÈGE',
    'AUDACIOUS': 'AUDACIEUX',
    'DIPLOMATIC': 'DIPLOMATE',
    'RESOLUTE': 'DÉTERMINÉ',
    'YOUR FATAL FLAW': 'VOTRE TALON D’ACHILLE',
    '{count} campaign choices shaped this result':
        '{count} choix de campagne ont façonné ce résultat',
    'Back': 'Retour',
    'Hannibal Barca': 'Hannibal Barca',
    'Scipio Africanus': 'Scipion l’Africain',
    'Elissa (Dido)': 'Élyssa (Didon)',
    'Fabius Maximus': 'Fabius Maximus',
    'THE IMPOSSIBLE ROUTE': 'LA ROUTE IMPOSSIBLE',
    'THE PATIENT COUNTERSTRIKE': 'LA RIPOSTE PATIENTE',
    'THE CITY BUILDER': 'LA BÂTISSEUSE DE CITÉ',
    'THE LONG GAME': 'LE JEU DE LA PATIENCE',
    'You win battles faster than you finish wars.':
        'Vous gagnez les batailles plus vite que vous ne terminez les guerres.',
    'You can spend so long reading the board that others move first.':
        'À force d’analyser le terrain, vous laissez parfois les autres agir d’abord.',
    'You carry the weight of every alliance yourself.':
        'Vous portez seul le poids de chaque alliance.',
    'Your patience may look like hesitation when the moment is real.':
        'Votre patience peut passer pour de l’hésitation au moment décisif.',
    'You see a route where everyone else sees a wall. Your bold ideas work best when you plan what happens after the victory.':
        'Vous voyez un chemin là où les autres voient un mur. Vos idées audacieuses réussissent mieux quand vous prévoyez l’après-victoire.',
    'You study the enemy, build your position, and strike when the balance turns. Your patience is a weapon.':
        'Vous étudiez l’ennemi, consolidez votre position et frappez au bon moment. Votre patience est une arme.',
    'You turn uncertain beginnings into lasting alliances. People follow you because you make room for them.':
        'Vous transformez des débuts incertains en alliances durables. On vous suit parce que vous faites une place aux autres.',
    'You are hard to bait. You conserve strength, survive pressure, and trust that timing can beat spectacle.':
        'Vous ne tombez pas facilement dans les pièges. Vous ménagez vos forces et savez que le bon moment vaut mieux qu’un coup d’éclat.',
  },
  'ar': {
    'Home': 'الرئيسية',
    'Dilemma': 'المعضلة',
    'Wrapped': 'النتيجة',
    'Language': 'اللغة',
    'Choose the language for the whole app': 'اختر لغة التطبيق بالكامل',
    'HANNIBAL / YOUR LEGACY': 'حنبعل / إرثك',
    'History is decided\none choice at a time.':
        'يُصنع التاريخ\nبقرار واحد كل مرة.',
    'Command the campaign. Then discover the ancient leader inside your decisions.':
        'قد الحملة، ثم اكتشف القائد القديم الذي تكشفه قراراتك.',
    '01 / PLAY': '01 / العب',
    'Hannibal’s\nDilemma': 'معضلة\nحنبعل',
    'Swipe through real turning points. See the price of every move.':
        'اتخذ قرارات عند منعطفات تاريخية حقيقية، واكتشف ثمن كل خطوة.',
    '7 HISTORICAL DECISIONS · NEW ON REPLAY':
        '٧ قرارات تاريخية · جديدة عند الإعادة',
    'CAMPAIGN COMPLETE': 'اكتملت الحملة',
    'CONTINUE {count} OF {total}': 'تابع: {count} من {total}',
    '02 / DISCOVER': '02 / اكتشف',
    'Hannibal\nWrapped': 'شخصيتك\nالتاريخية',
    'Seven fresh choices each run. One ancient alter ego. A result worth sharing.':
        'سبعة اختيارات جديدة كل مرة، وشخصية تاريخية تشبهك ونتيجة تستحق المشاركة.',
    'YOUR CAMPAIGN CAN SHAPE THE RESULT': 'حملتك قد تؤثر في النتيجة',
    '{count} CAMPAIGN CHOICES INCLUDED': 'احتُسب {count} من قرارات الحملة',
    'The choices are yours. The historical facts stay true.':
        'القرارات لك، أما الحقائق التاريخية فتبقى كما هي.',
    'HANNIBAL’S DILEMMA': 'معضلة حنبعل',
    'THE DECISION IS YOURS': 'القرار قرارك',
    'SWIPE THE CARD OR TAP A CHOICE': 'اسحب البطاقة أو اضغط أحد الخيارين',
    'LEFT': 'يسار',
    'RIGHT': 'يمين',
    'YOU CHOSE HANNIBAL’S MOVE': 'اخترت قرار حنبعل',
    'A DIFFERENT TIMELINE': 'مسار تاريخي بديل',
    'RISK': 'المخاطرة',
    'SURPRISE': 'المفاجأة',
    'ARMY': 'الجيش',
    'Game stats illustrate trade-offs; they are not historical measurements.':
        'تعرض أرقام اللعبة آثار الخيارات، وليست قياسات تاريخية.',
    'THE CONSEQUENCE': 'النتيجة',
    'AI FIELD NOTE': 'ملاحظة من الذكاء الاصطناعي',
    'CAMPAIGN NOTE': 'ملاحظة الحملة',
    'WHAT HANNIBAL DID': 'ما فعله حنبعل',
    'Next decision': 'القرار التالي',
    'Finish campaign': 'إنهاء الحملة',
    'THE CAMPAIGN IS COMPLETE': 'اكتملت الحملة',
    'You shaped\nthe war.': 'لقد غيّرت\nمسار الحرب.',
    'Your decisions now influence your Hannibal Wrapped result. Seven quick questions reveal your ancient alter ego.':
        'تؤثر قراراتك الآن في نتيجتك. سبعة أسئلة سريعة تكشف شخصيتك التاريخية.',
    'History remembers Hannibal’s choices. Wrapped remembers yours.':
        'يتذكر التاريخ قرارات حنبعل، وتتذكر النتيجة قراراتك.',
    'Discover your alter ego': 'اكتشف شخصيتك التاريخية',
    'Replay the campaign': 'أعد الحملة',
    'HANNIBAL WRAPPED': 'شخصيتك التاريخية',
    'YOUR RESULT': 'نتيجتك',
    'YOUR INSTINCTS, REVEALED': 'هكذا تتصرف حقاً',
    'Choose what you would actually do.': 'اختر ما كنت ستفعله حقاً.',
    '{count} Dilemma decisions will shape your match too.':
        'ستؤثر {count} من قرارات المعضلة في شخصيتك أيضاً.',
    'NO WRONG ANSWERS. JUST YOUR STORY.': 'لا إجابات خاطئة، إنها قصتك.',
    'THE VERDICT IS IN': 'ظهرت النتيجة',
    'Share to Instagram Story': 'شارك في قصة إنستغرام',
    'Preparing your Story…': 'جارٍ تجهيز قصتك…',
    'Instagram opened. You choose whether to post your Story.':
        'فُتح إنستغرام. أنت من يقرر نشر القصة أو إلغاءها.',
    'Instagram is not installed. Install it to share your Story.':
        'إنستغرام غير مثبّت. ثبّته لمشاركة قصتك.',
    'Instagram Stories is available on Android only.':
        'مشاركة قصة إنستغرام متاحة على أندرويد فقط.',
    'Could not open Instagram Stories. Please try again.':
        'تعذّر فتح قصص إنستغرام. حاول مرة أخرى.',
    'Replay Dilemma': 'أعد المعضلة',
    'Play Dilemma': 'العب المعضلة',
    'Retake the quiz': 'أعد الاختبار',
    'YOU ARE': 'أنت تشبه',
    'STRATEGIC': 'استراتيجي',
    'AUDACIOUS': 'جريء',
    'DIPLOMATIC': 'دبلوماسي',
    'RESOLUTE': 'حازم',
    'YOUR FATAL FLAW': 'نقطة ضعفك',
    '{count} campaign choices shaped this result':
        'ساهم {count} من قرارات الحملة في هذه النتيجة',
    'Back': 'رجوع',
    'Hannibal Barca': 'حنبعل برقا',
    'Scipio Africanus': 'سكيبيو الإفريقي',
    'Elissa (Dido)': 'عليسة (ديدو)',
    'Fabius Maximus': 'فابيوس ماكسيموس',
    'THE IMPOSSIBLE ROUTE': 'الطريق المستحيل',
    'THE PATIENT COUNTERSTRIKE': 'الرد الصبور',
    'THE CITY BUILDER': 'بانية المدينة',
    'THE LONG GAME': 'الرهان الطويل',
    'You win battles faster than you finish wars.':
        'تربح المعارك أسرع مما تنهي الحروب.',
    'You can spend so long reading the board that others move first.':
        'قد تطيل دراسة الموقف حتى يسبقك الآخرون إلى التحرك.',
    'You carry the weight of every alliance yourself.':
        'تحمل عبء كل تحالف وحدك.',
    'Your patience may look like hesitation when the moment is real.':
        'قد يبدو صبرك تردداً حين تحين اللحظة الحاسمة.',
    'You see a route where everyone else sees a wall. Your bold ideas work best when you plan what happens after the victory.':
        'ترى طريقاً حيث يرى الآخرون جداراً. تنجح أفكارك الجريئة أكثر عندما تخطط لما بعد النصر.',
    'You study the enemy, build your position, and strike when the balance turns. Your patience is a weapon.':
        'تدرس خصمك، وتقوّي موقعك، ثم تضرب حين تميل الكفة. صبرك سلاحك.',
    'You turn uncertain beginnings into lasting alliances. People follow you because you make room for them.':
        'تحوّل البدايات الصعبة إلى تحالفات دائمة. يتبعك الناس لأنك تفسح لهم مكاناً.',
    'You are hard to bait. You conserve strength, survive pressure, and trust that timing can beat spectacle.':
        'يصعب استدراجك. تحافظ على قوتك تحت الضغط، وتعرف أن التوقيت الجيد أقوى من الاستعراض.',
  },
};
