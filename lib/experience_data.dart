import 'dart:math';

import 'package:flutter/foundation.dart';

/// The four traits used by both experiences. Values here are game points.
class Traits {
  const Traits({
    this.strategy = 0,
    this.audacity = 0,
    this.diplomacy = 0,
    this.resolve = 0,
  });

  final int strategy;
  final int audacity;
  final int diplomacy;
  final int resolve;

  Traits operator +(Traits other) => Traits(
    strategy: strategy + other.strategy,
    audacity: audacity + other.audacity,
    diplomacy: diplomacy + other.diplomacy,
    resolve: resolve + other.resolve,
  );
}

class DecisionOption {
  const DecisionOption({
    required this.label,
    required this.outcomeTitle,
    required this.outcome,
    required this.risk,
    required this.surprise,
    required this.army,
    required this.traits,
  });

  final String label;
  final String outcomeTitle;
  final String outcome;
  final int risk;
  final int surprise;
  final int army;
  final Traits traits;
}

class Dilemma {
  const Dilemma({
    required this.year,
    required this.place,
    required this.title,
    required this.setup,
    required this.left,
    required this.right,
    required this.actualRight,
    required this.historicalTruth,
  });

  final String year;
  final String place;
  final String title;
  final String setup;
  final DecisionOption left;
  final DecisionOption right;
  final bool actualRight;
  final String historicalTruth;
}

