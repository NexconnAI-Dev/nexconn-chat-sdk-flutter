import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents an individual user's read receipt status for a message.
class MessageReadReceiptUser {
  /// The user ID of the reader.
  final String? userId;

  /// The timestamp when the user read the message (in milliseconds).
  final int? timestamp;

  /// Whether the user was mentioned in the message.
  final bool? isMentioned;

  final RCIMIWReadReceiptUser? _raw;

  /// Creates a read-receipt user value for callers that construct models
  /// directly. This constructor preserves the pre-5.44 public API.
  const MessageReadReceiptUser({this.userId, this.timestamp, this.isMentioned})
    : _raw = null;

  MessageReadReceiptUser._fromRaw(RCIMIWReadReceiptUser raw)
    : userId = raw.userId,
      timestamp = raw.timestamp,
      isMentioned = raw.isMentioned,
      _raw = raw;

  /// Creates a [MessageReadReceiptUser] from an existing SDK object.
  static MessageReadReceiptUser fromRaw(RCIMIWReadReceiptUser raw) =>
      MessageReadReceiptUser._fromRaw(raw);

  /// The associated SDK object for advanced usage.
  RCIMIWReadReceiptUser get raw =>
      _raw ??
      RCIMIWReadReceiptUser.fromJson({
        'userId': userId,
        'timestamp': timestamp,
        'isMentioned': isMentioned,
      });
}
