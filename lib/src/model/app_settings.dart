import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Application-level settings retrieved from the server.
///
/// Contains feature flags and configuration values that affect SDK behavior
/// across the entire application.
class AppSettings {
  /// Whether speech-to-text conversion is enabled for voice messages.
  final bool? speechToTextEnable;

  /// The time window (in minutes) during which a sent message can be modified.
  final int? messageModifiableMinutes;

  AppSettings._({this.speechToTextEnable, this.messageModifiableMinutes});

  /// Creates a [AppSettings] from an existing SDK object.
  static AppSettings fromRaw(RCIMIWAppSettings raw) {
    return AppSettings._(
      speechToTextEnable: raw.speechToTextEnable,
      messageModifiableMinutes: raw.messageModifiableMinutes,
    );
  }
}
