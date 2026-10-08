# Hannibal Legacy

An interactive Flutter app that turns Hannibal Barca's history into a decision game and a shareable personality result. Built for **L'IA au service d'Hannibal Barca**.

The app has two connected experiences:

- **Hannibal's Dilemma** — Swipe through seven decisions inspired by real turning points in Hannibal's story. Each choice reveals game trade-offs and a separate historical truth.
- **Hannibal Wrapped** — Answer seven situational questions to discover an ancient-leader match, four personality scores, and a memorable fatal flaw. Choices made in Dilemma influence the result.

Both experiences draw from rotating banks of 14 prompts, so a replay gives you a different set. Historical facts and scoring are authored in the app; they do not depend on an AI service.

## Features

- Home, Dilemma, and Wrapped in a fixed bottom navigation bar.
- English, French, and Arabic, with right-to-left layout for Arabic. Change language from the gear on Home; the selection is saved locally.
- Optional AI-written decision notes and Wrapped descriptions. The app remains playable offline or without an API key.
- A 9:16 Wrapped poster exported as a 1080 × 1920 PNG for Instagram Stories on Android. Instagram opens its Story composer; **the user chooses whether to post**.

## Run locally

Install Flutter and an Android emulator or connect an Android phone, then run from this repository:

```powershell
flutter pub get
flutter devices
flutter run -d YOUR_DEVICE_ID
```

The app works without API configuration. For optional AI narration, the current integration uses `gpt-4o` through the `codex.sale` Responses endpoint:

```powershell
flutter run -d YOUR_DEVICE_ID --dart-define=CODEX_LB_API_KEY=YOUR_KEY
```

For a Meta-registered app, you may also pass `--dart-define=META_APP_ID=YOUR_META_APP_ID` to include `source_application` in the Instagram Story handoff.

**Keep credentials out of Git.** Dart defines are bundled into the compiled app, so this key setup is for a local demo, not a secure production release. A production version should send AI requests through a backend that keeps the key private.

## Instagram Story sharing

Finish Wrapped and tap **Share to Instagram Story**. The app renders the visible result as a PNG, shares it with Instagram through an Android `FileProvider`, and leaves editing and posting to the user.

- Requires Instagram on the Android device; test the complete handoff on a physical phone.
- Does not publish automatically or require Instagram login inside the app.
- iOS Story sharing is not implemented yet; the app shows an unsupported-platform message there.

## Check the project

```powershell
flutter analyze
flutter test
flutter build apk --release
```

The main implementation lives in `lib/hannibal_experience.dart`. The rotating questions, historical facts, and scoring are in `lib/experience_data.dart`; translations are in the `lib/experience_*localizations.dart` files. Optional AI narration is in `lib/ai_narrator.dart`, and the Instagram bridge is in `lib/instagram_story_share.dart` plus the Android `MainActivity.kt` and `StoryFileProvider.kt` files.

## Historical reading

The game separates the player's hypothetical choices from what the sources say happened. Starting points for the Punic War and Hannibal's later career include [Polybius, *Histories*, Book III](https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.01.0234%3Abook%3D3), [Livy, *History of Rome*, Book XXX](https://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.02.0159%3Abook%3D30), and [Book XXXIII](https://www.emersonkent.com/source_text/livius_the_history_of_rome_book_33.htm).