// The outcome of an alternate choice is explicitly a game simulation.
const dilemmas = <Dilemma>[
  Dilemma(
    year: '218 BC',
    place: 'THE ALPS',
    title: 'A road no one expects',
    setup:
        'Rome watches the familiar routes into Italy. Your army faces mountain passes, cold, and dwindling supplies.',
    left: DecisionOption(
      label: 'Find a safer route',
      outcomeTitle: 'You avoid the mountains.',
      outcome:
          'In this imagined campaign, more soldiers may arrive together, but Rome gets more time to prepare.',
      risk: -20,
      surprise: -35,
      army: 20,
      traits: Traits(strategy: 4, audacity: -9, diplomacy: 2, resolve: 3),
    ),
    right: DecisionOption(
      label: 'Cross the Alps',
      outcomeTitle: 'You cross the Alps.',
      outcome:
          'The army pays for the crossing, but your arrival in Italy shocks Rome.',
      risk: 35,
      surprise: 50,
      army: -20,
      traits: Traits(strategy: 7, audacity: 12, resolve: 9),
    ),
    actualRight: true,
    historicalTruth:
        'Hannibal crossed the Alps into Italy in 218 BC with an army that included elephants. The journey cost him many troops.',
  ),
  Dilemma(
    year: '218 BC',
    place: 'THE TREBIA',
    title: 'The river is freezing',
    setup:
        'Roman troops are eager for battle. A cold river lies between them and your prepared position.',
    left: DecisionOption(
      label: 'Wait for warmer ground',
      outcomeTitle: 'You delay the battle.',
      outcome:
          'In this imagined campaign, your troops recover, but the Romans keep control of when to engage.',
      risk: -15,
      surprise: -20,
      army: 10,
      traits: Traits(strategy: 5, audacity: -6, resolve: 3),
    ),
    right: DecisionOption(
      label: 'Lure them across',
      outcomeTitle: 'You spring the trap.',
      outcome:
          'Cold and disarray weaken the advancing Romans before your concealed force strikes.',
      risk: 20,
      surprise: 40,
      army: -5,
      traits: Traits(strategy: 11, audacity: 8, resolve: 5),
    ),
    actualRight: true,
    historicalTruth:
        'At the Trebia in 218 BC, Hannibal drew Roman forces across the cold river and used a hidden force under his brother Mago.',
  ),
  Dilemma(
    year: '217 BC',
    place: 'LAKE TRASIMENE',
    title: 'The road beside the lake',
    setup:
        'A Roman army follows you through narrow ground. Hills rise on one side; the lake closes the other.',
    left: DecisionOption(
      label: 'Meet them in open battle',
      outcomeTitle: 'You form a battle line.',
      outcome:
          'In this imagined campaign, the Romans can see you coming and the terrain loses its advantage.',
      risk: 5,
      surprise: -35,
      army: -10,
      traits: Traits(strategy: -6, audacity: 5, resolve: 4),
    ),
    right: DecisionOption(
      label: 'Hide along the hills',
      outcomeTitle: 'You wait in silence.',
      outcome: 'The confined route turns a Roman march into an ambush.',
      risk: 20,
      surprise: 45,
      army: 5,
      traits: Traits(strategy: 11, audacity: 7, resolve: 4),
    ),
    actualRight: true,
    historicalTruth:
        'Hannibal ambushed the Roman army near Lake Trasimene in 217 BC, using the terrain to conceal his troops.',
  ),
  Dilemma(
    year: '216 BC',
    place: 'CANNAE',
    title: 'They outnumber you',
    setup:
        'The Roman infantry presses toward your center. Your wings have room to move.',
    left: DecisionOption(
      label: 'Hold a rigid front',
      outcomeTitle: 'You stand firm.',
      outcome:
          'In this imagined campaign, your line takes the blow directly while the chance to surround Rome fades.',
      risk: 10,
      surprise: -20,
      army: -25,
      traits: Traits(strategy: -7, audacity: -2, resolve: 8),
    ),
    right: DecisionOption(
      label: 'Yield, then encircle',
      outcomeTitle: 'The center bends.',
      outcome: 'The Romans push inward; your stronger wings close around them.',
      risk: 30,
      surprise: 45,
      army: 10,
      traits: Traits(strategy: 13, audacity: 10, resolve: 6),
    ),
    actualRight: true,
    historicalTruth:
        'At Cannae in 216 BC, Hannibal used a flexible center and enveloping wings to defeat a larger Roman army.',
  ),
  Dilemma(
    year: '216 BC',
    place: 'AFTER CANNAE',
    title: 'Rome still stands',
    setup:
        'You have won a huge battle. The Roman state is wounded, but its capital is fortified.',
    left: DecisionOption(
      label: 'March on Rome now',
      outcomeTitle: 'You turn toward Rome.',
      outcome:
          'In this imagined campaign, speed may spread panic, but a siege would demand supplies and time.',
      risk: 45,
      surprise: 25,
      army: -25,
      traits: Traits(strategy: -4, audacity: 13, resolve: 8),
    ),
    right: DecisionOption(
      label: 'Win Rome’s allies',
      outcomeTitle: 'You build a coalition.',
      outcome:
          'Cities begin weighing a change of allegiance, though Rome still has deep reserves.',
      risk: -10,
      surprise: 5,
      army: 10,
      traits: Traits(strategy: 9, audacity: 1, diplomacy: 12, resolve: 5),
    ),
    actualRight: true,
    historicalTruth:
        'Hannibal did not march directly on Rome after Cannae. Several of Rome’s Italian allies, including Capua, joined him.',
  ),
  Dilemma(
    year: '211 BC',
    place: 'CAPUA',
    title: 'An ally under siege',
    setup:
        'Rome threatens Capua, one of your most important allies. You need to pull Roman troops away.',
    left: DecisionOption(
      label: 'Threaten Rome itself',
      outcomeTitle: 'You march toward Rome.',
      outcome:
          'The move alarms the capital, but the Roman siege of Capua continues.',
      risk: 30,
      surprise: 35,
      army: -10,
      traits: Traits(strategy: 8, audacity: 10, diplomacy: 3, resolve: 7),
    ),
    right: DecisionOption(
      label: 'Attack the siege head-on',
      outcomeTitle: 'You rush to Capua.',
      outcome:
          'In this imagined campaign, you fight where Rome is strongest and risk more of your army.',
      risk: 35,
      surprise: -15,
      army: -20,
      traits: Traits(strategy: -4, audacity: 6, diplomacy: 2, resolve: 10),
    ),
    actualRight: false,
    historicalTruth:
        'In 211 BC, Hannibal marched toward Rome hoping to draw Roman forces away from Capua. The siege held, and Capua fell.',
  ),
  Dilemma(
    year: '202 BC',
    place: 'ZAMA',
    title: 'The final field',
    setup:
        'Scipio has brought the war to Africa. Your forces gather for a decisive confrontation.',
    left: DecisionOption(
      label: 'Delay the battle',
      outcomeTitle: 'You buy time.',
      outcome:
          'In this imagined campaign, delay may help you regroup, but Scipio keeps the initiative.',
      risk: -15,
      surprise: -10,
      army: 10,
      traits: Traits(strategy: 5, audacity: -7, diplomacy: 5, resolve: 3),
    ),
    right: DecisionOption(
      label: 'Face Scipio',
      outcomeTitle: 'You accept the battle.',
      outcome:
          'A decisive defeat ends your campaign despite years of victories in Italy.',
      risk: 35,
      surprise: 0,
      army: -35,
      traits: Traits(strategy: 2, audacity: 8, resolve: 11),
    ),
    actualRight: true,
    historicalTruth:
        'Hannibal fought Scipio Africanus at Zama in 202 BC and lost. The defeat led to a peace treaty in 201 BC.',
  ),
];

