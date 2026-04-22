import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/channel_type.dart';
import '../enum/connection_status.dart';
import '../enum/no_disturb_level.dart';
import '../enum/translate_strategy.dart';
import '../error/nc_error.dart';
import '../message/message.dart';
import '../message/text_message.dart';
import '../message/image_message.dart';
import '../message/hd_voice_message.dart';
import '../message/short_video_message.dart';
import '../message/file_message.dart';
import '../message/gif_message.dart';
import '../message/combine_message.dart';
import '../message/custom_media_message.dart';
import '../message/location_message.dart';
import '../message/reference_message.dart';
import '../message/custom_message.dart';
import '../message/command_message.dart';
import '../message/command_notification_message.dart';
import '../message/stream_message.dart';
import '../message/group_notification_message.dart';
import '../message/unknown_message.dart';
import '../channel/base_channel.dart';
import '../channel/direct_channel.dart';
import '../channel/group_channel.dart';
import '../channel/open_channel.dart';
import '../channel/community_channel.dart';
import '../channel/community_sub_channel.dart';
import '../channel/system_channel.dart';

/// Conversion utilities between public Nexconn types and SDK data types.
///
/// This class only exposes static methods and maintains no state. It is used
/// to centralize mappings for channels, messages, statuses, and errors.
class Converter {
  /// Converts [ChannelType] to the SDK conversation type.
  static RCIMIWConversationType toRCConversationType(ChannelType type) {
    switch (type) {
      case ChannelType.direct:
        return RCIMIWConversationType.private;
      case ChannelType.group:
        return RCIMIWConversationType.group;
      case ChannelType.open:
        return RCIMIWConversationType.chatroom;
      case ChannelType.community:
        return RCIMIWConversationType.ultraGroup;
      case ChannelType.system:
        return RCIMIWConversationType.system;
    }
  }

  /// Converts the SDK conversation type to [ChannelType].
  ///
  /// Returns [ChannelType.direct] for unknown values.
  static ChannelType fromRCConversationType(RCIMIWConversationType type) {
    switch (type) {
      case RCIMIWConversationType.private:
        return ChannelType.direct;
      case RCIMIWConversationType.group:
        return ChannelType.group;
      case RCIMIWConversationType.chatroom:
        return ChannelType.open;
      case RCIMIWConversationType.ultraGroup:
        return ChannelType.community;
      case RCIMIWConversationType.system:
        return ChannelType.system;
      default:
        return ChannelType.direct;
    }
  }

  /// Converts SDK connection status to [ConnectionStatus].
  ///
  /// Returns [ConnectionStatus.unknown] when [status] is `null` or unrecognized.
  static ConnectionStatus fromRCConnectionStatus(
    RCIMIWConnectionStatus? status,
  ) {
    if (status == null) return ConnectionStatus.unknown;
    switch (status) {
      case RCIMIWConnectionStatus.networkUnavailable:
        return ConnectionStatus.networkUnavailable;
      case RCIMIWConnectionStatus.connected:
        return ConnectionStatus.connected;
      case RCIMIWConnectionStatus.connecting:
        return ConnectionStatus.connecting;
      case RCIMIWConnectionStatus.unconnected:
        return ConnectionStatus.unconnected;
      case RCIMIWConnectionStatus.kickedOfflineByOtherClient:
        return ConnectionStatus.kickedOfflineByOtherClient;
      case RCIMIWConnectionStatus.tokenIncorrect:
        return ConnectionStatus.tokenIncorrect;
      case RCIMIWConnectionStatus.connUserBlocked:
        return ConnectionStatus.connUserBlocked;
      case RCIMIWConnectionStatus.signOut:
        return ConnectionStatus.signOut;
      case RCIMIWConnectionStatus.suspend:
        return ConnectionStatus.suspend;
      case RCIMIWConnectionStatus.timeout:
        return ConnectionStatus.timeout;
      default:
        return ConnectionStatus.unknown;
    }
  }

  /// Creates an [NCError] from an error code.
  ///
  /// When [code] is `null`, it is treated as success with `code = 0`.
  static NCError? toNCError(int? code, {String? errorMessage}) {
    return NCError(code: code ?? 0, message: errorMessage);
  }

  /// Converts a list of [ChannelType] values to SDK conversation types.
  static List<RCIMIWConversationType> toRCConversationTypes(
    List<ChannelType> channelTypes,
  ) {
    return channelTypes.map(toRCConversationType).toList();
  }

