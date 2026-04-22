import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../message/message.dart';
import '../channel/base_channel.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../model/page_data.dart';

/// Parameters for searching messages by keyword within a channel.
class SearchMessagesQueryParams {
  /// The target channel identifier.
  final ChannelIdentifier channelIdentifier;

  /// The keyword to search for in message content.
  final String keyword;

  /// The start timestamp used for pagination. Defaults to `0`.
  final int startTime;

  /// Maximum number of messages returned per page.
  final int pageSize;

  /// Creates a [SearchMessagesQueryParams] instance.
  SearchMessagesQueryParams({
    required this.channelIdentifier,
    required this.keyword,
    this.startTime = 0,
    this.pageSize = 20,
  });
}

/// Paginated query executor for searching messages by keyword.
///
/// Searches message content within the specified channel.
/// Call [loadNextPage] repeatedly to paginate through results.
class SearchMessagesQuery {
  final SearchMessagesQueryParams _params;
  int _startTime;
  bool _loading = false;

  /// Creates a [SearchMessagesQuery] with the given [params].
  SearchMessagesQuery(this._params) : _startTime = _params.startTime;

  /// Loads the next page of search results.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<Message>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.searchMessages(
      Converter.toRCConversationType(_params.channelIdentifier.channelType),
      _params.channelIdentifier.channelId,
      _params.channelIdentifier.subChannelId,
      _params.keyword,
      _startTime,
      _params.pageSize,
      callback: IRCIMIWSearchMessagesCallback(
        onSuccess: (messages) {
          _loading = false;
          if (messages != null && messages.isNotEmpty) {
            _startTime = messages.last.sentTime ?? 0;
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

/// Parameters for searching messages sent by a specific user within a channel.
class SearchMessagesByUserQueryParams {
  /// The target channel identifier.
  final ChannelIdentifier channelIdentifier;

  /// The user ID whose messages should be searched.
  final String userId;

  /// The start timestamp used for pagination. Defaults to `0`.
  final int startTime;

  /// Maximum number of messages returned per page.
  final int pageSize;

  /// Creates a [SearchMessagesByUserQueryParams] instance.
  SearchMessagesByUserQueryParams({
    required this.channelIdentifier,
    required this.userId,
    this.startTime = 0,
    this.pageSize = 20,
  });
}

/// Paginated query executor for searching messages by a specific user.
///
/// Filters messages within a channel to only those sent by the specified user.
/// Call [loadNextPage] repeatedly to paginate through results.
class SearchMessagesByUserQuery {
  final SearchMessagesByUserQueryParams _params;
  int _startTime;
  bool _loading = false;

  /// Creates a [SearchMessagesByUserQuery] with the given [params].
  SearchMessagesByUserQuery(this._params) : _startTime = _params.startTime;

  /// Loads the next page of messages from the specified user.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<Message>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.searchMessagesByUserId(
      _params.userId,
      Converter.toRCConversationType(_params.channelIdentifier.channelType),
      _params.channelIdentifier.channelId,
      _params.channelIdentifier.subChannelId,
      _startTime,
      _params.pageSize,
      callback: IRCIMIWSearchMessagesByUserIdCallback(
        onSuccess: (messages) {
          _loading = false;
          if (messages != null && messages.isNotEmpty) {
            _startTime = messages.last.sentTime ?? 0;
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

/// Parameters for searching messages within a specific time range.
class SearchMessagesByTimeRangeQueryParams {
  /// The target channel identifier.
  final ChannelIdentifier channelIdentifier;

  /// The keyword to search for in message content.
  final String keyword;

  /// The lower-bound timestamp (in milliseconds) for the search range.
  final int startTime;

  /// The upper-bound timestamp (in milliseconds) for the search range.
  final int endTime;

  /// Maximum number of messages returned per page.
  final int pageSize;

  /// Creates a [SearchMessagesByTimeRangeQueryParams] instance.
  SearchMessagesByTimeRangeQueryParams({
    required this.channelIdentifier,
    required this.keyword,
    this.startTime = 0,
    required this.endTime,
    this.pageSize = 20,
  });
}

/// Paginated query executor for searching messages within a time range.
///
/// Uses offset-based pagination instead of timestamp-based cursor.
/// Call [loadNextPage] repeatedly to paginate through results.
class SearchMessagesByTimeRangeQuery {
  final SearchMessagesByTimeRangeQueryParams _params;
  final int _startTime;
  int _offset = 0;
  bool _loading = false;

  /// Creates a [SearchMessagesByTimeRangeQuery] with the given [params].
  SearchMessagesByTimeRangeQuery(this._params) : _startTime = _params.startTime;

  /// Loads the next page of messages within the time range.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<Message>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.searchMessagesByTimeRange(
      Converter.toRCConversationType(_params.channelIdentifier.channelType),
      _params.channelIdentifier.channelId,
      _params.channelIdentifier.subChannelId,
      _params.keyword,
      _startTime,
      _params.endTime,
      _offset,
      _params.pageSize,
      callback: IRCIMIWSearchMessagesByTimeRangeCallback(
        onSuccess: (messages) {
          _loading = false;
          if (messages != null && messages.isNotEmpty) {
            _offset += messages.length;
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
