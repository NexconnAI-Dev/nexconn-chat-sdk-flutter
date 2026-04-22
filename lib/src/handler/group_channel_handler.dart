import '../enum/group_operation.dart';
import '../enum/group_operation_type.dart';
import '../model/group_application_info.dart';
import '../model/group_info.dart';
import '../model/group_member_info.dart';

/// Event containing details of a group operation (e.g., member join, kick, mute).
class GroupOperationEventInfo {
  /// The group identifier where the operation occurred.
  final String? groupId;

  /// The member who performed the operation.
  final GroupMemberInfo? operatorInfo;

  /// The group information at the time of the operation.
  final GroupInfo? groupInfo;

  /// The type of group operation performed.
  final GroupOperation? operation;

  /// The members affected by this operation.
  final List<GroupMemberInfo>? memberInfos;

  /// The timestamp when the operation occurred.
  final int? operationTime;

  /// Creates a [GroupOperationEventInfo].
  const GroupOperationEventInfo({
    this.groupId,
    this.operatorInfo,
    this.groupInfo,
    this.operation,
    this.memberInfos,
    this.operationTime,
  });
}

/// Event fired when group information is changed.
class GroupInfoChangedEventInfo {
  /// The member who changed the group information.
  final GroupMemberInfo? operatorInfo;

  /// The complete group information after the change.
  final GroupInfo? fullGroupInfo;

  /// The changed fields of the group information.
  final GroupInfo? changedGroupInfo;

  /// The timestamp when the change occurred.
  final int? operationTime;

  /// Creates a [GroupInfoChangedEventInfo].
  const GroupInfoChangedEventInfo({
    this.operatorInfo,
    this.fullGroupInfo,
    this.changedGroupInfo,
    this.operationTime,
  });
}

/// Event fired when a group member's information is changed.
class GroupMemberInfoChangedEventInfo {
  /// The group identifier where the member info changed.
  final String? groupId;

  /// The member who performed the change.
  final GroupMemberInfo? operatorInfo;

  /// The updated member information.
  final GroupMemberInfo? memberInfo;

  /// The timestamp when the change occurred.
  final int? operationTime;

  /// Creates a [GroupMemberInfoChangedEventInfo].
  const GroupMemberInfoChangedEventInfo({
    this.groupId,
    this.operatorInfo,
    this.memberInfo,
    this.operationTime,
  });
}

/// Event fired when a group application (join request or invite) is received.
class GroupApplicationEventInfo {
  /// The group application details.
  final GroupApplicationInfo? info;

  /// Creates a [GroupApplicationEventInfo].
  const GroupApplicationEventInfo({this.info});
}

/// Event fired when the group favorites list changes, synced from the server.
class GroupFavoritesChangedSyncEvent {
  /// The group identifier whose favorites changed.
  final String? groupId;

  /// The type of favorites operation performed.
  final GroupOperationType? operationType;

  /// The user identifiers affected by the favorites change.
  final List<String>? userIds;

  /// The timestamp when the change occurred.
  final int? operationTime;

  /// Creates a [GroupFavoritesChangedSyncEvent].
  const GroupFavoritesChangedSyncEvent({
    this.groupId,
    this.operationType,
    this.userIds,
    this.operationTime,
  });
}

/// Callback invoked when a group operation occurs.
typedef OnGroupOperation = void Function(GroupOperationEventInfo event);

/// Callback invoked when group information changes.
typedef OnGroupInfoChanged = void Function(GroupInfoChangedEventInfo event);

/// Callback invoked when a group member's information changes.
typedef OnGroupMemberInfoChanged =
    void Function(GroupMemberInfoChangedEventInfo event);

/// Callback invoked when a group application event occurs.
typedef OnGroupApplicationEvent =
    void Function(GroupApplicationEventInfo event);

/// Callback invoked when group favorites change, synced from the server.
typedef OnGroupFavoritesChangedSync =
    void Function(GroupFavoritesChangedSyncEvent event);

/// Handler for group channel global events.
///
/// Register this handler via [NCEngine.addGroupChannelHandler] to receive
/// notifications about group operations, information changes, member updates,
/// application events, and favorites synchronization.
class GroupChannelHandler {
  /// Called when a group operation (join, kick, mute, etc.) occurs.
  final OnGroupOperation? onGroupOperation;

  /// Called when group information changes.
  final OnGroupInfoChanged? onGroupInfoChanged;

  /// Called when a group member's information changes.
  final OnGroupMemberInfoChanged? onGroupMemberInfoChanged;

  /// Called when a group application event (join request or invite) occurs.
  final OnGroupApplicationEvent? onGroupApplicationEvent;

  /// Called when group favorites change, synced from the server.
  final OnGroupFavoritesChangedSync? onGroupFavoritesChangedSync;

  /// Creates a [GroupChannelHandler].
  GroupChannelHandler({
    this.onGroupOperation,
    this.onGroupInfoChanged,
    this.onGroupMemberInfoChanged,
    this.onGroupApplicationEvent,
    this.onGroupFavoritesChangedSync,
  });
}
