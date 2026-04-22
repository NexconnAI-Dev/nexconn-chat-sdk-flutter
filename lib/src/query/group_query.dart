import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/group_member_role.dart';
import '../enum/group_application_direction.dart';
import '../enum/group_application_status.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../model/group_info.dart';
import '../model/group_member_info.dart';
import '../model/group_application_info.dart';
import '../model/page_data.dart';

/// Parameters for querying group members filtered by their role.
class GroupMembersByRoleQueryParams {
  /// The unique identifier of the target group.
  final String groupId;

  /// The member role to filter by (e.g., owner, admin, member).
  final GroupMemberRole role;

  /// Maximum number of members returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Creates a [GroupMembersByRoleQueryParams] instance.
  GroupMembersByRoleQueryParams({
    required this.groupId,
    required this.role,
    this.pageSize = 20,
    this.isAscending,
  });
}

/// Paginated query executor for fetching group members by role.
///
/// Uses token-based pagination. Call [loadNextPage] repeatedly to
/// iterate through all matching members.
class GroupMembersByRoleQuery {
  final GroupMembersByRoleQueryParams _params;
  String _pageToken = '';
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [GroupMembersByRoleQuery] with the given [params].
  GroupMembersByRoleQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of group members matching the specified role.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageResult<GroupMemberInfo>> handler,
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
    return NCEngine.engine.getGroupMembersByRole(
      _params.groupId,
      RCIMIWGroupMemberRole.values[_params.role.index],
      option,
      callback: IRCIMIWGetGroupMembersByRoleCallback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken ?? '';
          _hasMore = _pageToken.isNotEmpty;
          handler(
            PageResult(
              data:
                  t?.data?.map((e) => GroupMemberInfo.fromRaw(e)).toList() ??
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

/// Parameters for querying groups the current user has joined, filtered by role.
class JoinedGroupsByRoleQueryParams {
  /// The role the current user holds in the groups to query.
  final GroupMemberRole role;

  /// Maximum number of groups returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Creates a [JoinedGroupsByRoleQueryParams] instance.
  JoinedGroupsByRoleQueryParams({
    required this.role,
    this.pageSize = 20,
    this.isAscending,
  });
}

/// Paginated query executor for fetching groups the current user has joined, filtered by role.
///
/// Uses token-based pagination. Call [loadNextPage] repeatedly to
/// iterate through all matching groups.
class JoinedGroupsByRoleQuery {
  final JoinedGroupsByRoleQueryParams _params;
  String _pageToken = '';
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [JoinedGroupsByRoleQuery] with the given [params].
  JoinedGroupsByRoleQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of joined groups where the user holds the specified role.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(OperationHandler<PageResult<GroupInfo>> handler) {
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
    return NCEngine.engine.getJoinedGroupsByRole(
      RCIMIWGroupMemberRole.values[_params.role.index],
      option,
      callback: IRCIMIWGetJoinedGroupsByRoleCallback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken ?? '';
          _hasMore = _pageToken.isNotEmpty;
          handler(
            PageResult(
              data:
                  t?.data?.map((e) => GroupInfo.fromRaw(e)).toList() ??
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

/// Parameters for querying group join/invite applications.
class GroupApplicationsQueryParams {
  /// The application directions to filter (e.g., sent, received).
  final List<GroupApplicationDirection> directions;

  /// The application statuses to filter (e.g., pending, accepted, rejected).
  final List<GroupApplicationStatus> status;

  /// Maximum number of applications returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Creates a [GroupApplicationsQueryParams] instance.
  GroupApplicationsQueryParams({
    required this.directions,
    required this.status,
    this.pageSize = 20,
    this.isAscending,
  });
}

/// Paginated query executor for fetching group applications.
///
/// Retrieves group join or invite requests filtered by direction and status.
/// Uses token-based pagination.
class GroupApplicationsQuery {
  final GroupApplicationsQueryParams _params;
  String _pageToken = '';
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [GroupApplicationsQuery] with the given [params].
  GroupApplicationsQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of group applications.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageData<GroupApplicationInfo>> handler,
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
    return NCEngine.engine.getGroupApplications(
      option,
      _params.directions
          .map((d) => RCIMIWGroupApplicationDirection.values[d.index])
          .toList(),
      _params.status
          .map((s) => RCIMIWGroupApplicationStatus.values[s.index])
          .toList(),
      callback: IRCIMIWGetGroupApplicationsCallback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken ?? '';
          _hasMore = _pageToken.isNotEmpty;
          handler(
            PageData(
              data:
                  t?.data
                      ?.map((e) => GroupApplicationInfo.fromRaw(e))
                      .toList() ??
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

/// Parameters for searching group members by display name.
///
/// The [groupId] is normally injected by the owning [GroupChannel] and is
/// therefore not exposed in the public constructor.
class SearchGroupMembersQueryParams {
  /// The unique identifier of the target group.
  ///
  /// Injected internally by [GroupChannel.createSearchGroupMembersQuery] and
  /// not set by SDK users.
  String groupId = '';

  /// The name (or partial name) to search for.
  final String memberName;

  /// Maximum number of members returned per page.
  final int pageSize;

  /// Sort order. `true` for ascending, `false` for descending, `null` for default.
  final bool? isAscending;

  /// Creates a [SearchGroupMembersQueryParams] instance.
  SearchGroupMembersQueryParams({
    required this.memberName,
    this.pageSize = 20,
    this.isAscending,
  });
}

/// Paginated query executor for searching group members by name.
///
/// Uses token-based pagination. Call [loadNextPage] repeatedly to
/// iterate through all matching members.
class SearchGroupMembersQuery {
  final SearchGroupMembersQueryParams _params;
  String _pageToken = '';
  bool _loading = false;
  bool _hasMore = true;

  /// Creates a [SearchGroupMembersQuery] with the given [params].
  SearchGroupMembersQuery(this._params);

  /// Whether more pages may still be available.
  bool get hasMore => _hasMore;

  /// Loads the next page of group members matching the search name.
  ///
  /// Returns the operation ID, or `-1` if a request is already in progress.
  Future<int> loadNextPage(
    OperationHandler<PageResult<GroupMemberInfo>> handler,
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
    return NCEngine.engine.searchGroupMembers(
      _params.groupId,
      _params.memberName,
      option,
      callback: IRCIMIWSearchGroupMembersCallback(
        onSuccess: (t) {
          _loading = false;
          _pageToken = t?.pageToken ?? '';
          _hasMore = _pageToken.isNotEmpty;
          handler(
            PageResult(
              data:
                  t?.data?.map((e) => GroupMemberInfo.fromRaw(e)).toList() ??
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
