import '../enum/channel_type.dart';
import '../internal/converter.dart';
import '../engine/nc_engine.dart';
import 'base_channel.dart';

/// A direct channel for one-to-one conversations.
///
/// [DirectChannel] extends [BaseChannel] with capabilities specific to direct
/// messaging, such as sending typing status indicators.
class DirectChannel extends BaseChannel {
  /// Creates a [DirectChannel].
  DirectChannel(
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
  }) : super(ChannelType.direct, channelId);

  /// Creates a [DirectChannel] from a [ChannelIdentifier].
  DirectChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId);

  /// Sends a typing status indicator to the other user.
  ///
  /// [typingMessageType] identifies the kind of content currently being typed.
  Future<int> sendTypingStatus(String typingMessageType) {
    return NCEngine.engine.sendTypingStatus(
      Converter.toRCConversationType(channelType),
      channelId,
      null,
      typingMessageType,
    );
  }
}