// A second chapter keeps replays from following only Hannibal's road in Italy.
// Facts are grounded in Polybius, Histories III, and Livy, Books XXX and XXXIII.
const otherDilemmas = <Dilemma>[
  Dilemma(
    year: '221 BC',
    place: 'IBERIA',
    title: 'A command falls vacant',
    setup:
        'Hasdrubal is dead. The army in Iberia wants you to lead it, but the frontier is still unstable.',
    left: DecisionOption(
      label: 'Accept command',
      outcomeTitle: 'You take the army.',
      outcome: 'You begin consolidating Carthaginian power in Iberia.',
      risk: 20,
      surprise: 5,
      army: 5,
      traits: Traits(strategy: 7, audacity: 7, resolve: 8),
    ),
    right: DecisionOption(
      label: 'Refuse the command',
      outcomeTitle: 'You step aside.',
      outcome: 'In this imagined path, someone else directs the Iberian army.',
      risk: -10,
      surprise: -5,
      army: 0,
      traits: Traits(audacity: -8, diplomacy: 4),
    ),
    actualRight: false,
    historicalTruth:
        'After Hasdrubal was killed in 221 BC, the army in Iberia chose Hannibal as its commander; Carthage confirmed the appointment.',
  ),
  Dilemma(
    year: '220 BC',
    place: 'THE TAGUS',
    title: 'The river narrows their numbers',
    setup:
        'Opposing Iberian forces approach in great numbers. The Tagus River limits where they can cross.',
    left: DecisionOption(
      label: 'Fight on open ground',
      outcomeTitle: 'You leave the river.',
      outcome:
          'In this imagined fight, the enemy can use more of its numbers at once.',
      risk: 30,
      surprise: -20,
      army: -15,
      traits: Traits(audacity: 6, strategy: -6),
    ),
    right: DecisionOption(
      label: 'Hold the river crossings',
      outcomeTitle: 'The river becomes your ally.',
      outcome:
          'The crossing breaks up the attack before your troops counterstrike.',
      risk: 15,
      surprise: 25,
      army: 5,
      traits: Traits(strategy: 11, resolve: 6),
    ),
    actualRight: true,
    historicalTruth:
        'In 220 BC, Hannibal defeated Iberian opponents at the Tagus by using the river crossing to blunt their larger force.',
  ),
  Dilemma(
    year: '219 BC',
    place: 'SAGUNTUM',
    title: 'A city on your flank',
    setup:
        'Saguntum is allied with Rome. Leaving it behind could threaten your plans in Iberia.',
    left: DecisionOption(
      label: 'Besiege Saguntum',
      outcomeTitle: 'You commit to the siege.',
      outcome: 'The city falls, and the clash with Rome moves closer.',
      risk: 35,
      surprise: 5,
      army: -10,
      traits: Traits(strategy: 7, audacity: 9, resolve: 9),
    ),
    right: DecisionOption(
      label: 'Leave it alone',
      outcomeTitle: 'You bypass the city.',
      outcome:
          'In this imagined campaign, a Roman ally remains behind your lines.',
      risk: -10,
      surprise: 10,
      army: 5,
      traits: Traits(diplomacy: 7, audacity: -5),
    ),
    actualRight: false,
    historicalTruth:
        'Hannibal besieged and captured Saguntum in 219 BC. The attack helped trigger the Second Punic War.',
  ),
  Dilemma(
    year: '218 BC',
    place: 'GALLIC ALLIES',
    title: 'You need friends ahead',
    setup:
        'The route toward Italy passes through Celtic territory. Local support could change the entire campaign.',
    left: DecisionOption(
      label: 'Send envoys and promises',
      outcomeTitle: 'You seek allies.',
      outcome: 'Your envoys try to win support before the army arrives.',
      risk: 10,
      surprise: 15,
      army: 10,
      traits: Traits(strategy: 7, diplomacy: 11),
    ),
    right: DecisionOption(
      label: 'March without diplomacy',
      outcomeTitle: 'You rely on force.',
      outcome:
          'In this imagined march, you risk fighting every group along the route.',
      risk: 30,
      surprise: 5,
      army: -20,
      traits: Traits(audacity: 7, diplomacy: -8),
    ),
    actualRight: false,
    historicalTruth:
        'Before marching into Italy in 218 BC, Hannibal sent messages to Celtic leaders and counted on their cooperation.',
  ),
  Dilemma(
    year: '218 BC',
    place: 'THE RHONE',
    title: 'Elephants meet a river',
    setup:
        'Your army must cross the Rhone. The elephants cannot simply be left behind.',
    left: DecisionOption(
      label: 'Leave the elephants',
      outcomeTitle: 'You move faster.',
      outcome:
          'In this imagined march, you lose a powerful symbol and battlefield asset.',
      risk: -10,
      surprise: -20,
      army: 5,
      traits: Traits(strategy: 4, audacity: -5),
    ),
    right: DecisionOption(
      label: 'Build crossing rafts',
      outcomeTitle: 'The elephants cross.',
      outcome:
          'The crossing takes effort, but the animals continue toward the Alps.',
      risk: 25,
      surprise: 25,
      army: -5,
      traits: Traits(strategy: 8, audacity: 8, resolve: 7),
    ),
    actualRight: true,
    historicalTruth:
        'Hannibal crossed the Rhone in 218 BC and used rafts to transport his elephants.',
  ),
  Dilemma(
    year: '203 BC',
    place: 'RETURN TO AFRICA',
    title: 'Carthage calls you home',
    setup:
        'Scipio threatens Carthage in North Africa. Your long campaign in Italy is no longer the only front.',
    left: DecisionOption(
      label: 'Stay in Italy',
      outcomeTitle: 'You remain abroad.',
      outcome:
          'In this imagined path, Carthage faces Scipio without your returning army.',
      risk: 35,
      surprise: 0,
      army: 5,
      traits: Traits(audacity: 8, diplomacy: -5),
    ),
    right: DecisionOption(
      label: 'Return to defend Carthage',
      outcomeTitle: 'You sail home.',
      outcome:
          'Your Italian campaign ends as you prepare to face Scipio in Africa.',
      risk: 20,
      surprise: -5,
      army: -5,
      traits: Traits(strategy: 7, resolve: 10),
    ),
    actualRight: true,
    historicalTruth:
        'Carthage recalled Hannibal from Italy in 203 BC after Scipio carried the war into Africa.',
  ),
  Dilemma(
    year: '196 BC',
    place: 'CARTHAGE',
    title: 'The battlefield is now politics',
    setup:
        'The war is over. As a Carthaginian magistrate, you face entrenched political power and strained finances.',
    left: DecisionOption(
      label: 'Push financial reforms',
      outcomeTitle: 'You challenge the establishment.',
      outcome: 'You work to repair Carthage from inside its institutions.',
      risk: 20,
      surprise: 10,
      army: 0,
      traits: Traits(strategy: 9, diplomacy: 5, resolve: 9),
    ),
    right: DecisionOption(
      label: 'Avoid the conflict',
      outcomeTitle: 'You keep the peace.',
      outcome:
          'In this imagined career, the old system remains less challenged.',
      risk: -15,
      surprise: -5,
      army: 0,
      traits: Traits(diplomacy: 6, resolve: -6),
    ),
    actualRight: false,
    historicalTruth:
        'Hannibal became a suffete, a senior Carthaginian magistrate, in 196 BC and pursued reforms to public finances and political power.',
  ),
];