  /// Converts a native channel object to a Nexconn [BaseChannel] subclass based on the channel type.
  static BaseChannel toChannel(RCIMIWConversation conv) {
    final channelId = conv.targetId ?? '';
    final subChannelId = conv.channelId;
    final unreadCount = conv.unreadCount;
    final mentionedCount = conv.mentionedCount;
    final mentionedMeCount = conv.mentionedMeCount;
    final isPinned = conv.top;
    final draft = conv.draft;
    final latestMessage =
        conv.lastMessage != null ? fromRawMessage(conv.lastMessage!) : null;
    final notificationLevel =
        conv.notificationLevel != null
            ? ChannelNoDisturbLevel.values[conv.notificationLevel!.index]
            : null;
    final firstUnreadMsgSendTime = conv.firstUnreadMsgSendTime;
    final operationTime = conv.operationTime;
    final translateStrategy =
        conv.translateStrategy != null
            ? TranslateStrategy.values[conv.translateStrategy!.index]
            : null;

    switch (conv.conversationType) {
      case RCIMIWConversationType.private:
        return DirectChannel(
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
      case RCIMIWConversationType.group:
        return GroupChannel(
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
      case RCIMIWConversationType.chatroom:
        return OpenChannel(
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
      case RCIMIWConversationType.ultraGroup:
        if (subChannelId != null && subChannelId.isNotEmpty) {
          return CommunitySubChannel(
            channelId,
            subChannelId,
            unreadCount: unreadCount,
            mentionedCount: mentionedCount,
            mentionedMeCount: mentionedMeCount,
            isPinned: isPinned,
            draft: draft,
            latestMessage: latestMessage,
            notificationLevel: notificationLevel,
            firstUnreadMsgSendTime: firstUnreadMsgSendTime,
            operationTime: operationTime,
            translateStrategy: translateStrategy,
          );
        }
        return CommunityChannel(
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
      case RCIMIWConversationType.system:
        return SystemChannel(
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
      default:
        return BaseChannel(
          ChannelType.direct,
          channelId,
          unreadCount: unreadCount,
          mentionedCount: mentionedCount,
          mentionedMeCount: mentionedMeCount,
          isPinned: isPinned,
          draft: draft,
          latestMessage: latestMessage,
          notificationLevel: notificationLevel,
          firstUnreadMsgSendTime: firstUnreadMsgSendTime,
          operationTime: operationTime,
          translateStrategy: translateStrategy,
        );
    }
  }

  /// Converts a list of native channel objects to Nexconn [BaseChannel] objects.
  ///
  /// Returns an empty list if [convs] is `null`.
  static List<BaseChannel> toChannels(List<RCIMIWConversation>? convs) {
    return convs?.map(toChannel).toList() ?? [];
  }

  /// Converts a native message object to the appropriate Nexconn [Message] subclass based on the runtime type.
  ///
  /// Falls back to [UnknownMessage] if the message type is not recognized.
  static Message fromRawMessage(RCIMIWMessage raw) {
    if (raw is RCIMIWTextMessage) return TextMessage.fromRaw(raw);
    if (raw is RCIMIWImageMessage) return ImageMessage.fromRaw(raw);
    if (raw is RCIMIWVoiceMessage) return HDVoiceMessage.fromRaw(raw);
    if (raw is RCIMIWSightMessage) return ShortVideoMessage.fromRaw(raw);
    if (raw is RCIMIWFileMessage) return FileMessage.fromRaw(raw);
    if (raw is RCIMIWGIFMessage) return GIFMessage.fromRaw(raw);
    if (raw is RCIMIWCombineV2Message) return CombineMessage.fromRaw(raw);
    if (raw is RCIMIWNativeCustomMediaMessage) {
      return CustomMediaMessage.fromRaw(raw);
    }
    if (raw is RCIMIWLocationMessage) return LocationMessage.fromRaw(raw);
    if (raw is RCIMIWReferenceMessage) return ReferenceMessage.fromRaw(raw);
    if (raw is RCIMIWNativeCustomMessage) {
      return CustomMessage.fromRaw(raw);
    }
    if (raw is RCIMIWCommandMessage) return CommandMessage.fromRaw(raw);
    if (raw is RCIMIWCommandNotificationMessage) {
      return CommandNotificationMessage.fromRaw(raw);
    }
    if (raw is RCIMIWStreamMessage) return StreamMessage.fromRaw(raw);
    if (raw is RCIMIWGroupNotificationMessage) {
      return GroupNotificationMessage.fromRaw(raw);
    }
    if (raw is RCIMIWUnknownMessage) return UnknownMessage.fromRaw(raw);
    return UnknownMessage.wrap(raw);
  }
}
