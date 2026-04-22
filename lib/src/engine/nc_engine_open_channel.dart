part of 'nc_engine.dart';

void _notifyOpenChannelEntering(String? channelId) {
  NCEngine._openChannelHandlers.notify(
    (h) => h.onEntering?.call(OpenChannelEnteringEvent(channelId: channelId)),
  );
}

void _notifyOpenChannelParticipantChanged(
  String? channelId,
  List<RCIMIWChatRoomMemberAction>? actions,
) {
  final wrapped =
      actions?.map(OpenChannelParticipantActionInfo.fromRaw).toList();
  NCEngine._openChannelHandlers.notify(
    (h) => h.onParticipantChanged?.call(
      OpenChannelParticipantChangedEvent(
        channelId: channelId,
        actions: wrapped,
      ),
    ),
  );
}

void _notifyOpenChannelStatusChanged(
  String? channelId,
  RCIMIWChatRoomStatus? status,
) {
  final wrapped =
      status != null ? OpenChannelStatus.values[status.index] : null;
  NCEngine._openChannelHandlers.notify(
    (h) => h.onStatusChanged?.call(
      OpenChannelStatusChangedEvent(channelId: channelId, status: wrapped),
    ),
  );
}

void _notifyOpenChannelMetadataUpdated(
  RCIMIWChatRoomEntriesOperationType? operationType,
  String? roomId,
  Map? entries,
) {
  final wrapped =
      operationType != null
          ? OpenChannelMetadataOperationType.values[operationType.index]
          : null;
  final infos = <OpenChannelMetadataChangeInfo>[];
  if (entries != null && entries.isNotEmpty) {
    entries.forEach((k, v) {
      infos.add(
        OpenChannelMetadataChangeInfo(
          channelId: roomId,
          key: k?.toString(),
          value: v?.toString(),
          operationType: wrapped,
        ),
      );
    });
  } else {
    infos.add(
      OpenChannelMetadataChangeInfo(channelId: roomId, operationType: wrapped),
    );
  }
  NCEngine._openChannelHandlers.notify(
    (h) => h.onMetadataChanged?.call(
      OpenChannelMetadataChangedEvent(changeInfo: infos),
    ),
  );
}

void _notifyOpenChannelMetadataSynced(String? roomId) {
  NCEngine._openChannelHandlers.notify(
    (h) => h.onMetadataSynced?.call(
      OpenChannelMetadataSyncedEvent(channelId: roomId),
    ),
  );
}

void _notifyOpenChannelParticipantMuted(RCIMIWChatRoomMemberBanEvent? event) {
  final wrapped =
      event != null ? OpenChannelParticipantMutedInfo.fromRaw(event) : null;
  NCEngine._openChannelHandlers.notify(
    (h) => h.onParticipantMuted?.call(
      OpenChannelParticipantMutedEvent(info: wrapped),
    ),
  );
}

void _notifyOpenChannelParticipantBanned(
  RCIMIWChatRoomMemberBlockEvent? event,
) {
  final wrapped =
      event != null ? OpenChannelParticipantBannedInfo.fromRaw(event) : null;
  NCEngine._openChannelHandlers.notify(
    (h) => h.onParticipantBanned?.call(
      OpenChannelParticipantBannedEvent(info: wrapped),
    ),
  );
}

void _notifyOpenChannelMultiLoginSync(RCIMIWChatRoomSyncEvent? event) {
  final wrapped = event != null ? OpenChannelSyncEvent.fromRaw(event) : null;
  NCEngine._openChannelHandlers.notify(
    (h) => h.onNotifyMultiLoginSync?.call(
      OpenChannelMultiLoginSyncEvent(event: wrapped),
    ),
  );
}