class QuizOption {
  const QuizOption(this.text, this.traits);
  final String text;
  final Traits traits;
}

class QuizQuestion {
  const QuizQuestion(this.prompt, this.options);
  final String prompt;
  final List<QuizOption> options;
}

const quizQuestions = <QuizQuestion>[
  QuizQuestion('You win a huge battle. What now?', [
    QuizOption('Press the enemy immediately', Traits(audacity: 11, resolve: 7)),
    QuizOption('Build alliances first', Traits(strategy: 8, diplomacy: 11)),
    QuizOption(
      'Rebuild your forces',
      Traits(strategy: 8, audacity: -6, resolve: 5),
    ),
    QuizOption('Offer terms', Traits(diplomacy: 12, resolve: -2)),
  ]),
  QuizQuestion('Scouts find a dangerous mountain pass.', [
    QuizOption('Take it for surprise', Traits(audacity: 12, strategy: 5)),
    QuizOption('Map every risk first', Traits(strategy: 11, audacity: -4)),
    QuizOption('Secure supplies, then move', Traits(strategy: 8, resolve: 7)),
    QuizOption('Find a local guide', Traits(diplomacy: 9, strategy: 5)),
  ]),
  QuizQuestion('A rival city offers an alliance.', [
    QuizOption('Accept and move fast', Traits(audacity: 7, diplomacy: 8)),
    QuizOption('Negotiate guarantees', Traits(strategy: 7, diplomacy: 11)),
    QuizOption('Watch them before trusting', Traits(strategy: 9, audacity: -5)),
    QuizOption('Turn down the offer', Traits(resolve: 8, diplomacy: -7)),
  ]),
  QuizQuestion('Your army is losing confidence.', [
    QuizOption('Lead from the front', Traits(audacity: 9, resolve: 11)),
    QuizOption('Listen to your officers', Traits(diplomacy: 9, strategy: 6)),
    QuizOption('Reorganize the plan', Traits(strategy: 11, resolve: 6)),
    QuizOption('Give them time to rest', Traits(diplomacy: 5, resolve: 7)),
  ]),
  QuizQuestion('A trusted adviser challenges your plan.', [
    QuizOption(
      'Change course if they are right',
      Traits(strategy: 9, diplomacy: 8),
    ),
    QuizOption(
      'Debate until the best idea wins',
      Traits(strategy: 8, resolve: 5),
    ),
    QuizOption('Trust your instinct', Traits(audacity: 9, resolve: 7)),
    QuizOption('Stay the course', Traits(resolve: 11, diplomacy: -4)),
  ]),
  QuizQuestion('A city offers to surrender peacefully.', [
    QuizOption('Offer generous terms', Traits(diplomacy: 12, strategy: 4)),
    QuizOption(
      'Ask for supplies and safe passage',
      Traits(strategy: 9, diplomacy: 5),
    ),
    QuizOption('Demand total control', Traits(resolve: 9, diplomacy: -8)),
    QuizOption('Ignore it and keep moving', Traits(audacity: 7, strategy: -3)),
  ]),
  QuizQuestion('One campaign remains. Your priority?', [
    QuizOption('An unexpected strike', Traits(audacity: 12, strategy: 4)),
    QuizOption('A flawless battle plan', Traits(strategy: 12, resolve: 5)),
    QuizOption('Protect every supply line', Traits(strategy: 8, audacity: -6)),
    QuizOption(
      'A peace your allies can keep',
      Traits(diplomacy: 12, resolve: 6),
    ),
  ]),
];

