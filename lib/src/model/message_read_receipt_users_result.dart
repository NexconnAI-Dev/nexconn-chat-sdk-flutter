import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import 'message_read_receipt_user.dart';

/// The result of querying users who have read or not read a specific message.
///
/// Contains a paginated list of users and the total count.
class MessageReadReceiptUsersResult {
  final RCIMIWReadReceiptUsersResult _raw;
  MessageReadReceiptUsersResult._(this._raw);

  /// Creates a [MessageReadReceiptUsersResult] from an existing SDK object.
  static MessageReadReceiptUsersResult fromRaw(
    RCIMIWReadReceiptUsersResult raw,
  ) => MessageReadReceiptUsersResult._(raw);

  /// The pagination token for fetching the next page of results.
  String? get pageToken => _raw.pageToken;

  /// The total number of users matching the query.
  int? get totalCount => _raw.totalCount;

  /// The list of users with their read receipt details.
  List<MessageReadReceiptUser>? get users =>
      _raw.users?.map(MessageReadReceiptUser.fromRaw).toList();

  /// The associated SDK object for advanced usage.
  RCIMIWReadReceiptUsersResult get raw => _raw;
}
