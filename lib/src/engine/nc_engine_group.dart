part of 'nc_engine.dart';

void _notifyGroupOperation(
  String? groupId,
  RCIMIWGroupMemberInfo? operatorInfo,
  RCIMIWGroupInfo? groupInfo,
  RCIMIWGroupOperation? operation,
  List<RCIMIWGroupMemberInfo>? memberInfos,
  int? operationTime,
) {
  final wrappedOperator =
      operatorInfo != null ? GroupMemberInfo.fromRaw(operatorInfo) : null;
  final wrappedGroup = groupInfo != null ? GroupInfo.fromRaw(groupInfo) : null;
  final wrappedOperation =
      operation != null ? GroupOperation.values[operation.index] : null;
  final wrappedMembers =
      memberInfos?.map((e) => GroupMemberInfo.fromRaw(e)).toList();
  NCEngine._groupChannelHandlers.notify(
    (h) => h.onGroupOperation?.call(
      GroupOperationEventInfo(
        groupId: groupId,
        operatorInfo: wrappedOperator,
        groupInfo: wrappedGroup,
        operation: wrappedOperation,
        memberInfos: wrappedMembers,
        operationTime: operationTime,
      ),
    ),
  );
}

void _notifyGroupInfoChanged(
  RCIMIWGroupMemberInfo? operatorInfo,
  RCIMIWGroupInfo? fullGroupInfo,
  RCIMIWGroupInfo? changedGroupInfo,
  int? operationTime,
) {
  final wrappedOperator =
      operatorInfo != null ? GroupMemberInfo.fromRaw(operatorInfo) : null;
  final wrappedFullGroup =
      fullGroupInfo != null ? GroupInfo.fromRaw(fullGroupInfo) : null;
  final wrappedChangedGroup =
      changedGroupInfo != null ? GroupInfo.fromRaw(changedGroupInfo) : null;
  NCEngine._groupChannelHandlers.notify(
    (h) => h.onGroupInfoChanged?.call(
      GroupInfoChangedEventInfo(
        operatorInfo: wrappedOperator,
        fullGroupInfo: wrappedFullGroup,
        changedGroupInfo: wrappedChangedGroup,
        operationTime: operationTime,
      ),
    ),
  );
}

void _notifyGroupMemberInfoChanged(
  String? groupId,
  RCIMIWGroupMemberInfo? operatorInfo,
  RCIMIWGroupMemberInfo? memberInfo,
  int? operationTime,
) {
  final wrappedOperator =
      operatorInfo != null ? GroupMemberInfo.fromRaw(operatorInfo) : null;
  final wrappedMember =
      memberInfo != null ? GroupMemberInfo.fromRaw(memberInfo) : null;
  NCEngine._groupChannelHandlers.notify(
    (h) => h.onGroupMemberInfoChanged?.call(
      GroupMemberInfoChangedEventInfo(
        groupId: groupId,
        operatorInfo: wrappedOperator,
        memberInfo: wrappedMember,
        operationTime: operationTime,
      ),
    ),
  );
}

void _notifyGroupApplicationEvent(RCIMIWGroupApplicationInfo? info) {
  final wrapped = info != null ? GroupApplicationInfo.fromRaw(info) : null;
  NCEngine._groupChannelHandlers.notify(
    (h) => h.onGroupApplicationEvent?.call(
      GroupApplicationEventInfo(info: wrapped),
    ),
  );
}

void _notifyGroupFavoritesChangedSync(
  String? groupId,
  RCIMIWGroupOperationType? operationType,
  List<String>? userIds,
  int? operationTime,
) {
  final wrapped =
      operationType != null
          ? GroupOperationType.values[operationType.index]
          : null;
  NCEngine._groupChannelHandlers.notify(
    (h) => h.onGroupFavoritesChangedSync?.call(
      GroupFavoritesChangedSyncEvent(
        groupId: groupId,
        operationType: wrapped,
        userIds: userIds,
        operationTime: operationTime,
      ),
    ),
  );
}
