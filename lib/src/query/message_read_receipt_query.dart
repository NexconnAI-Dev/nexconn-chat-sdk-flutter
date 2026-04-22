import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../channel/base_channel.dart';
import '../enum/read_receipt_status.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../model/message_read_receipt_user.dart';
import '../model/page_data.dart';

/// Parameters for querying users who have read or not read a specific message.
class MessagesReadReceiptUsersQueryParams {
  /// The target channel identifier.
  final ChannelIdentifier channelIdentifier;

  /// The unique identifier of the message to query read receipts for.
  final String messageId;

  /// Maximum number of users returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Optional filter by read/unread status.
  final MessageReadReceiptStatus? status;

  /// Creates a [MessagesReadReceiptUsersQueryParams] instance.
  MessagesReadReceiptUsersQueryParams({
    required this.channelIdentifier,
    required this.messageId,
    this.pageSize = 20,
    this.isAscending,
    this.status,
  });
}

/// Paginated query executor for fetching message read receipt users.
///
/// Retrieves the list of users who have read or not read a specific message.
/// Uses token-based pagination.
class MessagesReadReceiptUsersQuery {
  final MessagesReadReceiptUsersQueryParams _params;
  String? _pageToken;
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [MessagesReadReceiptUsersQuery] with the given [params].
  MessagesReadReceiptUsersQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of read receipt users for the specified message.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageResult<MessageReadReceiptUser>> handler,
  ) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    final option = RCIMIWReadReceiptUsersOption.create(
      pageToken: _pageToken,
      pageCount: _params.pageSize,
      order:
          _params.isAscending == null
              ? null
              : (_params.isAscending!
                  ? RCIMIWReadReceiptOrder.ascending
                  : RCIMIWReadReceiptOrder.descending),
      readStatus:
          _params.status != null
              ? RCIMIWReadReceiptStatus.values[_params.status!.index]
              : null,
    );
    return NCEngine.engine.getMessagesReadReceiptUsersByPageV5(
      Converter.toRCConversationType(_params.channelIdentifier.channelType),
      _params.channelIdentifier.channelId,
      _params.channelIdentifier.subChannelId,
      _params.messageId,
      option,
      callback: IRCIMIWGetMessagesReadReceiptUsersByPageV5Callback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken;
          _hasMore = _pageToken?.isNotEmpty == true;
          handler(
            PageResult(
              data:
                  t?.users?.map(MessageReadReceiptUser.fromRaw).toList() ??
                  const [],
              totalCount: t?.totalCount ?? 0,
            ),
            null,
          );
        },
        onError: (code) {
          _loading = false;
          handler(null, Converter.toNCError(code));
        },
      ),
    );
  }
}
