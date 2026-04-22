import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String? _optionalText(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  ({Map<String, String>? value, bool hasError}) _parseExtProfile(
    Object? value,
    String action,
  ) {
    final text = _optionalText(value);
    if (text == null) {
      return (value: null, hasError: false);
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        showResult('$action [onError]', {
          'error': 'ExtProfileJson must be a JSON object',
        });
        return (value: null, hasError: true);
      }

      return (
        value: decoded.map<String, String>(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        ),
        hasError: false,
      );
    } catch (_) {
      showResult('$action [onError]', {
        'error': 'ExtProfileJson is not valid JSON',
      });
      return (value: null, hasError: true);
    }
  }

  T? _enumByIndex<T>(List<T> values, Object? value) {
    final index = int.tryParse(value?.toString() ?? '');
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  Future<String?> _pickGroupId() async {
    final args = await showParamsDialog(
      context,
      title: '输入群组ID',
      params: [(label: 'GroupId', hint: 'groupId', isNumber: false)],
    );
    return args?['GroupId'];
  }

  void _createGroup() async {
    final args = await showParamsDialog(
      context,
      title: '创建群组',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'GroupName', hint: 'groupName', isNumber: false),
        (label: 'AvatarUrl', hint: 'avatar url', isNumber: false),
        (label: 'Introduction', hint: 'group introduction', isNumber: false),
        (label: 'Notice', hint: 'group notice', isNumber: false),
        (label: 'ExtProfileJson', hint: '{"k":"v"}', isNumber: false),
        (
          label:
              'JoinPermission(0=ownerverify,1=free,2=owneroradminverify,3=nooneallowed)',
          hint: '1',
          isNumber: true
        ),
        (
          label: 'RemoveMemberPermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '0',
          isNumber: true
        ),
        (
          label: 'InvitePermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '0',
          isNumber: true
        ),
        (
          label: 'InviteHandlePermission(0=free,1=inviteeverify)',
          hint: '0',
          isNumber: true
        ),
        (
          label: 'GroupInfoEditPermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '0',
          isNumber: true
        ),
        (
          label:
              'MemberInfoEditPermission(0=owneroradminorself,1=ownerorself,2=self)',
          hint: '0',
          isNumber: true
        ),
        (label: 'InviteeUserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final invitees = (args['InviteeUserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final extProfileResult = _parseExtProfile(
      args['ExtProfileJson'],
      'createGroup',
    );
    if (extProfileResult.hasError) return;
    final createParams = CreateGroupParams(
      groupId: _optionalText(args['GroupId']) ?? '',
      groupName: _optionalText(args['GroupName']) ?? '',
      avatarUrl: _optionalText(args['AvatarUrl']),
      introduction: _optionalText(args['Introduction']),
      notice: _optionalText(args['Notice']),
      extProfile: extProfileResult.value,
      joinPermission: _enumByIndex<GroupJoinPermission>(
        GroupJoinPermission.values,
        args[
            'JoinPermission(0=ownerverify,1=free,2=owneroradminverify,3=nooneallowed)'],
      ),
      removeMemberPermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['RemoveMemberPermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      invitePermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['InvitePermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      inviteHandlePermission: _enumByIndex<GroupInviteHandlePermission>(
        GroupInviteHandlePermission.values,
        args['InviteHandlePermission(0=free,1=inviteeverify)'],
      ),
      groupInfoEditPermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['GroupInfoEditPermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      memberInfoEditPermission: _enumByIndex<GroupMemberInfoEditPermission>(
        GroupMemberInfoEditPermission.values,
        args[
            'MemberInfoEditPermission(0=owneroradminorself,1=ownerorself,2=self)'],
      ),
      inviteeUserIds: invitees,
    );
    showInput('createGroup', {
      'groupId': createParams.groupId,
      'groupName': createParams.groupName,
      'avatarUrl': createParams.avatarUrl,
      'introduction': createParams.introduction,
      'notice': createParams.notice,
      'extProfile': createParams.extProfile,
      'joinPermission': createParams.joinPermission?.name,
      'removeMemberPermission': createParams.removeMemberPermission?.name,
      'invitePermission': createParams.invitePermission?.name,
      'inviteHandlePermission': createParams.inviteHandlePermission?.name,
      'groupInfoEditPermission': createParams.groupInfoEditPermission?.name,
      'memberInfoEditPermission': createParams.memberInfoEditPermission?.name,
      'inviteeUserIds': invitees,
    });
    await GroupChannel.createGroup(
      createParams,
      (errorKeys, processCode, error) {
        showResult(
            'createGroup',
            hasError(error)
                ? {
                    ...?error?.toJson(),
                    'errorKeys': errorKeys,
                    'processCode': processCode,
                  }
                : {
                    'groupId': createParams.groupId,
                    'processCode': processCode,
                  });
      },
    );
  }

  void _updateInfo() async {
    final args = await showParamsDialog(
      context,
      title: '更新群组信息',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'GroupName', hint: 'new name', isNumber: false),
        (label: 'AvatarUrl', hint: 'avatar url', isNumber: false),
        (label: 'Introduction', hint: 'group introduction', isNumber: false),
        (label: 'Notice', hint: 'group notice', isNumber: false),
        (label: 'ExtProfileJson', hint: '{"k":"v"}', isNumber: false),
        (
          label:
              'JoinPermission(0=ownerverify,1=free,2=owneroradminverify,3=nooneallowed)',
          hint: '(optional)',
          isNumber: true
        ),
        (
          label: 'RemoveMemberPermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '(optional)',
          isNumber: true
        ),
        (
          label: 'InvitePermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '(optional)',
          isNumber: true
        ),
        (
          label: 'InviteHandlePermission(0=free,1=inviteeverify)',
          hint: '(optional)',
          isNumber: true
        ),
        (
          label: 'GroupInfoEditPermission(0=owner,1=owneroradmin,2=everyone)',
          hint: '(optional)',
          isNumber: true
        ),
        (
          label:
              'MemberInfoEditPermission(0=owneroradminorself,1=ownerorself,2=self)',
          hint: '(optional)',
          isNumber: true
        ),
      ],
    );
    if (args == null || !mounted) return;
    final portraitPath = await pickLocalFile(FilePickType.image);
    final groupId = args['GroupId'] ?? '';
    final extProfileResult = _parseExtProfile(
      args['ExtProfileJson'],
      'updateInfo',
    );
    if (extProfileResult.hasError) return;
    final updateParams = UpdateGroupInfoParams(
      groupName: _optionalText(args['GroupName']),
      avatarUrl: _optionalText(portraitPath ?? args['AvatarUrl']),
      introduction: _optionalText(args['Introduction']),
      notice: _optionalText(args['Notice']),
      extProfile: extProfileResult.value,
      joinPermission: _enumByIndex<GroupJoinPermission>(
        GroupJoinPermission.values,
        args[
            'JoinPermission(0=ownerverify,1=free,2=owneroradminverify,3=nooneallowed)'],
      ),
      removeMemberPermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['RemoveMemberPermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      invitePermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['InvitePermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      inviteHandlePermission: _enumByIndex<GroupInviteHandlePermission>(
        GroupInviteHandlePermission.values,
        args['InviteHandlePermission(0=free,1=inviteeverify)'],
      ),
      groupInfoEditPermission: _enumByIndex<GroupOperationPermission>(
        GroupOperationPermission.values,
        args['GroupInfoEditPermission(0=owner,1=owneroradmin,2=everyone)'],
      ),
      memberInfoEditPermission: _enumByIndex<GroupMemberInfoEditPermission>(
        GroupMemberInfoEditPermission.values,
        args[
            'MemberInfoEditPermission(0=owneroradminorself,1=ownerorself,2=self)'],
      ),
    );
    final channel = GroupChannel(groupId);
    showInput('updateInfo', {
      'groupId': groupId,
      'groupName': args['GroupName'] ?? '',
      'avatarUrl': portraitPath,
      'introduction': args['Introduction'] ?? '',
      'notice': args['Notice'] ?? '',
      'extProfile': args['ExtProfileJson'] ?? '',
    });
    await channel.updateInfo(updateParams, (errorInfo, error) {
      showResult('updateInfo', {
        'error': error?.toJson(),
        if (errorInfo != null) 'errorInfo': errorInfo,
      });
    });
  }

  void _kickMembers() async {
    final args = await showParamsDialog(
      context,
      title: '踢出群成员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
        (label: 'Reason', hint: '(optional)', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final groupId = args['GroupId'] ?? '';
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(groupId);
    showInput('kickMembers', {
      'groupId': groupId,
      'userIds': userIds,
      'reason': args['Reason'] ?? '',
    });
    await channel.kickMembers(
      KickGroupMembersParams(
        userIds: userIds,
        config: LeaveGroupConfig(),
      ),
      (error) => showResult('kickMembers', error?.toJson()),
    );
  }

  void _leaveGroup() async {
    final groupId = await _pickGroupId();
    if (groupId == null || !mounted) return;
    final channel = GroupChannel(groupId);
    showInput('leaveGroup', {'groupId': groupId});
    await channel.leave(
      LeaveGroupConfig(),
      (error) => showResult('leaveGroup', error?.toJson()),
    );
  }

  void _dismissGroup() async {
    final groupId = await _pickGroupId();
    if (groupId == null || !mounted) return;
    final channel = GroupChannel(groupId);
    showInput('dismissGroup', {'groupId': groupId});
    await channel.dismiss(
      (error) => showResult('dismissGroup', error?.toJson()),
    );
  }

  void _inviteUsers() async {
    final args = await showParamsDialog(
      context,
      title: '邀请用户入群',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final groupId = args['GroupId'] ?? '';
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(groupId);
    showInput('inviteUsers', {'groupId': groupId, 'userIds': userIds});
    await channel.inviteUsers(userIds, (processCode, error) {
      showResult('inviteUsers',
          hasError(error) ? error?.toJson() : {'processCode': processCode});
    });
  }

  void _acceptInvite() async {
    final args = await showParamsDialog(
      context,
      title: '接受群邀请',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'InviterId', hint: 'inviter userId', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('acceptInvite', {
      'groupId': args['GroupId'] ?? '',
      'inviterId': args['InviterId'] ?? '',
    });
    await channel.acceptInvite(
      args['InviterId'] ?? '',
      (error) => showResult('acceptInvite', error?.toJson()),
    );
  }

  void _refuseInvite() async {
    final args = await showParamsDialog(
      context,
      title: '拒绝群邀请',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'InviterId', hint: 'inviter userId', isNumber: false),
        (label: 'Reason', hint: '(optional)', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('refuseInvite', {
      'groupId': args['GroupId'] ?? '',
      'inviterId': args['InviterId'] ?? '',
      'reason': args['Reason'] ?? '',
    });
    await channel.refuseInvite(
      RefuseGroupInviteParams(
        inviterId: args['InviterId'] ?? '',
        reason: args['Reason'] ?? '',
      ),
      (error) => showResult('refuseInvite', error?.toJson()),
    );
  }

  void _transferOwner() async {
    final args = await showParamsDialog(
      context,
      title: '转让群主',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'NewOwnerId', hint: 'new owner userId', isNumber: false),
        (label: 'QuitGroup(0/1)', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('transferOwner', {
      'groupId': args['GroupId'] ?? '',
      'newOwnerId': args['NewOwnerId'] ?? '',
      'leaveAfterTransfer': args['QuitGroup(0/1)'] == '1',
    });
    await channel.transferOwner(
      TransferGroupOwnerParams(
        newOwnerId: args['NewOwnerId'] ?? '',
        leaveAfterTransfer: args['QuitGroup(0/1)'] == '1',
        config: LeaveGroupConfig(),
      ),
      (error) => showResult('transferOwner', error?.toJson()),
    );
  }

  void _addAdmins() async {
    final args = await showParamsDialog(
      context,
      title: '设置群管理员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('addAdmins', {
      'groupId': args['GroupId'] ?? '',
      'userIds': userIds,
    });
    await channel.addAdmins(userIds, (error) {
      showResult('addAdmins', error?.toJson());
    });
  }

  void _removeAdmins() async {
    final args = await showParamsDialog(
      context,
      title: '取消群管理员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('removeAdmins', {
      'groupId': args['GroupId'] ?? '',
      'userIds': userIds,
    });
    await channel.removeAdmins(userIds, (error) {
      showResult('removeAdmins', error?.toJson());
    });
  }

  void _setMemberInfo() async {
    final args = await showParamsDialog(
      context,
      title: '设置群成员信息',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserId', hint: 'userId', isNumber: false),
        (label: 'Nickname', hint: 'nickname', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('setMemberInfo', {
      'groupId': args['GroupId'] ?? '',
      'userId': args['UserId'] ?? '',
      'nickname': args['Nickname'] ?? '',
    });
    await channel.setMemberInfo(
      SetGroupMemberInfoParams(
          userId: args['UserId'] ?? '', nickname: args['Nickname'] ?? ''),
      (error) => showResult('setMemberInfo', error?.toJson()),
    );
  }

  void _getMembers() async {
    final args = await showParamsDialog(
      context,
      title: '获取群成员信息',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('getMembers', {
      'groupId': args['GroupId'] ?? '',
      'userIds': userIds,
    });
    await channel.getMembers(userIds, (members, error) {
      showResult(
          'getMembers',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': members?.length,
                  'members': members?.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _addFavorites() async {
    final args = await showParamsDialog(
      context,
      title: '关注群成员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('addFavorites', {
      'groupId': args['GroupId'] ?? '',
      'userIds': userIds,
    });
    await channel.addFavorites(userIds, (error) {
      showResult('addFavorites', error?.toJson());
    });
  }

  void _removeFavorites() async {
    final args = await showParamsDialog(
      context,
      title: '取消关注群成员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = GroupChannel(args['GroupId'] ?? '');
    showInput('removeFavorites', {
      'groupId': args['GroupId'] ?? '',
      'userIds': userIds,
    });
    await channel.removeFavorites(userIds, (error) {
      showResult('removeFavorites', error?.toJson());
    });
  }

  void _getGroupsInfo() async {
    final args = await showParamsDialog(
      context,
      title: '获取群组信息',
      params: [(label: 'GroupIds(comma)', hint: 'gid1,gid2', isNumber: false)],
    );
    if (args == null || !mounted) return;
    final groupIds = (args['GroupIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('getGroupsInfo', {'groupIds': groupIds});
    await GroupChannel.getGroupsInfo(groupIds, (infos, error) {
      showResult(
          'getGroupsInfo',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': infos?.length,
                  'groups': infos?.map((e) => e.toJson()).toList()
                });
    });
  }

  void _getGroupApplications() async {
    final args = await showParamsDialog(
      context,
      title: '获取群申请列表',
      params: [
        (label: 'PageSize', hint: '20', isNumber: true),
        (label: 'Ascending(0=desc,1=asc)', hint: '(optional)', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final ascStr = args['Ascending(0=desc,1=asc)'] ?? '';
    final bool? isAscending = ascStr.isEmpty ? null : ascStr == '1';
    showInput('getGroupApplications', {
      'pageSize': int.tryParse(args['PageSize'] ?? '20') ?? 20,
      'isAscending': isAscending,
      'directions': [GroupApplicationDirection.applicationreceived.name],
      'status': [GroupApplicationStatus.adminunhandled.name],
    });
    await GroupChannel.createGroupApplicationsQuery(
        GroupApplicationsQueryParams(
      directions: [GroupApplicationDirection.applicationreceived],
      status: [GroupApplicationStatus.adminunhandled],
      pageSize: int.tryParse(args['PageSize'] ?? '20') ?? 20,
      isAscending: isAscending,
    )).loadNextPage(
      (result, error) {
        showResult(
            'getGroupApplications',
            hasError(error)
                ? error?.toJson()
                : {
                    'count': result?.data.length ?? 0,
                    'applications':
                        result?.data.map((e) => e.toJson()).toList(),
                  });
      },
    );
  }

  void _groupMembersByRoleQuery() async {
    final args = await showParamsDialog(
      context,
      title: '按角色获取群成员',
      params: [
        (label: 'GroupId', hint: 'groupId', isNumber: false),
        (label: 'Role(0=owner,1=admin,2=member)', hint: '2', isNumber: true),
        (label: 'PageSize', hint: '20', isNumber: true),
        (label: 'Ascending(0=desc,1=asc)', hint: '(optional)', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final ascStr = args['Ascending(0=desc,1=asc)'] ?? '';
    final bool? isAscending = ascStr.isEmpty ? null : ascStr == '1';
    showInput('GroupMembersByRoleQuery', {
      'groupId': args['GroupId'] ?? '',
      'role': GroupMemberRole
          .values[
              int.tryParse(args['Role(0=owner,1=admin,2=member)'] ?? '2') ?? 2]
          .name,
      'pageSize': int.tryParse(args['PageSize'] ?? '20') ?? 20,
      'isAscending': isAscending,
    });
    final query = GroupChannel.createGroupMembersByRoleQuery(
        GroupMembersByRoleQueryParams(
      groupId: args['GroupId'] ?? '',
      role: GroupMemberRole.values[
          int.tryParse(args['Role(0=owner,1=admin,2=member)'] ?? '2') ?? 2],
      pageSize: int.tryParse(args['PageSize'] ?? '20') ?? 20,
      isAscending: isAscending,
    ));
    await query.loadNextPage((result, error) {
      showResult(
          'GroupMembersByRoleQuery',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': result?.data.length,
                  'members': result?.data.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _joinedGroupsQuery() async {
    final args = await showParamsDialog(
      context,
      title: '查询已加入群组',
      params: [
        (label: 'PageSize', hint: '20', isNumber: true),
        (label: 'Ascending(0=desc,1=asc)', hint: '(optional)', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final ascStr = args['Ascending(0=desc,1=asc)'] ?? '';
    final bool? isAscending = ascStr.isEmpty ? null : ascStr == '1';
    showInput('joinedGroupsQuery', {
      'role': GroupMemberRole.normal.name,
      'pageSize': int.tryParse(args['PageSize'] ?? '20') ?? 20,
      'isAscending': isAscending,
    });
    final query = GroupChannel.createJoinedGroupsByRoleQuery(
        JoinedGroupsByRoleQueryParams(
      role: GroupMemberRole.normal,
      pageSize: int.tryParse(args['PageSize'] ?? '20') ?? 20,
      isAscending: isAscending,
    ));
    await query.loadNextPage((result, error) {
      showResult(
          'joinedGroupsQuery',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': result?.data.length,
                  'groupIds': result?.data.map((g) => g.groupId).toList(),
                });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('群组相关')),
      body: ListView(
        children: [
          ApiSection(
            title: '群组管理',
            children: [
              ApiButton(label: '创建群组', onPressed: _createGroup),
              ApiButton(label: '更新群组信息', onPressed: _updateInfo),
              ApiButton(label: '解散群组', onPressed: _dismissGroup),
              ApiButton(label: '退出群组', onPressed: _leaveGroup),
              ApiButton(label: '获取群组信息', onPressed: _getGroupsInfo),
              ApiButton(
                  label: '设置群备注',
                  onPressed: () async {
                    final args = await showParamsDialog(context,
                        title: '设置群备注',
                        params: [
                          (label: 'GroupId', hint: 'groupId', isNumber: false),
                          (label: 'Remark', hint: 'remark', isNumber: false),
                        ],
                        trimValues: false);
                    if (args == null || !mounted) return;
                    showInput('setRemark', {
                      'groupId': args['GroupId'] ?? '',
                      'remark': args['Remark'] ?? '',
                    });
                    await GroupChannel(args['GroupId'] ?? '').setRemark(
                      args['Remark'] ?? '',
                      (error) => showResult('setRemark', error?.toJson()),
                    );
                  }),
            ],
          ),
          ApiSection(
            title: '成员管理',
            children: [
              ApiButton(label: '邀请用户', onPressed: _inviteUsers),
              ApiButton(label: '接受群邀请', onPressed: _acceptInvite),
              ApiButton(label: '拒绝群邀请', onPressed: _refuseInvite),
              ApiButton(label: '踢出成员', onPressed: _kickMembers),
              ApiButton(label: '设置管理员', onPressed: _addAdmins),
              ApiButton(label: '取消管理员', onPressed: _removeAdmins),
              ApiButton(label: '设置成员信息', onPressed: _setMemberInfo),
              ApiButton(label: '获取成员信息', onPressed: _getMembers),
              ApiButton(label: '转让群主', onPressed: _transferOwner),
            ],
          ),
          ApiSection(
            title: '关注/收藏',
            children: [
              ApiButton(label: '关注成员', onPressed: _addFavorites),
              ApiButton(label: '取消关注', onPressed: _removeFavorites),
              ApiButton(
                  label: '获取关注列表',
                  onPressed: () async {
                    final groupId = await _pickGroupId();
                    if (groupId == null || !mounted) return;
                    showInput('getFavorites', {'groupId': groupId});
                    await GroupChannel(groupId).getFavorites((infos, error) {
                      showResult(
                          'getFavorites',
                          hasError(error)
                              ? error?.toJson()
                              : {
                                  'count': infos?.length,
                                  'favorites': infos
                                      ?.map((info) => info.toJson())
                                      .toList(),
                                });
                    });
                  }),
            ],
          ),
          ApiSection(
            title: '查询',
            children: [
              ApiButton(label: '已加入群列表', onPressed: _joinedGroupsQuery),
              ApiButton(label: '按角色查成员', onPressed: _groupMembersByRoleQuery),
              ApiButton(
                  label: '搜索已加入群',
                  onPressed: () async {
                    final args = await showParamsDialog(context,
                        title: '搜索已加入群',
                        params: [
                          (
                            label: 'GroupName',
                            hint: 'group name keyword',
                            isNumber: false
                          ),
                          (label: 'PageSize', hint: '20', isNumber: true),
                          (
                            label: 'Ascending(0=desc,1=asc)',
                            hint: '(optional)',
                            isNumber: true
                          ),
                        ]);
                    if (args == null || !mounted) return;
                    final ascStr = args['Ascending(0=desc,1=asc)'] ?? '';
                    final bool? isAscending =
                        ascStr.isEmpty ? null : ascStr == '1';
                    showInput('searchJoinedGroups', {
                      'groupName': args['GroupName'] ?? '',
                      'pageSize': int.tryParse(args['PageSize'] ?? '20') ?? 20,
                      'isAscending': isAscending,
                    });
                    await GroupChannel.searchJoinedGroups(
                      SearchJoinedGroupsParams(
                        groupName: args['GroupName'] ?? '',
                        option: PagingQueryOption(
                          pageSize:
                              int.tryParse(args['PageSize'] ?? '20') ?? 20,
                          order: isAscending,
                        ),
                      ),
                      (result, error) {
                        showResult(
                            'searchJoinedGroups',
                            hasError(error)
                                ? error?.toJson()
                                : {
                                    'totalCount': result?.totalCount,
                                    'groups': result?.data
                                        ?.map((e) => e.toJson())
                                        .toList(),
                                  });
                      },
                    );
                  }),
              ApiButton(label: '获取群申请', onPressed: _getGroupApplications),
            ],
          ),
        ],
      ),
    );
  }
}
