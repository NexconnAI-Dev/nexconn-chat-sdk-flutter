import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/channel_type.dart';
import '../enum/group_join_permission.dart';
import '../enum/group_operation_permission.dart';
import '../enum/group_invite_handle_permission.dart';
import '../enum/group_member_info_edit_permission.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../model/favorite_info.dart';
import '../model/group_info.dart';
import '../model/group_member_info.dart';
import '../message/message.dart';
import '../model/paging_query_option.dart';
import '../model/paging_query_result.dart';
import '../model/leave_group_config.dart';
import '../query/group_query.dart';
import 'base_channel.dart';

/// Parameters for kicking members from a group channel.
class KickGroupMembersParams {
  /// The list of user IDs to remove from the group.
  final List<String> userIds;

  /// Configuration controlling post-kick behavior (e.g., whether to delete chat history).
  final LeaveGroupConfig config;

  /// Creates params with the given [userIds] and [config].
  KickGroupMembersParams({required this.userIds, required this.config});
}

/// Parameters for transferring group ownership to another member.
class TransferGroupOwnerParams {
  /// The user ID of the new group owner.
  final String newOwnerId;

  /// Whether the current owner should leave the group after transferring ownership.
  /// Defaults to `false`.
  final bool leaveAfterTransfer;

  /// Configuration controlling post-transfer behavior.
  final LeaveGroupConfig config;

  /// Creates params with the given [newOwnerId], optional [leaveAfterTransfer],
  /// and [config].
  TransferGroupOwnerParams({
    required this.newOwnerId,
    this.leaveAfterTransfer = false,
    required this.config,
  });
}

/// Parameters for updating a group member's profile information.
class SetGroupMemberInfoParams {
  /// The user ID of the member to update.
  final String userId;

  /// The new nickname for the member within the group. Defaults to empty string.
  final String nickname;

  /// Additional metadata for the member. Defaults to empty string.
  final String extra;

  /// Creates params with the given [userId], optional [nickname], and [extra].
  SetGroupMemberInfoParams({
    required this.userId,
    this.nickname = '',
    this.extra = '',
  });
}

/// Parameters for refusing a group invitation.
class RefuseGroupInviteParams {
  /// The user ID of the person who sent the invitation.
  final String inviterId;

  /// The reason for refusing the invitation. Defaults to empty string.
  final String reason;

  /// Creates params with the given [inviterId] and optional [reason].
  RefuseGroupInviteParams({required this.inviterId, this.reason = ''});
}

/// Parameters for accepting a group join application.
class AcceptGroupApplicationParams {
  /// The inviter's user ID.
  ///
  /// This should be empty when the user applied to join the group directly.
  /// It should be filled when the join request originated from an invitation.
  final String inviterId;

  /// The applicant's user ID.
  final String applicantId;

  /// Creates params with the given [applicantId] and optional [inviterId].
  AcceptGroupApplicationParams({
    this.inviterId = '',
    required this.applicantId,
  });
}

/// Parameters for refusing a group join application.
class RefuseGroupApplicationParams {
  /// The user ID of the person who referred the applicant.
  final String inviterId;

  /// The user ID of the applicant being refused.
  final String applicantId;

  /// The reason for refusing the application. Defaults to empty string.
  final String reason;

  /// Creates params with the given [inviterId], [applicantId], and optional [reason].
  RefuseGroupApplicationParams({
    required this.inviterId,
    required this.applicantId,
    this.reason = '',
  });
}

/// Parameters for creating a new group.
class CreateGroupParams {
  /// The unique identifier of the group to create.
  final String groupId;

  /// The display name of the group.
  final String? groupName;

  /// The URL of the group's avatar image.
  final String? avatarUrl;

  /// The group's introduction or description text.
  final String? introduction;

  /// The group announcement or notice text.
  final String? notice;

  /// Extended profile data as key-value pairs.
  final Map? extProfile;

  /// The permission level required for users to join the group.
  final GroupJoinPermission? joinPermission;

  /// The permission level required to invite new members.
  final GroupOperationPermission? invitePermission;

  /// The permission setting for how group invitations are handled.
  final GroupInviteHandlePermission? inviteHandlePermission;

  /// The permission level required to edit group information.
  final GroupOperationPermission? groupInfoEditPermission;

