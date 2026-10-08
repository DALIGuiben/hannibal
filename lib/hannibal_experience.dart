import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_narrator.dart';
import 'experience_data.dart';
import 'experience_localizations.dart';
import 'instagram_story_share.dart';

const _ink = Color(0xFF0B1018);
const _bronze = Color(0xFFD7A76E);
const _cream = Color(0xFFFFF2DF);
const _purple = Color(0xFF5132B9);

class HannibalHomePage extends StatefulWidget {
  const HannibalHomePage({super.key});

  @override
  State<HannibalHomePage> createState() => _HannibalHomePageState();
}

class _HannibalHomePageState extends State<HannibalHomePage> {
  final GameSession _session = GameSession();
  int _selectedTab = 0;
  int _dilemmaRevision = 0;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString('experience_language');
      if (mounted && supportedExperienceLanguages.containsKey(saved)) {
        setState(() => _language = saved!);
      }
    } catch (_) {
      // The app remains usable if platform preferences are unavailable.
    }
  }

  Future<void> _setLanguage(String code) async {
    if (!supportedExperienceLanguages.containsKey(code)) return;
    setState(() => _language = code);
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('experience_language', code);
    } catch (_) {}
  }

  void _openLanguageSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF19212B),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: _language == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    translated(_language, 'Language'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    translated(
                      _language,
                      'Choose the language for the whole app',
                    ),
                    style: const TextStyle(color: Color(0xFFA8AFB8)),
                  ),
                  const SizedBox(height: 18),
                  for (final entry in supportedExperienceLanguages.entries)
                    ListTile(
                      title: Text(entry.value),
                      trailing: Icon(
                        entry.key == _language
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: _bronze,
                      ),
                      onTap: () {
                        _setLanguage(entry.key);
                        Navigator.pop(sheetContext);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  void _openDilemma() => setState(() => _selectedTab = 1);

  void _openWrapped() => setState(() => _selectedTab = 2);

  void _openDilemmaFromWrapped() {
    if (_session.decisionCount == _session.currentDilemmas.length) {
      _session.resetDilemmas();
      _dilemmaRevision++;
    }
    _openDilemma();
  }

  @override
  Widget build(BuildContext context) {
    return ExperienceLanguage(
      code: _language,
      child: Directionality(
        textDirection: _language == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: _ink,
            body: IndexedStack(
              index: _selectedTab,
              children: [
                SafeArea(
                  child: AnimatedBuilder(
                    animation: _session,
                    builder: (context, _) => Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                children: [
                                  const _Seal(),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tx(context, 'HANNIBAL / YOUR LEGACY'),
                                      textDirection: _language == 'ar'
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      style: const TextStyle(
                                        color: _bronze,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    key: const Key('language_settings'),
                                    onPressed: _openLanguageSettings,
                                    tooltip: tx(context, 'Language'),
                                    icon: const Icon(Icons.settings_rounded),
                                    color: _bronze,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              tx(
                                context,
                                'History is decided\none choice at a time.',
                              ),
                              style: const TextStyle(
                                color: _cream,
                                fontSize: 35,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.3,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              tx(
                                context,
                                'Command the campaign. Then discover the ancient leader inside your decisions.',
                              ),
                              style: const TextStyle(
                                color: Color(0xFFA8AFB8),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 27),
                            _ExperienceTile(
                              onTap: _openDilemma,
                              dark: true,
                              number: tx(context, '01 / PLAY'),
                              title: tx(context, 'Hannibal’s\nDilemma'),
                              description: tx(
                                context,
                                'Swipe through real turning points. See the price of every move.',
                              ),
                              footnote: _session.decisionCount == 0
                                  ? tx(
                                      context,
                                      '7 HISTORICAL DECISIONS · NEW ON REPLAY',
                                    )
                                  : _session.decisionCount ==
                                        _session.currentDilemmas.length
                                  ? tx(context, 'CAMPAIGN COMPLETE')
                                  : translatedTemplate(
                                      _language,
                                      'CONTINUE {count} OF {total}',
                                      {
                                        'count': _session.decisionCount,
                                        'total':
                                            _session.currentDilemmas.length,
                                      },
                                    ),
                              icon: Icons.swipe_rounded,
                            ),
                            const SizedBox(height: 14),
                            _ExperienceTile(
                              onTap: _openWrapped,
                              dark: false,
                              number: tx(context, '02 / DISCOVER'),
                              title: tx(context, 'Hannibal\nWrapped'),
                              description: tx(
                                context,
                                'Seven fresh choices each run. One ancient alter ego. A result worth sharing.',
                              ),
                              footnote: _session.decisionCount == 0
                                  ? tx(
                                      context,
                                      'YOUR CAMPAIGN CAN SHAPE THE RESULT',
                                    )
                                  : translatedTemplate(
                                      _language,
                                      '{count} CAMPAIGN CHOICES INCLUDED',
                                      {'count': _session.decisionCount},
                                    ),
                              icon: Icons.auto_awesome_rounded,
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                tx(
                                  context,
                                  'The choices are yours. The historical facts stay true.',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF777F8A),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                DilemmaPage(
                  key: ValueKey(_dilemmaRevision),
                  session: _session,
                  onHome: () => setState(() => _selectedTab = 0),
                  onWrapped: _openWrapped,
                ),
                WrappedPage(
                  session: _session,
                  onHome: () => setState(() => _selectedTab = 0),
                  onDilemma: _openDilemmaFromWrapped,
                ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              height: 72,
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              backgroundColor: const Color(0xFF151B25),
              indicatorColor: const Color(0xFF594331),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  color: _cream,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_rounded),
                  label: tx(context, 'Home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.swipe_rounded),
                  label: tx(context, 'Dilemma'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: tx(context, 'Wrapped'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Seal extends StatelessWidget {
  const _Seal();
  @override
  Widget build(BuildContext context) => Container(
    width: 37,
    height: 37,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFF2D211D),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _bronze.withValues(alpha: .4)),
    ),
    child: const Text(
      'H',
      style: TextStyle(
        color: _bronze,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({
    required this.onTap,
    required this.dark,
    required this.number,
    required this.title,
    required this.description,
    required this.footnote,
    required this.icon,
  });
  final VoidCallback onTap;
  final bool dark;
  final String number;
  final String title;
  final String description;
  final String footnote;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? _cream : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          height: 210,
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF31201F),
                      Color(0xFF161C23),
                      Color(0xFF261B1A),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6946D6),
                      Color(0xFF4532B6),
                      Color(0xFFEC7291),
                    ],
                  ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: dark ? const Color(0xFF6C4E3D) : const Color(0x55FFFFFF),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(
                    color: Colors.white.withValues(alpha: dark ? .09 : .16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(21, 18, 20, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          number,
                          style: TextStyle(
                            color: dark ? _bronze : const Color(0xFFEADFFF),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          icon,
                          color: foreground.withValues(alpha: .82),
                          size: 25,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 27,
                        height: 1.01,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: .78),
                        fontSize: 13,
                        height: 1.27,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            footnote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground.withValues(alpha: .85),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .65,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: foreground,
                          size: 20,
                        ),
                      ],
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

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final path = Path()
        ..moveTo(size.width * (.35 + i * .11), -20)
        ..cubicTo(
          size.width * (.2 + i * .12),
          size.height * .28,
          size.width * (.88 - i * .06),
          size.height * .55,
          size.width * (.62 + i * .1),
          size.height + 30,
        );
      canvas.drawPath(path, line);
    }
    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * .76, size.height * .24), 3, dot);
    canvas.drawCircle(Offset(size.width * .57, size.height * .75), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      color != oldDelegate.color;
}

class DilemmaPage extends StatefulWidget {
  const DilemmaPage({
    super.key,
    required this.session,
    required this.onHome,
    required this.onWrapped,
  });
  final GameSession session;
  final VoidCallback onHome;
  final VoidCallback onWrapped;
  @override
  State<DilemmaPage> createState() => _DilemmaPageState();
}

class _DilemmaPageState extends State<DilemmaPage> {
  final AiNarrator _narrator = const AiNarrator();
  late int _index;
  bool? _choiceRight;
  double _drag = 0;
  String? _fieldNote;
  bool _noteFromAi = false;
  String? _noteLanguage;

  @override
  void initState() {
    super.initState();
    _index = widget.session.nextDecision;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = ExperienceLanguage.of(context);
    if (_noteLanguage != null &&
        _noteLanguage != language &&
        _choiceRight != null) {
      final dilemma = widget.session.currentDilemmas[_index];
      final choice = _choiceRight! ? dilemma.right : dilemma.left;
      _fieldNote = choice.outcome;
      _noteFromAi = false;
      _noteLanguage = language;
      if (_narrator.isConfigured) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadNote(
              dilemma,
              choice,
              _choiceRight == dilemma.actualRight,
              _index,
              language,
            );
          }
        });
      }
    }
  }

  void _choose(bool right) {
    if (_choiceRight != null ||
        _index >= widget.session.currentDilemmas.length) {
      return;
    }
    final dilemma = widget.session.currentDilemmas[_index];
    final choice = right ? dilemma.right : dilemma.left;
    final language = ExperienceLanguage.of(context);
    widget.session.choose(_index, right);
    setState(() {
      _choiceRight = right;
      _drag = 0;
      _fieldNote = choice.outcome;
      _noteFromAi = false;
      _noteLanguage = language;
    });
    if (_narrator.isConfigured) {
      _loadNote(
        dilemma,
        choice,
        right == dilemma.actualRight,
        _index,
        language,
      );
    }
  }

  Future<void> _loadNote(
    Dilemma dilemma,
    DecisionOption choice,
    bool historical,
    int requestIndex,
    String language,
  ) async {
    final text = await _narrator.consequence(
      dilemma: dilemma,
      choice: choice,
      wasHistoricalChoice: historical,
      language: language,
    );
    if (!mounted ||
        _index != requestIndex ||
        _choiceRight == null ||
        _noteLanguage != language) {
      return;
    }
    setState(() {
      _fieldNote = text;
      _noteFromAi = text != choice.outcome;
    });
  }

  void _next() {
    setState(() {
      _index = widget.session.nextDecision;
      _choiceRight = null;
      _drag = 0;
      _fieldNote = null;
      _noteFromAi = false;
      _noteLanguage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = _index >= widget.session.currentDilemmas.length;
    return Scaffold(
      backgroundColor: const Color(0xFF101318),
      bottomNavigationBar: _choiceRight == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 11, 20, 12),
                color: const Color(0xFF101318),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 590),
                    child: _PrimaryButton(
                      label: tx(
                        context,
                        _index == widget.session.currentDilemmas.length - 1
                            ? 'Finish campaign'
                            : 'Next decision',
                      ),
                      icon: Icons.arrow_forward_rounded,
                      onTap: _next,
                      color: _bronze,
                      foreground: const Color(0xFF241713),
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 630),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              children: [
                _GameTopBar(
                  onBack: widget.onHome,
                  label: tx(context, 'HANNIBAL’S DILEMMA'),
                  index: completed
                      ? widget.session.currentDilemmas.length
                      : _index + 1,
                  total: widget.session.currentDilemmas.length,
                ),
                const SizedBox(height: 25),
                if (completed)
                  _CampaignComplete(
                    onWrapped: widget.onWrapped,
                    onReplay: () {
                      widget.session.resetDilemmas();
                      _next();
                    },
                  )
                else if (_choiceRight == null)
                  _decisionView(widget.session.currentDilemmas[_index])
                else
                  _outcomeView(
                    widget.session.currentDilemmas[_index],
                    _choiceRight!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _decisionView(Dilemma dilemma) {
    final translatedLayout = ExperienceLanguage.of(context) != 'en';
    final cardHeight = math.min(
      translatedLayout ? 570.0 : 465.0,
      math.max(
        translatedLayout ? 510.0 : 375.0,
        MediaQuery.sizeOf(context).height * .58,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tx(context, 'THE DECISION IS YOURS'),
          style: const TextStyle(
            color: _bronze,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onHorizontalDragUpdate: (details) => setState(
            () => _drag = (_drag + details.delta.dx).clamp(-185, 185),
          ),
          onHorizontalDragEnd: (_) {
            if (_drag.abs() > 85) {
              _choose(_drag > 0);
            } else {
              setState(() => _drag = 0);
            }
          },
          child: Transform.translate(
            offset: Offset(_drag, 0),
            child: Transform.rotate(
              angle: _drag / 2200,
              child: Container(
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF322321),
                      Color(0xFF1B2027),
                      Color(0xFF161A20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF69503D)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 35,
                      offset: Offset(0, 17),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CustomPaint(
                          painter: const _RoutePainter(
                            color: Color(0x24D7A76E),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23, 23, 23, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                translatedYear(
                                  ExperienceLanguage.of(context),
                                  dilemma.year,
                                ),
                                style: const TextStyle(
                                  color: _bronze,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.explore_outlined,
                                color: Color(0xFF9C8070),
                                size: 24,
                              ),
                            ],
                          ),
                          const Spacer(flex: 2),
                          Text(
                            tx(context, dilemma.place),
                            style: const TextStyle(
                              color: Color(0xFFC9A486),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tx(context, dilemma.title),
                            style: const TextStyle(
                              color: _cream,
                              fontSize: 34,
                              height: 1.03,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tx(context, dilemma.setup),
                            style: const TextStyle(
                              color: Color(0xFFE0D1C2),
                              fontSize: 16,
                              height: 1.44,
                            ),
                          ),
                          const Spacer(flex: 2),
                          Container(height: 1, color: const Color(0x50D7A76E)),
                          const SizedBox(height: 15),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _CardChoice(
                                    label: tx(context, dilemma.left.label),
                                    arrow: '←',
                                    alignRight: false,
                                    onTap: () => _choose(false),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _CardChoice(
                                    label: tx(context, dilemma.right.label),
                                    arrow: '→',
                                    alignRight: true,
                                    onTap: () => _choose(true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_drag.abs() > 22)
                      Positioned(
                        top: 78,
                        left: _drag < 0 ? 16 : null,
                        right: _drag > 0 ? 16 : null,
                        child: Transform.rotate(
                          angle: _drag < 0 ? -.15 : .15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _drag < 0
                                    ? const Color(0xFFFF8D75)
                                    : _bronze,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tx(context, _drag < 0 ? 'LEFT' : 'RIGHT'),
                              style: TextStyle(
                                color: _drag < 0
                                    ? const Color(0xFFFF8D75)
                                    : _bronze,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Center(
          child: Text(
            tx(context, 'SWIPE THE CARD OR TAP A CHOICE'),
            style: const TextStyle(
              color: Color(0xFF8F8580),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _outcomeView(Dilemma dilemma, bool right) {
    final choice = right ? dilemma.right : dilemma.left;
    final historical = right == dilemma.actualRight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tx(
            context,
            historical ? 'YOU CHOSE HANNIBAL’S MOVE' : 'A DIFFERENT TIMELINE',
          ),
          style: const TextStyle(
            color: _bronze,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          tx(context, choice.outcomeTitle),
          style: const TextStyle(
            color: _cream,
            fontSize: 32,
            height: 1.08,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Expanded(
              child: _ImpactStat(
                label: tx(context, 'RISK'),
                value: choice.risk,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ImpactStat(
                label: tx(context, 'SURPRISE'),
                value: choice.surprise,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ImpactStat(
                label: tx(context, 'ARMY'),
                value: choice.army,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          tx(
            context,
            'Game stats illustrate trade-offs; they are not historical measurements.',
          ),
          style: const TextStyle(color: Color(0xFF8C9098), fontSize: 11),
        ),
        const SizedBox(height: 19),
        _InformationPanel(
          label: tx(context, _noteFromAi ? 'AI FIELD NOTE' : 'CAMPAIGN NOTE'),
          text: _noteFromAi
              ? (_fieldNote ?? '')
              : tx(context, _fieldNote ?? choice.outcome),
          icon: Icons.auto_awesome_rounded,
          accent: const Color(0xFFE5AE8A),
        ),
        const SizedBox(height: 12),
        _InformationPanel(
          label: tx(context, 'WHAT HANNIBAL DID'),
          text: tx(context, dilemma.historicalTruth),
          icon: Icons.history_edu_rounded,
          accent: _bronze,
        ),
      ],
    );
  }
}

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({
    required this.onBack,
    required this.label,
    required this.index,
    required this.total,
  });
  final VoidCallback onBack;
  final String label;
  final int index;
  final int total;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          _BackButton(onTap: onBack, color: _cream),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _cream,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            '${index.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: _bronze,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      const SizedBox(height: 17),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          minHeight: 4,
          value: index / total,
          backgroundColor: const Color(0xFF3C3331),
          valueColor: const AlwaysStoppedAnimation(_bronze),
        ),
      ),
    ],
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap, required this.color});
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tx(context, 'Back'),
    icon: const Icon(Icons.arrow_back_rounded),
    color: color,
    style: IconButton.styleFrom(
      backgroundColor: color.withValues(alpha: .11),
      fixedSize: const Size(40, 40),
    ),
  );
}

class _CardChoice extends StatelessWidget {
  const _CardChoice({
    required this.label,
    required this.arrow,
    required this.alignRight,
    required this.onTap,
  });
  final String label;
  final String arrow;
  final bool alignRight;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            arrow,
            style: const TextStyle(color: _bronze, fontSize: 23, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            textDirection: ExperienceLanguage.of(context) == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: const TextStyle(
              color: _cream,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.18,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) {
    final color = value > 0
        ? const Color(0xFF7EE2B1)
        : value < 0
        ? const Color(0xFFFF9B88)
        : const Color(0xFFE4D2BA);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF20262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF384047)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA4ADB5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${value > 0 ? '+' : ''}$value',
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationPanel extends StatelessWidget {
  const _InformationPanel({
    required this.label,
    required this.text,
    required this.icon,
    required this.accent,
  });
  final String label;
  final String text;
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2027),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: accent.withValues(alpha: .27)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(color: _cream, fontSize: 15, height: 1.4),
        ),
      ],
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.foreground,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 19),
        ],
      ),
    ),
  );
}

class _CampaignComplete extends StatelessWidget {
  const _CampaignComplete({required this.onWrapped, required this.onReplay});
  final VoidCallback onWrapped;
  final VoidCallback onReplay;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A2B27), Color(0xFF1B232B)],
          ),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: const Color(0xFF8B6146)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tx(context, 'THE CAMPAIGN IS COMPLETE'),
              style: const TextStyle(
                color: _bronze,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              tx(context, 'You shaped\nthe war.'),
              style: const TextStyle(
                color: _cream,
                fontSize: 40,
                height: 1.03,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              tx(
                context,
                'Your decisions now influence your Hannibal Wrapped result. Seven quick questions reveal your ancient alter ego.',
              ),
              style: const TextStyle(
                color: Color(0xFFD6C4B5),
                fontSize: 16,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              tx(
                context,
                'History remembers Hannibal’s choices. Wrapped remembers yours.',
              ),
              style: const TextStyle(
                color: Color(0xFFE8B983),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _PrimaryButton(
        label: tx(context, 'Discover your alter ego'),
        icon: Icons.auto_awesome_rounded,
        onTap: onWrapped,
        color: const Color(0xFFB9A5FF),
        foreground: const Color(0xFF25184C),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: onReplay,
        child: Text(
          tx(context, 'Replay the campaign'),
          style: const TextStyle(color: _bronze),
        ),
      ),
    ],
  );
}

class WrappedPage extends StatefulWidget {
  const WrappedPage({
    super.key,
    required this.session,
    required this.onHome,
    required this.onDilemma,
  });
  final GameSession session;
  final VoidCallback onHome;
  final VoidCallback onDilemma;

  @override
  State<WrappedPage> createState() => _WrappedPageState();
}

class _WrappedPageState extends State<WrappedPage> {
  final AiNarrator _narrator = const AiNarrator();
  final GlobalKey _storyKey = GlobalKey();
  late int _step;
  int? _selected;
  String? _portrait;
  bool _portraitFromAi = false;
  String? _portraitSignature;
  bool _sharingStory = false;

  @override
  void initState() {
    super.initState();
    _step = widget.session.answerCount;
    widget.session.addListener(_onSessionChanged);
    if (_step == widget.session.currentQuizQuestions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPortrait());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_step == widget.session.currentQuizQuestions.length &&
        widget.session.quizComplete &&
        _portraitSignature != _currentPortraitSignature()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadPortrait();
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (_step == widget.session.currentQuizQuestions.length &&
        widget.session.quizComplete &&
        _portraitSignature != _currentPortraitSignature()) {
      _loadPortrait();
    }
  }

  String _currentPortraitSignature() {
    final result = widget.session.result;
    return '${ExperienceLanguage.of(context)}|${result.match.name}|${result.strategy}|${result.audacity}|'
        '${result.diplomacy}|${result.resolve}|${widget.session.decisionSummary.join(';')}';
  }

  Future<void> _answer(int index) async {
    if (_selected != null ||
        _step >= widget.session.currentQuizQuestions.length) {
      return;
    }
    widget.session.answer(_step, index);
    setState(() => _selected = index);
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    setState(() {
      _step++;
      _selected = null;
    });
    if (_step == widget.session.currentQuizQuestions.length) _loadPortrait();
  }

  Future<void> _loadPortrait() async {
    if (!mounted || !widget.session.quizComplete) return;
    final result = widget.session.result;
    final signature = _currentPortraitSignature();
    _portraitSignature = signature;
    setState(() {
      _portrait = result.match.fallbackDescription;
      _portraitFromAi = false;
    });
    if (!_narrator.isConfigured) return;
    final text = await _narrator.wrappedDescription(
      result: result,
      decisions: widget.session.decisionSummary,
      language: ExperienceLanguage.of(context),
    );
    if (!mounted ||
        _step != widget.session.currentQuizQuestions.length ||
        _portraitSignature != signature) {
      return;
    }
    setState(() {
      _portrait = text;
      _portraitFromAi = text != result.match.fallbackDescription;
    });
  }

  void _retake() {
    widget.session.resetQuiz();
    setState(() {
      _step = 0;
      _selected = null;
      _portrait = null;
      _portraitFromAi = false;
      _portraitSignature = null;
    });
  }

  Future<void> _shareToStory() async {
    if (_sharingStory) return;
    setState(() => _sharingStory = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary =
          _storyKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || boundary.size.width <= 0) {
        throw StateError('Story poster is not ready');
      }
      // Render the visible result at Instagram Story resolution: 1080 × 1920.
      final image = await boundary.toImage(
        pixelRatio: 1080 / boundary.size.width,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('Could not encode Story poster');
      final opened = await const InstagramStoryShare().openComposer(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tx(
              context,
              opened
                  ? 'Instagram opened. You choose whether to post your Story.'
                  : 'Instagram is not installed. Install it to share your Story.',
            ),
          ),
        ),
      );
    } on MissingPluginException {
      _showStoryError('Instagram Stories is available on Android only.');
    } catch (_) {
      _showStoryError('Could not open Instagram Stories. Please try again.');
    } finally {
      if (mounted) setState(() => _sharingStory = false);
    }
  }

  void _showStoryError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tx(context, message))));
  }

  void _openDilemmaFromResult() => widget.onDilemma();

  @override
  Widget build(BuildContext context) {
    final finished = _step >= widget.session.currentQuizQuestions.length;
    return Scaffold(
      backgroundColor: const Color(0xFF3B239B),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5735C3), Color(0xFF3E29A9), Color(0xFFD85697)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 630),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  Row(
                    children: [
                      _BackButton(onTap: widget.onHome, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tx(context, 'HANNIBAL WRAPPED'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        finished
                            ? tx(context, 'YOUR RESULT')
                            : '${(_step + 1).toString().padLeft(2, '0')} / 07',
                        style: const TextStyle(
                          color: Color(0xFFFDE7FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (finished)
                    _resultView(widget.session.result)
                  else
                    _quizView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quizView() {
    final question = widget.session.currentQuizQuestions[_step];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.08, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(_step),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_step + 1) / widget.session.currentQuizQuestions.length,
              minHeight: 5,
              backgroundColor: const Color(0x55FFFFFF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFCF75)),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            tx(context, 'YOUR INSTINCTS, REVEALED'),
            style: const TextStyle(
              color: Color(0xFFFFD8A8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.75,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tx(context, question.prompt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            widget.session.decisionCount == 0
                ? tx(context, 'Choose what you would actually do.')
                : translatedTemplate(
                    ExperienceLanguage.of(context),
                    '{count} Dilemma decisions will shape your match too.',
                    {'count': widget.session.decisionCount},
                  ),
            style: const TextStyle(
              color: Color(0xFFE8DCF9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < question.options.length; i++) ...[
            _QuizChoice(
              letter: String.fromCharCode(65 + i),
              text: tx(context, question.options[i].text),
              selected: _selected == i,
              onTap: () => _answer(i),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 22),
          Center(
            child: Text(
              tx(context, 'NO WRONG ANSWERS. JUST YOUR STORY.'),
              style: const TextStyle(
                color: Color(0xFFDDD0F4),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultView(WrappedResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tx(context, 'THE VERDICT IS IN'),
          style: const TextStyle(
            color: Color(0xFFFFE0A5),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        RepaintBoundary(
          key: _storyKey,
          child: _StoryPoster(
            result: result,
            portrait: _portraitFromAi
                ? (_portrait ?? '')
                : tx(context, _portrait ?? result.match.fallbackDescription),
            portraitFromAi: _portraitFromAi,
          ),
        ),
        const SizedBox(height: 17),
        SizedBox(
          height: 54,
          child: FilledButton(
            key: const Key('share_instagram_story'),
            onPressed: _sharingStory ? null : _shareToStory,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _purple,
              disabledBackgroundColor: const Color(0xFFDFD8F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_sharingStory)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const _InstagramIcon(),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    tx(
                      context,
                      _sharingStory
                          ? 'Preparing your Story…'
                          : 'Share to Instagram Story',
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        TextButton.icon(
          onPressed: _openDilemmaFromResult,
          icon: const Icon(Icons.swipe_rounded, color: Colors.white),
          label: Text(
            widget.session.decisionCount ==
                    widget.session.currentDilemmas.length
                ? tx(context, 'Replay Dilemma')
                : tx(context, 'Play Dilemma'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: _retake,
          child: Text(
            tx(context, 'Retake the quiz'),
            style: const TextStyle(color: Color(0xFFEADFFF)),
          ),
        ),
      ],
    );
  }
}

class _QuizChoice extends StatelessWidget {
  const _QuizChoice({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        constraints: const BoxConstraints(minHeight: 74),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD783) : const Color(0xFFF9F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFFFE6AF) : const Color(0xFFE0D8FF),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x260F074A),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFECE4FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF251950),
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: _purple,
              size: selected ? 21 : 15,
            ),
          ],
        ),
      ),
    ),
  );
}

/// The on-screen preview is the exact 9:16 canvas exported to Instagram.
class _StoryPoster extends StatelessWidget {
  const _StoryPoster({
    required this.result,
    required this.portrait,
    required this.portraitFromAi,
  });

  final WrappedResult result;
  final String portrait;
  final bool portraitFromAi;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 9 / 16,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF27135F), Color(0xFF6A3BC8), Color(0xFFD65B91)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 17, 14, 17),
        child: Column(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 360,
                  child: _ShareCard(
                    result: result,
                    portrait: portrait,
                    portraitFromAi: portraitFromAi,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '#HannibalWrapped',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(20, 20),
    painter: _InstagramIconPainter(_purple),
  );
}

class _InstagramIconPainter extends CustomPainter {
  const _InstagramIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.2, 1.2, size.width - 2.4, size.height - 2.4),
        const Radius.circular(5.5),
      ),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * .22,
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .24),
      1.2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_InstagramIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.result,
    required this.portrait,
    required this.portraitFromAi,
  });
  final WrappedResult result;
  final String portrait;
  final bool portraitFromAi;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(22, 21, 22, 22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF7E8), Color(0xFFFFE5EC), Color(0xFFE7D8FF)],
      ),
      borderRadius: BorderRadius.circular(29),
      boxShadow: const [
        BoxShadow(
          color: Color(0x440F074A),
          blurRadius: 30,
          offset: Offset(0, 13),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tx(context, 'HANNIBAL WRAPPED'),
              style: const TextStyle(
                color: _purple,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
            const Spacer(),
            Text(result.match.symbol, style: const TextStyle(fontSize: 30)),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          tx(context, 'YOU ARE'),
          style: const TextStyle(
            color: Color(0xFF7B65A8),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        Text(
          '${result.percentage}%',
          style: const TextStyle(
            color: _purple,
            fontSize: 78,
            height: .98,
            fontWeight: FontWeight.w900,
            letterSpacing: -4,
          ),
        ),
        Text(
          tx(context, result.match.name).toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF2B1C64),
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          tx(context, result.match.subtitle),
          style: const TextStyle(
            color: Color(0xFF8C5C8C),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        _TraitBar(
          label: tx(context, 'STRATEGIC'),
          value: result.strategy,
          color: const Color(0xFF6C47DB),
        ),
        const SizedBox(height: 11),
        _TraitBar(
          label: tx(context, 'AUDACIOUS'),
          value: result.audacity,
          color: const Color(0xFFFF7970),
        ),
        const SizedBox(height: 11),
        _TraitBar(
          label: tx(context, 'DIPLOMATIC'),
          value: result.diplomacy,
          color: const Color(0xFFDA5EB4),
        ),
        const SizedBox(height: 11),
        _TraitBar(
          label: tx(context, 'RESOLUTE'),
          value: result.resolve,
          color: const Color(0xFFE7A049),
        ),
        const SizedBox(height: 23),
        Container(height: 1, color: const Color(0xFFCCB8DE)),
        const SizedBox(height: 18),
        Text(
          tx(context, 'YOUR FATAL FLAW'),
          style: const TextStyle(
            color: Color(0xFFB64D75),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tx(context, result.match.fatalFlaw),
          style: const TextStyle(
            color: Color(0xFF301D60),
            fontSize: 19,
            height: 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          portrait,
          style: const TextStyle(
            color: Color(0xFF5B4A75),
            fontSize: 14,
            height: 1.42,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                translatedTemplate(
                  ExperienceLanguage.of(context),
                  '{count} campaign choices shaped this result',
                  {'count': result.decisionCount},
                ),
                style: const TextStyle(
                  color: Color(0xFF876C99),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (portraitFromAi) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF8F61C4),
                size: 15,
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

class _TraitBar extends StatelessWidget {
  const _TraitBar({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5A4979),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          ),
          Text(
            '$value%',
            style: const TextStyle(
              color: Color(0xFF2E2063),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: value / 100,
          minHeight: 7,
          backgroundColor: const Color(0xFFD8CDEA),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ],
  );
}
