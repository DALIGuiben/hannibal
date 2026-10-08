import 'package:flutter/material.dart';

import 'app_strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.lang,
    required this.onLanguageChanged,
    required this.onClear,
  });

  final String lang;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onClear;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _lang = widget.lang;

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl(_lang) ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: const Color(0xFF141B25),
          title: Text(tr(_lang, 'clear_title')),
          content: Text(tr(_lang, 'clear_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr(_lang, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                tr(_lang, 'confirm'),
                style: const TextStyle(color: Color(0xFFFF8A80)),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      widget.onClear();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRtl(_lang) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D131C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D131C),
          title: Text(
            tr(_lang, 'settings'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                tr(_lang, 'chat_language').toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF8F9BAB),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            for (final code in kLanguageCodes)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF151D28),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: code == _lang
                        ? const Color(0x99E0B25B)
                        : Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(
                    kLanguageNames[code]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: Icon(
                    code == _lang
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: code == _lang
                        ? const Color(0xFFE0B25B)
                        : const Color(0xFF768294),
                  ),
                  onTap: () {
                    setState(() => _lang = code);
                    widget.onLanguageChanged(code);
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _confirmClear,
                icon: const Icon(Icons.delete_outline),
                label: Text(tr(_lang, 'clear')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8A80),
                  side: const BorderSide(color: Color(0x66FF8A80)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
