import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/channel_type.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../channel/base_channel.dart';
import '../model/page_data.dart';

/// Parameters for configuring a paginated channel list query.
class ChannelsQueryParams {
  /// The channel types to include in the query results.
  final List<ChannelType> channelTypes;

  /// The start timestamp used for pagination. Defaults to `0`.
  final int startTime;

  /// Maximum number of channels returned per page.
  /// Must satisfy `0 < pageSize <= 50`.
  final int pageSize;

  /// Whether pinned (top-priority) channels should be returned first.
  final bool topPriority;

  /// Creates a [ChannelsQueryParams] instance.
  ChannelsQueryParams({
    required this.channelTypes,
    this.startTime = 0,
    this.pageSize = 20,
    this.topPriority = true,
  });
}

/// Paginated query executor for fetching the channel list.
///
/// Results are ordered by operation time and optionally prioritize pinned
/// channels. Call [loadNextPage] repeatedly to paginate through results.
class ChannelsQuery {
  final ChannelsQueryParams _params;
  int _startTime;
  bool _loading = false;

  /// Creates a [ChannelsQuery] with the given [params].
  ChannelsQuery(this._params) : _startTime = _params.startTime;

  /// Loads the next page of channels.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<BaseChannel>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    if (_params.pageSize <= 0 || _params.pageSize > 50) {
      handler(null, Converter.toNCError(34232));
      return Future.value(34232);
    }
    _loading = true;
    return NCEngine.engine.getConversationsWithPriority(
      Converter.toRCConversationTypes(_params.channelTypes),
      null,
      _startTime,
      _params.pageSize,
      _params.topPriority,
      callback: IRCIMIWGetConversationsCallback(
        onSuccess: (t) {
          _loading = false;
          if (t != null && t.isNotEmpty) {
            _startTime = t.last.operationTime ?? 0;
          }
          handler(PageData(data: Converter.toChannels(t)), null);
        },
        onError: (code) {
          _loading = false;
          handler(null, Converter.toNCError(code));
        },
      ),
    );
  }
}
