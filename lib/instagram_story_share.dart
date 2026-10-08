import 'package:flutter/services.dart';

/// Hands a rendered PNG to Instagram's native Story composer on Android.
/// Opening the composer does not publish the story.
class InstagramStoryShare {
  const InstagramStoryShare();

  static const _channel = MethodChannel('hannibal/instagram_story');

  Future<bool> openComposer(Uint8List png) async {
    final status = await _channel.invokeMethod<String>('shareStory', {
      'png': png,
      // Optional Meta app ID for projects that register one later.
      'appId': const String.fromEnvironment('META_APP_ID'),
    });
    return status == 'opened';
  }
}
