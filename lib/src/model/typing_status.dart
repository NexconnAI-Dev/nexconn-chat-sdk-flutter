import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents a typing indicator status from another user.
///
/// Received when a user in a channel starts or stops typing.
class ChannelUserTypingStatusInfo {
  final RCIMIWTypingStatus _raw;
  ChannelUserTypingStatusInfo._(this._raw);

  /// Creates a [ChannelUserTypingStatusInfo] from an existing SDK object.
  static ChannelUserTypingStatusInfo fromRaw(RCIMIWTypingStatus raw) =>
      ChannelUserTypingStatusInfo._(raw);

  /// The user ID of the person who is typing.
  String? get userId => _raw.userId;

  /// The message content type being composed (e.g., "NC:TxtMsg").
  String? get typingMessageType => _raw.contentType;

  /// The timestamp when the typing status was sent (in milliseconds).
  int? get sentTime => _raw.sentTime;

  /// The associated SDK object for advanced usage.
  RCIMIWTypingStatus get raw => _raw;
}
