import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hannibal/experience_data.dart';
import 'package:hannibal/experience_localizations.dart';
import 'package:hannibal/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Wrapped exports a 1080 × 1920 PNG to the Story composer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Uint8List? sharedPng;
    const channel = MethodChannel('hannibal/instagram_story');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        expect(call.method, 'shareStory');
        sharedPng = (call.arguments as Map<Object?, Object?>)['png'] as Uint8List;
        return 'opened';
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HannibalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wrapped').last);
    await tester.pumpAndSettle();
    for (var i = 0; i < GameSession.questionsPerRun; i++) {
      final question = [...quizQuestions, ...otherQuizQuestions].firstWhere(
        (item) => find.text(item.prompt).evaluate().isNotEmpty,
      );
      final option = find.text(question.options.first.text);
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    expect(find.text('Share to Instagram Story'), findsOneWidget);
    expect(find.text('Copy result to share'), findsNothing);
    final shareButton = find.byKey(const Key('share_instagram_story'));
    await tester.ensureVisible(shareButton);
    await tester.tap(shareButton);
    await tester.pump();
    await tester.runAsync(() async {
      for (var i = 0; i < 30 && sharedPng == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    });
    await tester.pump();

    expect(sharedPng, isNotNull);
    final bytes = sharedPng!;
    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    final header = ByteData.sublistView(bytes);
    expect(header.getUint32(16), 1080);
    expect(header.getUint32(20), 1920);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the three destinations stay in one bottom navigation bar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HannibalApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.text('History is decided\none choice at a time.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Dilemma').last);
    await tester.pumpAndSettle();
    expect(find.text('THE DECISION IS YOURS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Wrapped').last);
    await tester.pumpAndSettle();
    expect(find.text('YOUR INSTINCTS, REVEALED'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(
      find.text('History is decided\none choice at a time.'),
      findsOneWidget,
    );
  });

  testWidgets('the gear changes and remembers French and Arabic', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HannibalApp());
    await tester.pumpAndSettle();

    expect(find.text('0/7 DECISIONS'), findsNothing);
    await tester.tap(find.byKey(const Key('language_settings')));
    await tester.pumpAndSettle();
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    expect(
      find.text('L’histoire se joue\nun choix à la fois.'),
      findsOneWidget,
    );
    expect(find.text('Accueil'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language_settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    final title = find.text('يُصنع التاريخ\nبقرار واحد كل مرة.');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const HannibalApp());
    await tester.pumpAndSettle();
    expect(title, findsOneWidget);
  });

  test('every scenario and quiz question has French and Arabic text', () {
    for (final dilemma in [...dilemmas, ...otherDilemmas]) {
      final strings = [
        dilemma.place,
        dilemma.title,
        dilemma.setup,
        dilemma.left.label,
        dilemma.left.outcomeTitle,
        dilemma.left.outcome,
        dilemma.right.label,
        dilemma.right.outcomeTitle,
        dilemma.right.outcome,
        dilemma.historicalTruth,
      ];
      for (final language in ['fr', 'ar']) {
        for (final source in strings) {
          expect(
            hasTranslation(language, source),
            isTrue,
            reason: 'Missing $language: $source',
          );
        }
      }
    }
    for (final question in [...quizQuestions, ...otherQuizQuestions]) {
      for (final language in ['fr', 'ar']) {
        expect(hasTranslation(language, question.prompt), isTrue);
        for (final choice in question.options) {
          expect(
            hasTranslation(language, choice.text),
            isTrue,
            reason: 'Missing $language: ${choice.text}',
          );
        }
      }
    }
  });

  testWidgets('Arabic game and Wrapped result work on a phone-sized screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'experience_language': 'ar'});
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HannibalApp());
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.byKey(const Key('language_settings'))).dx,
      greaterThan(300),
    );
    await tester.tap(find.text('المعضلة'));
    await tester.pumpAndSettle();
    final scenario = [...dilemmas, ...otherDilemmas].firstWhere(
      (item) => find.text(translated('ar', item.title)).evaluate().isNotEmpty,
    );
    final choice = find.text(translated('ar', scenario.left.label));
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    expect(
      find.text(translated('ar', scenario.historicalTruth)),
      findsOneWidget,
    );

    await tester.tap(find.text('النتيجة'));
    await tester.pumpAndSettle();
    for (var i = 0; i < GameSession.questionsPerRun; i++) {
      final question = [...quizQuestions, ...otherQuizQuestions].firstWhere(
        (item) =>
            find.text(translated('ar', item.prompt)).evaluate().isNotEmpty,
      );
      final option = find.text(translated('ar', question.options.first.text));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }
    expect(find.text('نقطة ضعفك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('French Dilemma card and historical reveal fit a phone', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'experience_language': 'fr'});
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HannibalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dilemme'));
    await tester.pumpAndSettle();
    final scenario = [...dilemmas, ...otherDilemmas].firstWhere(
      (item) => find.text(translated('fr', item.title)).evaluate().isNotEmpty,
    );
    final choice = find.text(translated('fr', scenario.left.label));
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    expect(
      find.text(translated('fr', scenario.historicalTruth)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test(
    'Dilemma replay uses different questions and includes non-Italy stories',
    () {
      final session = GameSession(random: Random(7));
      final first = session.currentDilemmas.toSet();
      expect(first.length, GameSession.questionsPerRun);
      expect(first.intersection(otherDilemmas.toSet()).length, 3);

      session.choose(0, true);
      expect(session.decisionCount, 1);
      expect(session.nextDecision, 1);
      session.resetDilemmas();

      final second = session.currentDilemmas.toSet();
      expect(first.intersection(second), isEmpty);
      expect(second.intersection(otherDilemmas.toSet()).length, 4);
      expect(session.decisionCount, 0);
      session.resetDilemmas();
      expect(second.intersection(session.currentDilemmas.toSet()), isEmpty);
      session.dispose();
    },
  );

  test('Wrapped replay changes questions and keeps deterministic scoring', () {
    final session = GameSession(random: Random(11));
    final first = session.currentQuizQuestions.toSet();
    final before = session.result;
    session.choose(0, true);
    expect(session.result.decisionCount, 1);
    expect(
      [
        session.result.strategy,
        session.result.audacity,
        session.result.diplomacy,
        session.result.resolve,
      ],
      isNot([
        before.strategy,
        before.audacity,
        before.diplomacy,
        before.resolve,
      ]),
    );

    for (var i = 0; i < session.currentQuizQuestions.length; i++) {
      session.answer(i, 0);
    }
    expect(session.quizComplete, isTrue);
    expect(session.result.shareText, contains('Fatal flaw:'));

    session.resetQuiz();
    expect(session.answerCount, 0);
    expect(session.quizComplete, isFalse);
    expect(first.intersection(session.currentQuizQuestions.toSet()), isEmpty);
    final second = session.currentQuizQuestions.toSet();
    session.resetQuiz();
    expect(second.intersection(session.currentQuizQuestions.toSet()), isEmpty);
    session.dispose();
  });
}