const otherQuizQuestions = <QuizQuestion>[
  QuizQuestion('A new commander inherits a divided army. Your first move?', [
    QuizOption('Set one bold objective', Traits(audacity: 10, resolve: 7)),
    QuizOption(
      'Learn what each unit needs',
      Traits(diplomacy: 10, strategy: 5),
    ),
    QuizOption('Fix supplies and training', Traits(strategy: 11, resolve: 5)),
    QuizOption(
      'Test the officers in small missions',
      Traits(strategy: 7, audacity: 5),
    ),
  ]),
  QuizQuestion('A larger force approaches across a river. What do you use?', [
    QuizOption('The narrow crossing', Traits(strategy: 12, resolve: 5)),
    QuizOption('A sudden attack upstream', Traits(audacity: 12, strategy: 3)),
    QuizOption('An offer to negotiate', Traits(diplomacy: 12)),
    QuizOption('Time to build defenses', Traits(strategy: 7, resolve: 9)),
  ]),
  QuizQuestion('A powerful neighbor backs a city in your path.', [
    QuizOption(
      'Confront it despite the risk',
      Traits(audacity: 10, resolve: 8),
    ),
    QuizOption(
      'Seek a diplomatic settlement',
      Traits(diplomacy: 12, strategy: 5),
    ),
    QuizOption('Secure other routes first', Traits(strategy: 11, audacity: -4)),
    QuizOption(
      'Wait until your army is ready',
      Traits(resolve: 8, strategy: 6),
    ),
  ]),
  QuizQuestion(
    'Your route crosses another people’s territory. How do you proceed?',
    [
      QuizOption(
        'Offer them a real alliance',
        Traits(diplomacy: 12, strategy: 5),
      ),
      QuizOption('Scout a path around them', Traits(strategy: 11)),
      QuizOption('Move before they react', Traits(audacity: 12, resolve: 4)),
      QuizOption('Hold position and talk', Traits(diplomacy: 8, resolve: 6)),
    ],
  ),
  QuizQuestion('A river blocks your army and its equipment.', [
    QuizOption('Engineer a crossing', Traits(strategy: 10, resolve: 8)),
    QuizOption('Travel light and leave gear', Traits(audacity: 7, strategy: 5)),
    QuizOption('Ask locals for help', Traits(diplomacy: 10, strategy: 5)),
    QuizOption('Wait for safer conditions', Traits(strategy: 7, audacity: -6)),
  ]),
  QuizQuestion('Your home city calls while you lead a distant campaign.', [
    QuizOption('Return immediately', Traits(resolve: 9, diplomacy: 7)),
    QuizOption('Send aid, keep the campaign', Traits(strategy: 7, audacity: 8)),
    QuizOption('Negotiate time to regroup', Traits(diplomacy: 11, strategy: 5)),
    QuizOption('Finish one last offensive', Traits(audacity: 11, resolve: 5)),
  ]),
  QuizQuestion(
    'The war ends, but your city is struggling. Where do you lead?',
    [
      QuizOption('Reform the treasury', Traits(strategy: 9, resolve: 8)),
      QuizOption('Rebuild old alliances', Traits(diplomacy: 12, strategy: 4)),
      QuizOption(
        'Prepare for the next threat',
        Traits(resolve: 9, audacity: 5),
      ),
      QuizOption(
        'Step aside for new leaders',
        Traits(diplomacy: 7, resolve: -5),
      ),
    ],
  ),
];