  /// The permission setting for editing member information.
  final GroupMemberInfoEditPermission? memberInfoEditPermission;

  /// The permission level required to remove members from the group.
  final GroupOperationPermission? removeMemberPermission;

  /// The list of user IDs to invite when creating the group.
  final List<String> inviteeUserIds;

  /// Creates params with the given group fields and [inviteeUserIds].
  CreateGroupParams({
    required this.groupId,
    this.groupName,
    this.avatarUrl,
    this.introduction,
    this.notice,
    this.extProfile,
    this.joinPermission,
    this.invitePermission,
    this.inviteHandlePermission,
    this.groupInfoEditPermission,
    this.memberInfoEditPermission,
    this.removeMemberPermission,
    required this.inviteeUserIds,
  });
}

/// Parameters for updating editable fields of a group.
///
/// Only fields that the client may modify are exposed here; read-only
/// metadata such as `creatorId`, `createTime`, and `membersCount` is
/// intentionally omitted. The target group ID is taken from the owning
/// [GroupChannel]'s `channelId`.
class UpdateGroupInfoParams {
  /// The new display name of the group.
  final String? groupName;

  /// The new URL of the group's avatar image.
  final String? avatarUrl;

  /// The new group announcement or notice text.
  final String? notice;

  /// The new extended profile data as key-value pairs.
  final Map? extProfile;

  /// The new group introduction or description text.
  final String? introduction;

  /// The new permission level required for users to join the group.
  final GroupJoinPermission? joinPermission;

  /// The new permission level required to invite new members.
  final GroupOperationPermission? invitePermission;

  /// The new permission setting for how group invitations are handled.
  final GroupInviteHandlePermission? inviteHandlePermission;

  /// The new permission level required to edit group information.
  final GroupOperationPermission? groupInfoEditPermission;

  /// The new permission setting for editing member information.
  final GroupMemberInfoEditPermission? memberInfoEditPermission;

  /// The new permission level required to remove members from the group.
  final GroupOperationPermission? removeMemberPermission;

  /// Creates params for updating editable group fields.
  UpdateGroupInfoParams({
    this.groupName,
    this.avatarUrl,
    this.notice,
    this.extProfile,
    this.introduction,
    this.joinPermission,
    this.invitePermission,
    this.inviteHandlePermission,
    this.groupInfoEditPermission,
    this.memberInfoEditPermission,
    this.removeMemberPermission,
  });
}

/// Parameters for searching joined groups by name.
class SearchJoinedGroupsParams {
  /// The group name keyword to search for.
  final String groupName;

  /// Paging options for the search query.
  final PagingQueryOption option;

  /// Creates params with the given [groupName] and [option].
  SearchJoinedGroupsParams({required this.groupName, required this.option});
}

/// Parameters for sending a message to designated users within a group.
class SendDesignatedMessageParams {
  /// The message to send.
  final Message message;

  /// The list of user IDs who should receive the message.
  final List<String> userIds;

  /// Creates params with the given [message] and [userIds].
  SendDesignatedMessageParams({required this.message, required this.userIds});
}

/// A channel representing a group channel with multiple members.
///
/// [GroupChannel] extends [BaseChannel] with group-specific operations such as
/// member management (invite, kick, set roles), group info updates,
/// ownership transfer, application/invitation handling, and favorites management.
class GroupChannel extends BaseChannel {
  /// Creates a [GroupChannel] with the given [channelId] and optional
  /// channel metadata inherited from [BaseChannel].
  GroupChannel(
    String channelId, {
    super.unreadCount,
    super.mentionedCount,
    super.mentionedMeCount,
    super.isPinned,
    super.draft,
    super.latestMessage,
    super.notificationLevel,
    super.firstUnreadMsgSendTime,
    super.operationTime,
    super.translateStrategy,
  }) : super(ChannelType.group, channelId);

