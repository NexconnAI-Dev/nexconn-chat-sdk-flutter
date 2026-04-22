import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/channel_type.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../query/open_channel_messages_query.dart';
import 'base_channel.dart';

/// Parameters for entering an open channel.
class EnterOpenChannelParams {
  /// The number of history messages to load when entering the channel.
  final int messageCount;

  /// Creates [EnterOpenChannelParams].
  EnterOpenChannelParams({required this.messageCount});
}

/// Parameters for setting open channel metadata entries.
class OpenChannelSetMetadataParams {
  /// The key-value entries to set.
  final Map metadata;

  /// Whether the entries should be removed automatically when the user leaves.
  final bool deleteWhenLeft;

  /// Whether existing entries with the same keys should be overwritten.
  final bool overwrite;

  /// Creates [OpenChannelSetMetadataParams].
  OpenChannelSetMetadataParams({
    required this.metadata,
    this.deleteWhenLeft = false,
    this.overwrite = true,
  });
}

/// Parameters for deleting open channel metadata entries.
class OpenChannelDeleteMetadataParams {
  /// The keys to delete.
  final List<String> keys;

  /// Whether deletion should be forced even if the entries were set by another user.
  final bool isForce;

  /// Creates [OpenChannelDeleteMetadataParams].
  OpenChannelDeleteMetadataParams({required this.keys, this.isForce = false});
}

/// An open channel for large-scale real-time interaction.
///
/// [OpenChannel] supports entering and leaving the channel, managing
/// channel-level metadata entries, and querying channel messages.
///
/// Open channels do not persist membership. Users must explicitly enter before
/// use and explicitly leave when done.
class OpenChannel extends BaseChannel {
  /// Creates an [OpenChannel].
  OpenChannel(
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
  }) : super(ChannelType.open, channelId);

  /// Creates an [OpenChannel] from a [ChannelIdentifier].
  OpenChannel.fromIdentifier(ChannelIdentifier identifier)
    : this(identifier.channelId);

  /// Enters this open channel and starts receiving messages.
  ///
  /// [params] specifies how many history messages should be loaded on entry.
  Future<int> enterChannel(
    EnterOpenChannelParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.joinChatRoom(
      channelId,
      params.messageCount,
      false,
      callback: IRCIMIWJoinChatRoomCallback(
        onChatRoomJoined: (code, tid) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Leaves this open channel and stops receiving its messages.
  Future<int> exitChannel(ErrorHandler handler) {
    return NCEngine.engine.leaveChatRoom(
      channelId,
      callback: IRCIMIWLeaveChatRoomCallback(
        onChatRoomLeft: (code, tid) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves metadata entries for this open channel.
  ///
  /// When [key] is provided, only the value for that key is returned.
  /// Otherwise, all entries are returned.
  Future<int> getMetadata({
    String? key,
    required OperationHandler<Map> handler,
  }) {
    if (key != null) {
      return NCEngine.engine.getChatRoomEntry(
        channelId,
        key,
        callback: IRCIMIWGetChatRoomEntryCallback(
          onSuccess: (t) => handler(t, null),
          onError: (code) => handler(null, Converter.toNCError(code)),
        ),
      );
    }
    return NCEngine.engine.getChatRoomAllEntries(
      channelId,
      callback: IRCIMIWGetChatRoomAllEntriesCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Sets or updates metadata entries for this open channel.
  ///
  /// This operates on channel-level entries rather than message-level metadata.
  Future<int> setMetadata(
    OpenChannelSetMetadataParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.addChatRoomEntries(
      channelId,
      params.metadata,
      params.deleteWhenLeft,
      params.overwrite,
      callback: IRCIMIWAddChatRoomEntriesCallback(
        onChatRoomEntriesAdded:
            (code, errors) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Creates a paginated message query for this open channel.
  OpenChannelMessagesQuery createOpenChannelMessagesQuery(
    OpenChannelMessagesQueryParams params,
  ) {
    return OpenChannelMessagesQuery(params);
  }

  /// Deletes metadata entries from this open channel.
  ///
  /// This operates on channel-level entries rather than message-level metadata.
  Future<int> deleteMetadata(
    OpenChannelDeleteMetadataParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.removeChatRoomEntries(
      channelId,
      params.keys,
      params.isForce,
      callback: IRCIMIWRemoveChatRoomEntriesCallback(
        onChatRoomEntriesRemoved: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }
}
