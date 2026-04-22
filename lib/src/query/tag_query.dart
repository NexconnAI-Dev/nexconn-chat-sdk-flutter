import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../channel/base_channel.dart';
import '../model/page_data.dart';

/// Parameters for querying channels associated with a specific tag.
class TagChannelsQueryParams {
  /// The unique identifier of the tag to query channels for.
  final String tagId;

  /// The start timestamp used for pagination. Defaults to `0`.
  final int startTime;

  /// Maximum number of channels returned per page.
  final int pageSize;

  /// Creates a [TagChannelsQueryParams] instance.
  TagChannelsQueryParams({
    required this.tagId,
    this.startTime = 0,
    this.pageSize = 20,
  });
}

/// Paginated query executor for fetching channels that belong to a specific tag.
///
/// Results are ordered by operation time. Call [loadNextPage] repeatedly
/// to paginate through all tagged channels.
class TagChannelsQuery {
  final TagChannelsQueryParams _params;
  int _startTime;
  bool _loading = false;

  /// Creates a [TagChannelsQuery] with the given [params].
  TagChannelsQuery(this._params) : _startTime = _params.startTime;

  /// Loads the next page of channels associated with the tag.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageData<BaseChannel>> handler) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.getConversationsFromTagByPage(
      _params.tagId,
      _startTime,
      _params.pageSize,
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
