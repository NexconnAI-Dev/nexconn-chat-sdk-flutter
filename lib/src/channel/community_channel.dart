import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/channel_type.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../message/message.dart';
import 'base_channel.dart';
import 'community_sub_channel.dart';

/// Parameters for deleting a community message.
class DeleteCommunityMessageParams {
  /// The message to delete.
  final Message message;

  /// Whether the message should also be deleted remotely.
  final bool deleteRemote;

  /// Creates [DeleteCommunityMessageParams].
  DeleteCommunityMessageParams({
    required this.message,
    this.deleteRemote = false,
  });
}

/// Result of checking whether messages still exist remotely.
class CheckRemoteMessagesResult {
  /// Messages that still exist remotely.
  final List<Message> matched;

  /// Messages that were not found remotely and may have been deleted.
  final List<Message> notMatched;

  /// Creates a [CheckRemoteMessagesResult].
  CheckRemoteMessagesResult({required this.matched, required this.notMatched});
}

/// A community channel with support for sub-channels.
///
/// [CommunityChannel] extends [BaseChannel] with community-specific features,
/// including sub-channel management, read-status sync, message metadata
/// management, and unread counts at the community level.
class CommunityChannel extends BaseChannel {
  /// Creates a [CommunityChannel].
  CommunityChannel(
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
  }) : super(ChannelType.community, channelId);

  /// Creates a [CommunityChannel] from a [ChannelIdentifier].
  CommunityChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId);

  /// Retrieves all sub-channels in this community.
  Future<int> getSubChannels(
    OperationHandler<List<CommunitySubChannel>> handler,
  ) {
    return NCEngine.engine.getConversationsForAllChannel(
      Converter.toRCConversationType(channelType),
      channelId,
      callback: IRCIMIWGetConversationsForAllChannelCallback(
        onSuccess:
            (t) => handler(
              Converter.toChannels(t).whereType<CommunitySubChannel>().toList(),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the unread message count for this community channel.
  @override
  Future<int> getUnreadCount(OperationHandler<int> handler) {
    return NCEngine.engine.getUltraGroupUnreadCount(
      channelId,
      callback: IRCIMIWGetUltraGroupUnreadCountCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Clears the unread count for this community channel.
  @override
  Future<int> clearUnreadCount(ErrorHandler handler) {
    return NCEngine.engine.syncUltraGroupReadStatus(
      channelId,
      null,
      0,
      callback: IRCIMIWSyncUltraGroupReadStatusCallback(
        onUltraGroupReadStatusSynced:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Deletes a message in this community channel.
  ///
  /// [params] specifies the target message and whether remote deletion is needed.
  Future<int> deleteMessageForAll(
    DeleteCommunityMessageParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.recallUltraGroupMessage(
      params.message.raw,
      params.deleteRemote,
      callback: IRCIMIWRecallUltraGroupMessageCallback(
        onUltraGroupMessageRecalled:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the total unread message count across all community channels.
  static Future<int> getTotalUnreadCount(OperationHandler<int> handler) {
    return NCEngine.engine.getUltraGroupAllUnreadCount(
      callback: IRCIMIWGetUltraGroupAllUnreadCountCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the total unread mentioned count across all community channels.
  static Future<int> getTotalUnreadMentionedCount(
    OperationHandler<int> handler,
  ) {
    return NCEngine.engine.getUltraGroupAllUnreadMentionedCount(
      callback: IRCIMIWGetUltraGroupAllUnreadMentionedCountCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Checks whether a group of messages still exists remotely.
  static Future<int> checkRemoteMessages(
    List<Message> messages,
    OperationHandler<CheckRemoteMessagesResult> handler,
  ) {
    return NCEngine.engine.getBatchRemoteUltraGroupMessages(
      messages.map((m) => m.raw).toList(),
      callback: IRCIMIWGetBatchRemoteUltraGroupMessagesCallback(
        onSuccess:
            (matched, notMatched) => handler(
              CheckRemoteMessagesResult(
                matched: matched?.map(Converter.fromRawMessage).toList() ?? [],
                notMatched:
                    notMatched?.map(Converter.fromRawMessage).toList() ?? [],
              ),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }
}
