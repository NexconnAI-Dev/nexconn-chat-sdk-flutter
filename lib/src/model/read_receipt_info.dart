import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents read receipt information for a specific message.
///
/// Provides the read, unread, and total counts for message recipients.
class ReadReceiptInfo {
  final RCIMIWReadReceiptInfoV5 _raw;
  ReadReceiptInfo._(this._raw);

  /// Creates a [ReadReceiptInfo] from an existing SDK object.
  static ReadReceiptInfo fromRaw(RCIMIWReadReceiptInfoV5 raw) =>
      ReadReceiptInfo._(raw);

  /// The unique message identifier.
  String? get messageId => _raw.messageUId;

  /// The number of users who have read the message.
  int? get readCount => _raw.readCount;

  /// The number of users who have not yet read the message.
  int? get unreadCount => _raw.unreadCount;

  /// The total number of message recipients.
  int? get totalCount => _raw.totalCount;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'readCount': readCount,
    'unreadCount': unreadCount,
    'totalCount': totalCount,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWReadReceiptInfoV5 get raw => _raw;
}
