import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Group read receipt information for a message in the Nexconn IM SDK.
///
/// Tracks which group members have read a specific message, enabling the sender to see read/unread status in group channels.
class GroupReadReceiptInfo {
  final RCIMIWGroupReadReceiptInfo _raw;

  GroupReadReceiptInfo._(this._raw);

  /// Creates a [GroupReadReceiptInfo] from an existing SDK object.
  static GroupReadReceiptInfo fromRaw(RCIMIWGroupReadReceiptInfo raw) =>
      GroupReadReceiptInfo._(raw);

  /// Whether this message is a read receipt request message.
  bool? get readReceiptMessage => _raw.readReceiptMessage;

  /// Whether the current user has responded (sent a read receipt) for this message.
  bool? get hasRespond => _raw.hasRespond;

  /// A map of user IDs who have responded with read receipts, keyed by user ID with the response timestamp as the value.
  Map? get respondUserIds => _raw.respondUserIds;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'readReceiptMessage': readReceiptMessage,
    'hasRespond': hasRespond,
    'respondUserIds': respondUserIds,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWGroupReadReceiptInfo get raw => _raw;
}
