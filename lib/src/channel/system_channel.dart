import '../enum/channel_type.dart';
import 'base_channel.dart';

/// A channel for receiving system notifications.
///
/// System channels are used for messages such as friend requests, account
/// alerts, and other service notifications.
class SystemChannel extends BaseChannel {
  /// Creates a [SystemChannel].
  SystemChannel(
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
  }) : super(ChannelType.system, channelId);

  /// Creates a [SystemChannel] from a [ChannelIdentifier].
  SystemChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId);
}