class AncientMatch {
  const AncientMatch({
    required this.name,
    required this.subtitle,
    required this.symbol,
    required this.profile,
    required this.fatalFlaw,
    required this.fallbackDescription,
  });

  final String name;
  final String subtitle;
  final String symbol;
  final Traits profile;
  final String fatalFlaw;
  final String fallbackDescription;
}

const ancientMatches = <AncientMatch>[
  AncientMatch(
    name: 'Hannibal Barca',
    subtitle: 'THE IMPOSSIBLE ROUTE',
    symbol: '🐘',
    profile: Traits(strategy: 88, audacity: 91, diplomacy: 60, resolve: 84),
    fatalFlaw: 'You win battles faster than you finish wars.',
    fallbackDescription:
        'You see a route where everyone else sees a wall. Your bold ideas work best when you plan what happens after the victory.',
  ),
  AncientMatch(
    name: 'Scipio Africanus',
    subtitle: 'THE PATIENT COUNTERSTRIKE',
    symbol: '🦅',
    profile: Traits(strategy: 90, audacity: 65, diplomacy: 72, resolve: 84),
    fatalFlaw:
        'You can spend so long reading the board that others move first.',
    fallbackDescription:
        'You study the enemy, build your position, and strike when the balance turns. Your patience is a weapon.',
  ),
  AncientMatch(
    name: 'Elissa (Dido)',
    subtitle: 'THE CITY BUILDER',
    symbol: '👑',
    profile: Traits(strategy: 72, audacity: 62, diplomacy: 93, resolve: 79),
    fatalFlaw: 'You carry the weight of every alliance yourself.',
    fallbackDescription:
        'You turn uncertain beginnings into lasting alliances. People follow you because you make room for them.',
  ),
  AncientMatch(
    name: 'Fabius Maximus',
    subtitle: 'THE LONG GAME',
    symbol: '🛡️',
    profile: Traits(strategy: 91, audacity: 27, diplomacy: 53, resolve: 91),
    fatalFlaw:
        'Your patience may look like hesitation when the moment is real.',
    fallbackDescription:
        'You are hard to bait. You conserve strength, survive pressure, and trust that timing can beat spectacle.',
  ),
];