  /// Creates a [GroupChannel] from a [ChannelIdentifier].
  GroupChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId);

  /// Updates editable group information (name, avatar URL, permissions, etc.).
  ///
  /// [params] contains the updated group fields.
  /// The [handler] is called with `(null, null)` on success, or
  /// `(errorInfo, NCError)` on failure. `errorInfo` carries the underlying
  /// failure description returned by the native layer (typically the list of
  /// field keys that failed to update).
  Future<int> updateInfo(
    UpdateGroupInfoParams params,
    OperationHandler<String> handler,
  ) {
    final info = GroupInfo(
      groupId: channelId,
      groupName: params.groupName,
      avatarUrl: params.avatarUrl,
      introduction: params.introduction,
      notice: params.notice,
      extProfile: params.extProfile,
      joinPermission: params.joinPermission,
      removeMemberPermission: params.removeMemberPermission,
      invitePermission: params.invitePermission,
      inviteHandlePermission: params.inviteHandlePermission,
      groupInfoEditPermission: params.groupInfoEditPermission,
      memberInfoEditPermission: params.memberInfoEditPermission,
    );
    return NCEngine.engine.updateGroupInfo(
      info.raw,
      callback: IRCIMIWGroupInfoUpdatedCallback(
        onGroupInfoUpdated: (code, errorInfo) {
          final error = Converter.toNCError(code);
          handler(errorInfo, error);
        },
      ),
    );
  }

  /// Kicks (removes) members from this group.
  ///
  /// [params] specifies the user IDs and leave configuration.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> kickMembers(KickGroupMembersParams params, ErrorHandler handler) {
    return NCEngine.engine.kickGroupMembers(
      channelId,
      params.userIds,
      params.config.raw,
      callback: IRCIMIWKickGroupMembersCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Leaves this group channel.
  ///
  /// [config] optionally controls post-leave behavior (e.g., whether to clear
  /// chat history). When omitted, the default [LeaveGroupConfig] is used.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> leave(LeaveGroupConfig? config, ErrorHandler handler) {
    return NCEngine.engine.quitGroup(
      channelId,
      (config ?? LeaveGroupConfig()).raw,
      callback: IRCIMIWQuitGroupCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Disbands (dismisses) this group, removing all members.
  ///
  /// Only the group owner can perform this operation.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> dismiss(ErrorHandler handler) {
    return NCEngine.engine.dismissGroup(
      channelId,
      callback: IRCIMIWDismissGroupCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Joins this group channel.
  ///
  /// The [handler] receives a result code on success, or an error on failure.
  Future<int> join(OperationHandler<int> handler) {
    return NCEngine.engine.joinGroup(
      channelId,
      callback: IRCIMIWJoinGroupCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Transfers group ownership to another member.
  ///
  /// [params] specifies the new owner, whether to quit after transfer, and configuration.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> transferOwner(
    TransferGroupOwnerParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.transferGroupOwner(
      channelId,
      params.newOwnerId,
      params.leaveAfterTransfer,
      params.config.raw,
      callback: IRCIMIWTransferGroupOwnerCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Promotes the specified users to group admin role.
  ///
  /// [userIds] is the list of user IDs to promote.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> addAdmins(List<String> userIds, ErrorHandler handler) {
    return NCEngine.engine.addGroupManagers(
      channelId,
      userIds,
      callback: IRCIMIWAddGroupManagersCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes the group admin role from the specified users.
  ///
  /// [userIds] is the list of user IDs to demote.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> removeAdmins(List<String> userIds, ErrorHandler handler) {
    return NCEngine.engine.removeGroupManagers(
      channelId,
      userIds,
      callback: IRCIMIWRemoveGroupManagersCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves member information for the specified user IDs in this group.
  ///
  /// [userIds] is the list of user IDs to query.
  /// The [handler] receives a list of [GroupMemberInfo] on success, or an error on failure.
  Future<int> getMembers(
    List<String> userIds,
    OperationHandler<List<GroupMemberInfo>> handler,
  ) {
    return NCEngine.engine.getGroupMembers(
      channelId,
      userIds,
      callback: IRCIMIWGetGroupMembersCallback(
        onSuccess:
            (t) => handler(
              t?.map((e) => GroupMemberInfo.fromRaw(e)).toList(),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Updates a member's profile information within this group.
  ///
  /// [params] specifies the user ID, nickname, and extra data to update.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> setMemberInfo(
    SetGroupMemberInfoParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.setGroupMemberInfo(
      channelId,
      params.userId,
      params.nickname,
      params.extra,
      callback: IRCIMIWSetGroupMemberInfoCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Creates a paginated query for searching group members by name.
  ///
  /// [params] specifies the search keyword and page size; `groupId` is
  /// injected automatically from this channel's [channelId].
  SearchGroupMembersQuery createSearchGroupMembersQuery(
    SearchGroupMembersQueryParams params,
  ) {
    params.groupId = channelId;
    return SearchGroupMembersQuery(params);
  }

  /// Invites users to join this group.
  ///
  /// [userIds] is the list of user IDs to invite.
  /// The [handler] receives a result code on success, or an error on failure.
  Future<int> inviteUsers(List<String> userIds, OperationHandler<int> handler) {
    return NCEngine.engine.inviteUsersToGroup(
      channelId,
      userIds,
      callback: IRCIMIWInviteUsersToGroupCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Accepts a group invitation from the specified inviter.
  ///
  /// [inviterId] is the user ID of the person who sent the invitation.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> acceptInvite(String inviterId, ErrorHandler handler) {
    return NCEngine.engine.acceptGroupInvite(
      channelId,
      inviterId,
      callback: IRCIMIWAcceptGroupInviteCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Refuses a group invitation.
  ///
  /// [params] specifies the inviter and an optional reason for refusal.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> refuseInvite(
    RefuseGroupInviteParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.refuseGroupInvite(
      channelId,
      params.inviterId,
      params.reason,
      callback: IRCIMIWRefuseGroupInviteCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Accepts a user's application to join this group.
  ///
  /// [params.inviterId] is the inviter's user ID. Pass an empty string when
  /// the applicant requested to join the group directly.
  /// [params.applicantId] is the user ID of the applicant being accepted.
  ///
  /// The [handler] receives the SDK `processCode` on success, or an error on
  /// failure. When the group requires invitee confirmation for invitation-based
  /// joins, the process code may indicate a pending acceptance state instead of
  /// direct success.
  Future<int> acceptApplication(
    AcceptGroupApplicationParams params,
    OperationHandler<int> handler,
  ) {
    return NCEngine.engine.acceptGroupApplication(
      channelId,
      params.inviterId,
      params.applicantId,
      callback: IRCIMIWAcceptGroupApplicationCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Refuses a user's application to join this group.
  ///
  /// [params] specifies the inviter, applicant, and an optional reason for refusal.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> refuseApplication(
    RefuseGroupApplicationParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.refuseGroupApplication(
      channelId,
      params.inviterId,
      params.applicantId,
      params.reason,
      callback: IRCIMIWRefuseGroupApplicationCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets a remark (alias/note) for this group visible only to the current user.
  ///
  /// [remark] is the remark text to set.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> setRemark(String remark, ErrorHandler handler) {
    return NCEngine.engine.setGroupRemark(
      channelId,
      remark,
      callback: IRCIMIWSetGroupRemarkCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Adds the specified users to the favorites (followed members) list for this group.
  ///
  /// [userIds] is the list of user IDs to add to favorites.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> addFavorites(List<String> userIds, ErrorHandler handler) {
    return NCEngine.engine.addGroupFollows(
      channelId,
      userIds,
      callback: IRCIMIWAddGroupFollowsCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes the specified users from the favorites (followed members) list for this group.
  ///
  /// [userIds] is the list of user IDs to remove from favorites.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> removeFavorites(List<String> userIds, ErrorHandler handler) {
    return NCEngine.engine.removeGroupFollows(
      channelId,
      userIds,
      callback: IRCIMIWRemoveGroupFollowsCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the favorites (followed members) list for this group.
  ///
  /// The [handler] receives a list of [FavoriteInfo] on success, or an error on failure.
  Future<int> getFavorites(OperationHandler<List<FavoriteInfo>> handler) {
    return NCEngine.engine.getGroupFollows(
      channelId,
      callback: IRCIMIWGetGroupFollowsCallback(
        onSuccess:
            (t) =>
                handler(t?.map((e) => FavoriteInfo.fromRaw(e)).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Creates a paginated query for listing group members filtered by role.
  ///
  /// [params] configures the group ID, role filter, and pagination options.
  static GroupMembersByRoleQuery createGroupMembersByRoleQuery(
    GroupMembersByRoleQueryParams params,
  ) {
    return GroupMembersByRoleQuery(params);
  }

  /// Creates a paginated query for listing groups the current user has joined,
  /// filtered by role.
  ///
  /// [params] configures the role filter and pagination options.
  static JoinedGroupsByRoleQuery createJoinedGroupsByRoleQuery(
    JoinedGroupsByRoleQueryParams params,
  ) {
    return JoinedGroupsByRoleQuery(params);
  }

  /// Creates a paginated query for listing pending group join applications.
  ///
  /// [params] configures the group ID and pagination options.
  static GroupApplicationsQuery createGroupApplicationsQuery(
    GroupApplicationsQueryParams params,
  ) {
    return GroupApplicationsQuery(params);
  }

  /// Creates a new group with the specified information and initial invitees.
  ///
  /// [params] specifies the group info and list of user IDs to invite.
  /// The [handler] receives the SDK [processCode] on success, or an optional
  /// list of `errorKeys` together with an [NCError] on failure. Callers that
  /// need the newly-created [GroupInfo] should follow up with
  /// [GroupChannel.getGroupsInfo].
  static Future<int> createGroup(
    CreateGroupParams params,
    OperationWithProcessCodeHandler<List<String>> handler,
  ) {
    final info = GroupInfo(
      groupId: params.groupId,
      groupName: params.groupName,
      avatarUrl: params.avatarUrl,
      introduction: params.introduction,
      notice: params.notice,
      extProfile: params.extProfile,
      joinPermission: params.joinPermission,
      removeMemberPermission: params.removeMemberPermission,
      invitePermission: params.invitePermission,
      inviteHandlePermission: params.inviteHandlePermission,
      groupInfoEditPermission: params.groupInfoEditPermission,
      memberInfoEditPermission: params.memberInfoEditPermission,
    );
    return NCEngine.engine.createGroup(
      info.raw,
      params.inviteeUserIds,
      callback: IRCIMIWCreateGroupCallback(
        onSuccess: (processCode) => handler(null, processCode, null),
        onError:
            (code, errorInfo) => handler(
              errorInfo != null ? [errorInfo] : null,
              null,
              Converter.toNCError(code, errorMessage: errorInfo),
            ),
      ),
    );
  }

  /// Retrieves group information for the specified group IDs.
  ///
  /// [groupIds] is the list of group IDs to query.
  /// The [handler] receives a list of [GroupInfo] on success, or an error on failure.
  static Future<int> getGroupsInfo(
    List<String> groupIds,
    OperationHandler<List<GroupInfo>> handler,
  ) {
    return NCEngine.engine.getGroupsInfo(
      groupIds,
      callback: IRCIMIWGetGroupsInfoCallback(
        onSuccess:
            (t) => handler(t?.map((e) => GroupInfo.fromRaw(e)).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Searches the current user's joined groups by group name.
  ///
  /// [params] specifies the search keyword and paging options.
  /// The [handler] receives a paginated [PagingQueryResult] of [GroupInfo] on success,
  /// or an error on failure.
  static Future<int> searchJoinedGroups(
    SearchJoinedGroupsParams params,
    OperationHandler<PagingQueryResult<GroupInfo>> handler,
  ) {
    return NCEngine.engine.searchJoinedGroups(
      params.groupName,
      params.option.raw,
      callback: IRCIMIWSearchJoinedGroupsCallback(
        onSuccess: (t) {
          final result =
              t != null
                  ? PagingQueryResult.fromRaw(
                    t,
                    t.data?.map((e) => GroupInfo.fromRaw(e)).toList(),
                  )
                  : null;
          handler(result, null);
        },
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves information about groups the current user has joined,
  /// optionally filtered by specific group IDs.
  ///
  /// [groupIds] is the list of group IDs to filter by.
  /// The [handler] receives a list of [GroupInfo] on success, or an error on failure.
  static Future<int> getJoinedGroups(
    List<String> groupIds,
    OperationHandler<List<GroupInfo>> handler,
  ) {
    return NCEngine.engine.getJoinedGroups(
      groupIds,
      callback: IRCIMIWGetJoinedGroupsCallback(
        onSuccess:
            (t) => handler(t?.map((e) => GroupInfo.fromRaw(e)).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }
}
