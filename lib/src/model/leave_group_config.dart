import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Configuration options for leaving a group.
///
/// Controls what associated data should be cleaned up when a user leaves a group.
class LeaveGroupConfig {
  final RCIMIWQuitGroupConfig _raw;
  LeaveGroupConfig._(this._raw);

  /// Creates a [LeaveGroupConfig] with default settings.
  LeaveGroupConfig() : this._(RCIMIWQuitGroupConfig.create());

  /// Creates a [LeaveGroupConfig] from an existing SDK object.
  static LeaveGroupConfig fromRaw(RCIMIWQuitGroupConfig raw) =>
      LeaveGroupConfig._(raw);

  /// Whether to remove the user's mute status upon leaving.
  bool? get deleteMuteStatus => _raw.removeMuteStatus;

  /// Whether to remove the user from the group's allowed senders list.
  bool? get deleteAllowedSendersList => _raw.removeWhiteList;

  /// Whether to remove the group from the user's favorites.
  bool? get deleteFavorites => _raw.removeFollow;

  /// The associated SDK object for advanced usage.
  RCIMIWQuitGroupConfig get raw => _raw;
}
