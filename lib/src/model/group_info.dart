import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/group_member_role.dart';
import '../enum/group_join_permission.dart';
import '../enum/group_operation_permission.dart';
import '../enum/group_invite_handle_permission.dart';
import '../enum/group_member_info_edit_permission.dart';
import '../enum/group_status.dart';

RCIMIWGroupJoinPermission? _toRawJoinPermission(
  GroupJoinPermission? permission,
) {
  if (permission == null) {
    return null;
  }
  return RCIMIWGroupJoinPermission.values[permission.index];
}

RCIMIWGroupOperationPermission? _toRawOperationPermission(
  GroupOperationPermission? permission,
) {
  if (permission == null) {
    return null;
  }
  return RCIMIWGroupOperationPermission.values[permission.index];
}

RCIMIWGroupInviteHandlePermission? _toRawInviteHandlePermission(
  GroupInviteHandlePermission? permission,
) {
  if (permission == null) {
    return null;
  }
  return RCIMIWGroupInviteHandlePermission.values[permission.index];
}

RCIMIWGroupMemberInfoEditPermission? _toRawMemberInfoEditPermission(
  GroupMemberInfoEditPermission? permission,
) {
  if (permission == null) {
    return null;
  }
  return RCIMIWGroupMemberInfoEditPermission.values[permission.index];
}

/// Contains metadata and configuration for an IM group.
///
/// Includes basic info (name, avatar URL), permission settings,
/// membership details, and group status.
class GroupInfo {
  final RCIMIWGroupInfo _raw;
  GroupInfo._(this._raw);

  /// Creates a [GroupInfo] from an existing SDK object.
  static GroupInfo fromRaw(RCIMIWGroupInfo raw) => GroupInfo._(raw);

  /// Creates a [GroupInfo] with basic group details and editable metadata.
  GroupInfo({
    String? groupId,
    String? groupName,
    String? avatarUrl,
    String? introduction,
    String? notice,
    Map? extProfile,
    GroupJoinPermission? joinPermission,
    GroupOperationPermission? removeMemberPermission,
    GroupOperationPermission? invitePermission,
    GroupInviteHandlePermission? inviteHandlePermission,
    GroupOperationPermission? groupInfoEditPermission,
    GroupMemberInfoEditPermission? memberInfoEditPermission,
  }) : _raw = RCIMIWGroupInfo.create(
         groupId: groupId,
         groupName: groupName,
         portraitUri: avatarUrl,
         introduction: introduction,
         notice: notice,
         extProfile: extProfile,
         joinPermission: _toRawJoinPermission(joinPermission),
         removeMemberPermission: _toRawOperationPermission(
           removeMemberPermission,
         ),
         invitePermission: _toRawOperationPermission(invitePermission),
         inviteHandlePermission: _toRawInviteHandlePermission(
           inviteHandlePermission,
         ),
         groupInfoEditPermission: _toRawOperationPermission(
           groupInfoEditPermission,
         ),
         memberInfoEditPermission: _toRawMemberInfoEditPermission(
           memberInfoEditPermission,
         ),
       );

  /// The unique identifier of the group.
  String? get groupId => _raw.groupId;

  /// The display name of the group.
  String? get groupName => _raw.groupName;

  /// The URL of the group's avatar image.
  String? get avatarUrl => _raw.portraitUri;

  /// The group's introduction or description text.
  String? get introduction => _raw.introduction;

  /// The group announcement or notice text.
  String? get notice => _raw.notice;

  /// Extended profile data as key-value pairs.
  Map? get extProfile => _raw.extProfile;

  /// The permission level required for users to join the group.
  GroupJoinPermission? get joinPermission =>
      _raw.joinPermission != null
          ? GroupJoinPermission.values[_raw.joinPermission!.index]
          : null;

  /// The permission level required to remove members from the group.
  GroupOperationPermission? get removeMemberPermission =>
      _raw.removeMemberPermission != null
          ? GroupOperationPermission.values[_raw.removeMemberPermission!.index]
          : null;

  /// The permission level required to invite new members.
  GroupOperationPermission? get invitePermission =>
      _raw.invitePermission != null
          ? GroupOperationPermission.values[_raw.invitePermission!.index]
          : null;

  /// The permission setting for how group invitations are handled.
  GroupInviteHandlePermission? get inviteHandlePermission =>
      _raw.inviteHandlePermission != null
          ? GroupInviteHandlePermission.values[_raw
              .inviteHandlePermission!
              .index]
          : null;

  /// The permission level required to edit group information.
  GroupOperationPermission? get groupInfoEditPermission =>
      _raw.groupInfoEditPermission != null
          ? GroupOperationPermission.values[_raw.groupInfoEditPermission!.index]
          : null;

  /// The permission setting for editing member information.
  GroupMemberInfoEditPermission? get memberInfoEditPermission =>
      _raw.memberInfoEditPermission != null
          ? GroupMemberInfoEditPermission.values[_raw
              .memberInfoEditPermission!
              .index]
          : null;

  /// The user ID of the group creator.
  String? get creatorId => _raw.creatorId;

  /// The user ID of the current group owner.
  String? get ownerId => _raw.ownerId;

  /// The group creation timestamp (in milliseconds).
  int? get createTime => _raw.createTime;

  /// The total number of members in the group.
  int? get membersCount => _raw.membersCount;

  /// The timestamp when the current user joined the group (in milliseconds).
  int? get joinedTime => _raw.joinedTime;

  /// The current user's role in the group (e.g., owner, admin, member).
  GroupMemberRole? get role =>
      _raw.role != null ? GroupMemberRole.values[_raw.role!.index] : null;

  /// The current status of the group (e.g., active, dismissed).
  GroupStatus? get groupStatus =>
      _raw.groupStatus != null
          ? GroupStatus.values[_raw.groupStatus!.index]
          : null;

  /// The timestamp of the last group status change (in milliseconds).
  int? get groupStatusUpdateTime => _raw.groupStatusUpdateTime;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'groupName': groupName,
    'avatarUrl': avatarUrl,
    'introduction': introduction,
    'notice': notice,
    'extProfile': extProfile,
    'joinPermission': joinPermission?.name,
    'removeMemberPermission': removeMemberPermission?.name,
    'invitePermission': invitePermission?.name,
    'inviteHandlePermission': inviteHandlePermission?.name,
    'groupInfoEditPermission': groupInfoEditPermission?.name,
    'memberInfoEditPermission': memberInfoEditPermission?.name,
    'creatorId': creatorId,
    'ownerId': ownerId,
    'createTime': createTime,
    'membersCount': membersCount,
    'joinedTime': joinedTime,
    'role': role?.name,
    'groupStatus': groupStatus?.name,
    'groupStatusUpdateTime': groupStatusUpdateTime,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWGroupInfo get raw => _raw;
}
