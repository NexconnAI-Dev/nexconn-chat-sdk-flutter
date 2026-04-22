import 'package:ai_nexconn_chat_plugin/src/enum/subscribe_type.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/friend_application_type.dart';
import '../enum/friend_application_status.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../model/friend_application_info.dart';
import '../model/page_data.dart';
import '../model/subscribe_status_info.dart';

/// Parameters for querying friend applications (requests).
class FriendApplicationsQueryParams {
  /// The application types to include (e.g., sent, received).
  final List<FriendApplicationType> applicationTypes;

  /// The application statuses to filter (e.g., pending, accepted, rejected).
  final List<FriendApplicationStatus> applicationStatuses;

  /// Maximum number of applications returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Creates a [FriendApplicationsQueryParams] instance.
  FriendApplicationsQueryParams({
    required this.applicationTypes,
    required this.applicationStatuses,
    this.pageSize = 20,
    this.isAscending,
  });
}

/// Paginated query executor for fetching friend applications.
///
/// Retrieves sent or received friend requests filtered by type and status.
/// Uses token-based pagination.
class FriendApplicationsQuery {
  final FriendApplicationsQueryParams _params;
  String _pageToken = '';
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [FriendApplicationsQuery] with the given [params].
  FriendApplicationsQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of friend applications.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageResult<FriendApplicationInfo>> handler,
  ) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    final option = RCIMIWPagingQueryOption.create(
      count: _params.pageSize,
      pageToken: _pageToken,
      order: _params.isAscending,
    );
    return NCEngine.engine.getFriendApplications(
      _params.applicationTypes
          .map((t) => RCIMIWFriendApplicationType.values[t.index])
          .toList(),
      _params.applicationStatuses
          .map((s) => RCIMIWFriendApplicationStatus.values[s.index])
          .toList(),
      option,
      callback: IRCIMIWGetFriendApplicationsCallback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken ?? '';
          _hasMore = _pageToken.isNotEmpty;
          handler(
            PageResult(
              data:
                  t?.data
                      ?.map((e) => FriendApplicationInfo.fromRaw(e))
                      .toList() ??
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

/// Parameters for querying subscribe (presence) status by page.
class SubscribeQueryParams {
  /// The subscribe type to query events for (e.g., online status).
  final SubscribeType subscribeType;

  /// Maximum number of events returned per page.
  final int pageSize;

  /// Creates a [SubscribeQueryParams] instance.
  SubscribeQueryParams({required this.subscribeType, this.pageSize = 20});
}

/// Paginated query executor for fetching subscribe (presence) status.
///
/// Uses offset-based pagination. Call [loadNextPage] repeatedly to
/// iterate through all results.
class SubscribeQuery {
  final SubscribeQueryParams _params;
  int _startIndex = 0;
  bool _loading = false;

  /// Creates a [SubscribeQuery] with the given [params].
  SubscribeQuery(this._params);

  /// Loads the next page of subscribe events.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageData<SubscribeStatusInfo>> handler,
  ) {
    if (_loading) {
      handler(null, NCError(code: 33103));
      return Future.value(-1);
    }
    _loading = true;
    return NCEngine.engine.querySubscribeEventByPage(
      RCIMIWSubscribeEventRequest.create(
        subscribeType: RCIMIWSubscribeType.values[_params.subscribeType.index],
      ),
      _params.pageSize,
      _startIndex,
      callback: IRCIMIWQuerySubscribeEventCallback(
        onSuccess: (events) {
          _loading = false;
          if (events != null) {
            _startIndex += events.length;
          }
          handler(
            PageData(
              data:
                  events?.map((e) => SubscribeStatusInfo.fromRaw(e)).toList() ??
                  const [],
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
