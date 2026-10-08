# Hannibal Legacy

A Flutter app with a Home tab and two experiences in a fixed bottom navigation bar:

- **Hannibal's Dilemma:** seven swipeable decisions per run, each followed by game trade-offs and a separate historical fact. The question bank covers Hannibal's Iberian command, Saguntum, the road to Italy, the Italian campaign, his return to Africa, and his later reforms in Carthage.
- **Hannibal Wrapped:** seven situational questions per run that combine with the campaign choices to produce a historical personality match.

Each experience draws from a rotating 14-question bank, so the next run has no questions from the run immediately before it. After the bank is exhausted, earlier questions return in a new order. Historical facts, trait scores, and matches remain authored and deterministic. The optional AI narrator adds a short field note after a decision and a personalized Wrapped description. If the API is unavailable, the built-in text appears immediately and play continues.

Use the gear in the top-right corner of Home to switch the entire experience between English, French, and Arabic. The choice is saved on the device, and Arabic uses a right-to-left layout. The campaign, quiz, results, and copied share text all follow the selected language.

Historical references for the new Dilemma chapter: [Polybius, *Histories*, Book III](https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.01.0234%3Abook%3D3), [Livy, Book XXX](https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.02.0159%3Abook%3D30), and [Livy, Book XXXIII](https://www.emersonkent.com/source_text/livius_the_history_of_rome_book_33.htm).

## Run

From this directory:

```powershell
flutter pub get
flutter run -d R3CWA02G7AK
```

To enable the optional AI writing through the configured `codex.sale` Responses endpoint and `gpt-4o`:

```powershell
flutter run -d R3CWA02G7AK --dart-define=CODEX_LB_API_KEY=YOUR_KEY
```

`API_KEY` also works as a Dart define for older local launch configurations. Do not commit a real key. The campaign and quiz work without one.

The Wrapped result is displayed as a 9:16 poster. **Share to Instagram Story** renders that poster as a 1080 × 1920 PNG and opens Instagram's Story composer on Android. The user can edit or cancel it there; the app never publishes automatically. Instagram must be installed on the device. The generated image is stored temporarily in the app's cache and shared through a read-only Android FileProvider URI. On iOS, the app currently shows an unsupported-platform message.

For Meta-registered apps, optionally pass `--dart-define=META_APP_ID=YOUR_META_APP_ID` so the Story intent includes `source_application`. Test the final handoff on a physical Android phone with Instagram installed; the emulator does not include Instagram.
