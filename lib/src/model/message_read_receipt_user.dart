import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents an individual user's read receipt status for a message.
class MessageReadReceiptUser {
  final RCIMIWReadReceiptUser _raw;
  MessageReadReceiptUser._(this._raw);

  /// Creates a [MessageReadReceiptUser] from an existing SDK object.
  static MessageReadReceiptUser fromRaw(RCIMIWReadReceiptUser raw) =>
      MessageReadReceiptUser._(raw);

  /// The user ID of the reader.
  String? get userId => _raw.userId;

  /// The timestamp when the user read the message (in milliseconds).
  int? get timestamp => _raw.timestamp;

  /// The associated SDK object for advanced usage.
  RCIMIWReadReceiptUser get raw => _raw;
}
