import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/message_operation_policy.dart';
import '../channel/base_channel.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../message/message.dart';
import '../model/page_data.dart';

/// Parameters for configuring a paginated message query.
///
/// Used by [MessagesQuery] to specify channel, ordering, data source policy,
/// start time, and page size.
class MessagesQueryParams {
  /// The target channel identifier (channel type + channel ID + optional sub-channel ID).
  final ChannelIdentifier channelIdentifier;

  /// Whether messages are fetched in ascending (older → newer) order.
  /// Defaults to `false` (descending, newest first).
  final bool isAscending;

  /// Determines whether messages are fetched from local storage, remote server, or both.
  /// Defaults to [MessageOperationPolicy.localRemote] to match the iOS SDK.
  final MessageOperationPolicy policy;

  /// The start timestamp (in milliseconds) used for pagination.
  /// Defaults to `0`, meaning starting from the latest (when descending)
  /// or earliest (when ascending) message.
  final int startTime;

  /// Maximum number of messages returned per page.
  final int pageSize;

  /// Creates a [MessagesQueryParams] instance.
  MessagesQueryParams({
    required this.channelIdentifier,
    this.isAscending = false,
    this.policy = MessageOperationPolicy.localRemote,
    this.startTime = 0,
    this.pageSize = 20,
  });
}

/// Paginated query executor for fetching messages from a channel.
///
/// Supports both local and remote data sources depending on the
/// [MessageOperationPolicy] specified in [MessagesQueryParams].
/// Call [loadNextPage] repeatedly to paginate through results.
class MessagesQuery {
  final MessagesQueryParams _params;
  int _lastTimestamp;
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [MessagesQuery] with the given [params].
  MessagesQuery(this._params) : _lastTimestamp = _params.startTime;

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of messages.
  ///
  /// Returns the operation ID from the underlying engine, or `-1` if a
  /// request is already in progress (error code `33103`).
  Future<int> loadNextPage(OperationHandler<PageResult<Message>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;

    return NCEngine.engine.getMessages(
      Converter.toRCConversationType(_params.channelIdentifier.channelType),
      _params.channelIdentifier.channelId,
      _params.channelIdentifier.subChannelId,
      _lastTimestamp,
      _params.isAscending ? RCIMIWTimeOrder.after : RCIMIWTimeOrder.before,
      RCIMIWMessageOperationPolicy.values[_params.policy.index],
      _params.pageSize,
      callback: IRCIMIWGetMessagesCallback(
        onSuccess: (messages, totalCount, hasMore) {
          _loading = false;
          _hasMore = hasMore ?? false;
          if (messages != null && messages.isNotEmpty) {
            _lastTimestamp = messages.last.sentTime ?? 0;
          }
          handler(
            PageResult(
              data:
                  messages?.map(Converter.fromRawMessage).toList() ?? const [],
              totalCount: totalCount ?? 0,
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
