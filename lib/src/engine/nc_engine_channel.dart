part of 'nc_engine.dart';

void _notifyChannelPinnedSync(
  ChannelType type,
  String? channelId,
  String? subChannelId,
  bool? isPinned,
) {
  final channel = ChannelIdentifier(
    channelType: type,
    channelId: channelId ?? '',
    subChannelId: subChannelId?.isEmpty == true ? null : subChannelId,
  );
  NCEngine._channelHandlers.notify(
    (h) => h.onChannelPinnedSync?.call(
      ChannelPinnedSyncEvent(
        channelIdentifier: channel,
        isPinned: isPinned ?? false,
      ),
    ),
  );
}

void _notifyChannelNotificationLevelSync(
  ChannelType type,
  String? channelId,
  String? subChannelId,
  RCIMIWPushNotificationLevel? level,
) {
  final channel = ChannelIdentifier(
    channelType: type,
    channelId: channelId ?? '',
    subChannelId: subChannelId?.isEmpty == true ? null : subChannelId,
  );
  final wrapped =
      level != null ? ChannelNoDisturbLevel.values[level.index] : null;
  if (wrapped == null) return;
  NCEngine._channelHandlers.notify(
    (h) => h.onChannelNoDisturbLevelSync?.call(
      ChannelNoDisturbLevelSyncEvent(
        channelIdentifier: channel,
        level: wrapped,
      ),
    ),
  );
}

void _notifyTypingStatusChanged(
  ChannelType type,
  String? channelId,
  String? subChannelId,
  List<RCIMIWTypingStatus>? status,
) {
  final channel = ChannelIdentifier(
    channelType: type,
    channelId: channelId ?? '',
    subChannelId: subChannelId?.isEmpty == true ? null : subChannelId,
  );
  final wrapped = status?.map(ChannelUserTypingStatusInfo.fromRaw).toList();
  NCEngine._channelHandlers.notify(
    (h) => h.onTypingStatusChanged?.call(
      TypingStatusChangedEvent(
        channelIdentifier: channel,
        userTypingStatus: wrapped,
      ),
    ),
  );
}

void _notifyRemoteChannelsSyncCompleted(int? code) {
  NCEngine._channelHandlers.notify(
    (h) => h.onRemoteChannelsSyncCompleted?.call(
      RemoteChannelsSyncCompletedEvent(error: Converter.toNCError(code)),
    ),
  );
}

void _notifyChannelTranslateStrategySync(
  RCIMIWConversationType? type,
  String? targetId,
  String? channelId,
  RCIMIWTranslateStrategy? strategy,
) {
  if (type == null || targetId == null) return;
  final channel = ChannelIdentifier(
    channelType: Converter.fromRCConversationType(type),
    channelId: targetId,
    subChannelId: channelId?.isEmpty == true ? null : channelId,
  );
  final ncStrategy =
      strategy != null ? TranslateStrategy.values[strategy.index] : null;
  NCEngine._channelHandlers.notify(
    (h) => h.onChannelTranslateStrategySync?.call(
      ChannelTranslateStrategySyncEvent(
        channelIdentifier: channel,
        strategy: ncStrategy,
      ),
    ),
  );
}

void _notifyCommunityChannelsSyncCompleted() {
  NCEngine._channelHandlers.notify(
    (h) => h.onCommunityChannelsSyncCompleted?.call(
      const CommunityChannelsSyncCompletedEvent(),
    ),
  );
}
