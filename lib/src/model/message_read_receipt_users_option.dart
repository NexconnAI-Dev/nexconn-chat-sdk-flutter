import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../enum/read_receipt_status.dart';

/// Options for querying users who have read or not read a specific message.
///
/// Supports pagination, ordering, and filtering by read status.
class MessageReadReceiptUsersOption {
  /// The pagination token for fetching the next page of results.
  final String? pageToken;

  /// The number of users to return per page.
  final int? pageCount;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Filter by read or unread status.
  final MessageReadReceiptStatus? readStatus;

  /// Creates [MessageReadReceiptUsersOption] with optional query parameters.
  MessageReadReceiptUsersOption({
    this.pageToken,
    this.pageCount,
    this.isAscending,
    this.readStatus,
  });

  /// Converts this object to the SDK data object.
  RCIMIWReadReceiptUsersOption toRaw() {
    return RCIMIWReadReceiptUsersOption.create(
      pageToken: pageToken,
      pageCount: pageCount,
      order:
          isAscending == null
              ? null
              : (isAscending!
                  ? RCIMIWReadReceiptOrder.ascending
                  : RCIMIWReadReceiptOrder.descending),
      readStatus:
          readStatus != null
              ? RCIMIWReadReceiptStatus.values[readStatus!.index]
              : null,
    );
  }
}