class WrappedResult {
  const WrappedResult({
    required this.match,
    required this.percentage,
    required this.strategy,
    required this.audacity,
    required this.diplomacy,
    required this.resolve,
    required this.decisionCount,
  });

  final AncientMatch match;
  final int percentage;
  final int strategy;
  final int audacity;
  final int diplomacy;
  final int resolve;
  final int decisionCount;

  String get shareText =>
      'My Hannibal Wrapped: $percentage% ${match.name.toUpperCase()}\n'
      'Strategic $strategy% · Audacious $audacity% · '
      'Diplomatic $diplomacy% · Resolute $resolve%\n'
      'Fatal flaw: ${match.fatalFlaw}\n#HannibalWrapped';
}

class GameSession extends ChangeNotifier {
  GameSession({Random? random}) : _random = random ?? Random() {
    _startDilemmaRun();
    _startQuizRun();
  }

  static const questionsPerRun = 7;
  final Random _random;
  final Map<int, bool> _decisions = {};
  final Map<int, int> _answers = {};
  final List<Dilemma> _italyDeck = [];
  final List<Dilemma> _otherDeck = [];
  final List<QuizQuestion> _quizDeck = [];
  late List<Dilemma> currentDilemmas;
  late List<QuizQuestion> currentQuizQuestions;
  int _dilemmaRuns = 0;
  int _quizRuns = 0;

  void _startDilemmaRun() {
    final italyCount = _dilemmaRuns.isEven ? 4 : 3;
    final otherCount = questionsPerRun - italyCount;
    if (_italyDeck.length < italyCount || _otherDeck.length < otherCount) {
      final previous = _dilemmaRuns == 0
          ? <Dilemma>{}
          : currentDilemmas.toSet();
      _italyDeck
        ..clear()
        ..addAll(dilemmas.where((item) => !previous.contains(item)));
      _otherDeck
        ..clear()
        ..addAll(otherDilemmas.where((item) => !previous.contains(item)));
      _italyDeck.shuffle(_random);
      _otherDeck.shuffle(_random);
    }
    currentDilemmas = [
      ..._italyDeck.take(italyCount),
      ..._otherDeck.take(otherCount),
    ]..shuffle(_random);
    _italyDeck.removeRange(0, italyCount);
    _otherDeck.removeRange(0, otherCount);
    _dilemmaRuns++;
  }

