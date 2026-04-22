import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../message/message.dart';
import '../model/page_data.dart';

/// Parameters for querying messages in an open channel.
class OpenChannelMessagesQueryParams {
  /// The unique identifier of the open channel.
  final String channelId;

  /// Whether messages are fetched in ascending (older → newer) order.
  /// Defaults to `false` (descending, newest first).
  final bool isAscending;

  /// The start timestamp (in milliseconds) used for pagination.
  /// Defaults to `0`, meaning starting from the latest (when descending)
  /// or earliest (when ascending) message.
  final int startTime;

  /// Maximum number of messages returned per page.
  final int pageSize;

  /// Creates an [OpenChannelMessagesQueryParams] instance.
  OpenChannelMessagesQueryParams({
    required this.channelId,
    this.isAscending = false,
    this.startTime = 0,
    this.pageSize = 20,
  });
}

/// Paginated query executor for fetching messages from an open channel.
///
/// Call [loadNextPage] repeatedly to paginate through the message history.
class OpenChannelMessagesQuery {
  final OpenChannelMessagesQueryParams _params;
  int _timestamp;
  bool _loading = false;

  /// Creates an [OpenChannelMessagesQuery] with the given [params].
  OpenChannelMessagesQuery(this._params) : _timestamp = _params.startTime;

  /// Loads the next page of open channel messages.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<Message>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.getChatRoomMessages(
      _params.channelId,
      _timestamp,
      _params.isAscending ? RCIMIWTimeOrder.after : RCIMIWTimeOrder.before,
      _params.pageSize,
      callback: IRCIMIWGetChatRoomMessagesCallback(
        onSuccess: (messages) {
          _loading = false;
          if (messages != null && messages.isNotEmpty) {
            _timestamp = messages.last.sentTime ?? 0;
          }
          handler(
            PageData(
              data:
                  messages?.map(Converter.fromRawMessage).toList() ?? const [],
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
