import '../enum/channel_type.dart';
import 'base_channel.dart';

/// A sub-channel within a community channel.
///
/// [CommunitySubChannel] represents a topic partition under a
/// [CommunityChannel]. Each sub-channel has its own message history, unread
/// state, and notification settings.
///
/// Sub-channels share the parent [channelId] and are distinguished by
/// [subChannelId].
class CommunitySubChannel extends BaseChannel {
  /// The unique identifier of this sub-channel within its community.
  final String subChannelId;

  /// Creates a [CommunitySubChannel].
  CommunitySubChannel(
    String channelId,
    this.subChannelId, {
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
  }) : super(ChannelType.community, channelId);

  /// Creates a [CommunitySubChannel] from a [ChannelIdentifier].
  ///
  /// Defaults to an empty string when [ChannelIdentifier.subChannelId] is null.
  CommunitySubChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId, identifier.subChannelId ?? '');

  /// Returns the identifier for this sub-channel.
  @override
  ChannelIdentifier get channelIdentifier => ChannelIdentifier(
    channelType: channelType,
    channelId: channelId,
    subChannelId: subChannelId,
  );
}