  void _startQuizRun() {
    if (_quizDeck.length < questionsPerRun) {
      final previous = _quizRuns == 0
          ? <QuizQuestion>{}
          : currentQuizQuestions.toSet();
      _quizDeck
        ..clear()
        ..addAll(quizQuestions.where((item) => !previous.contains(item)))
        ..addAll(otherQuizQuestions.where((item) => !previous.contains(item)));
      _quizDeck.shuffle(_random);
    }
    currentQuizQuestions = _quizDeck.take(questionsPerRun).toList();
    _quizDeck.removeRange(0, questionsPerRun);
    _quizRuns++;
  }

  int get decisionCount => _decisions.length;
  int get answerCount => _answers.length;
  bool get quizComplete => _answers.length == currentQuizQuestions.length;

  List<String> get decisionSummary => [
    for (final entry in _decisions.entries)
      '${currentDilemmas[entry.key].place}: '
          '${(entry.value ? currentDilemmas[entry.key].right : currentDilemmas[entry.key].left).label}',
  ];

  int get nextDecision {
    for (var i = 0; i < currentDilemmas.length; i++) {
      if (!_decisions.containsKey(i)) return i;
    }
    return currentDilemmas.length;
  }

  void choose(int scenarioIndex, bool right) {
    if (scenarioIndex < 0 || scenarioIndex >= currentDilemmas.length) return;
    _decisions[scenarioIndex] = right;
    notifyListeners();
  }

  void answer(int questionIndex, int optionIndex) {
    if (questionIndex < 0 || questionIndex >= currentQuizQuestions.length) {
      return;
    }
    if (optionIndex < 0 ||
        optionIndex >= currentQuizQuestions[questionIndex].options.length) {
      return;
    }
    _answers[questionIndex] = optionIndex;
    notifyListeners();
  }

  void resetDilemmas() {
    _decisions.clear();
    _startDilemmaRun();
    notifyListeners();
  }

  void resetQuiz() {
    _answers.clear();
    _startQuizRun();
    notifyListeners();
  }

  WrappedResult get result {
    var points = const Traits(
      strategy: 50,
      audacity: 50,
      diplomacy: 50,
      resolve: 50,
    );
    for (final entry in _decisions.entries) {
      final dilemma = currentDilemmas[entry.key];
      points += (entry.value ? dilemma.right : dilemma.left).traits;
    }
    for (final entry in _answers.entries) {
      points += currentQuizQuestions[entry.key].options[entry.value].traits;
    }

    int percent(int value) => value.clamp(8, 98);
    final strategy = percent(points.strategy);
    final audacity = percent(points.audacity);
    final diplomacy = percent(points.diplomacy);
    final resolve = percent(points.resolve);

    AncientMatch best = ancientMatches.first;
    var bestDistance = 1 << 30;
    for (final candidate in ancientMatches) {
      final distance =
          (strategy - candidate.profile.strategy).abs() +
          (audacity - candidate.profile.audacity).abs() +
          (diplomacy - candidate.profile.diplomacy).abs() +
          (resolve - candidate.profile.resolve).abs();
      if (distance < bestDistance) {
        best = candidate;
        bestDistance = distance;
      }
    }

    final matchPercent = max(58, min(98, 100 - (bestDistance / 4).round()));
    return WrappedResult(
      match: best,
      percentage: matchPercent,
      strategy: strategy,
      audacity: audacity,
      diplomacy: diplomacy,
      resolve: resolve,
      decisionCount: decisionCount,
    );
  }
}
