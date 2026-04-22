import 'package:ai_nexconn_chat_plugin/src/model/tag.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../error/nc_error.dart';
import '../enum/channel_type.dart';
import '../model/push_config.dart';
import '../enum/message_operation_policy.dart';
import '../enum/message_type.dart';
import '../enum/no_disturb_level.dart';
import '../enum/translate_strategy.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import '../engine/nc_engine.dart';
import '../message/message.dart';
import '../message/media_message.dart';
import '../message/text_message.dart';
import '../message/image_message.dart';
import '../message/hd_voice_message.dart';
import '../message/file_message.dart';
import '../message/short_video_message.dart';
import '../message/gif_message.dart';
import '../message/location_message.dart';
import '../message/combine_message.dart';
import '../message/reference_message.dart';
import '../message/custom_message.dart';
import '../message/custom_media_message.dart';
import '../model/message_identifier.dart';
import '../model/read_receipt_info.dart';
import '../model/message_read_receipt_users_result.dart';
import '../model/search_channel_result.dart';
import '../query/channel_list_query.dart';
import '../query/message_query.dart';
import '../query/message_read_receipt_query.dart';
import '../query/search_query.dart';

/// Uniquely identifies a channel.
///
/// A channel is identified by its type, channel ID, and optional sub-channel ID.
class ChannelIdentifier {
  /// The channel type.
  final ChannelType channelType;

  /// The channel ID.
  final String channelId;

  /// The optional sub-channel ID used by community sub-channels.
  final String? subChannelId;

  /// Creates a [ChannelIdentifier].
  ChannelIdentifier({
    required this.channelType,
    required this.channelId,
    this.subChannelId,
  });
}

/// Callback container for sending a regular message.
class SendMessageCallback {
  /// Called when the message has been saved locally.
  final void Function(Message? message)? onMessageSaved;

  /// Called when the message send operation finishes.
  ///
  /// [code] is `0` on success and non-zero on failure.
  final void Function(int? code, Message? message) onMessageSent;

  /// Creates a [SendMessageCallback].
  SendMessageCallback({this.onMessageSaved, required this.onMessageSent});
}

/// Parameters for querying messages around a specific timestamp.
class GetMessagesAroundTimeParams {
  /// The reference timestamp in milliseconds.
  final int sentTime;

  /// The number of messages to retrieve before [sentTime].
  final int beforeCount;

  /// The number of messages to retrieve after [sentTime].
  final int afterCount;

  /// Creates [GetMessagesAroundTimeParams].
  GetMessagesAroundTimeParams({
    required this.sentTime,
    required this.beforeCount,
    required this.afterCount,
  });
}

/// Parameters for retrieving a message by ID.
///
/// At least one of [messageClientId] and [messageId] must be provided.
class GetMessageByIdParams {
  /// The local message ID.
  final int? messageClientId;

  /// The server-side unique message ID.
  final String? messageId;

  /// Creates [GetMessageByIdParams].
  GetMessageByIdParams({this.messageClientId, this.messageId});
}

/// Callback container for sending a media message.
class SendMediaMessageHandler {
  /// Called when the media message has been saved locally.
  final void Function(MediaMessage? message)? onMediaMessageSaved;

  /// Called periodically during upload.
  ///
  /// [progress] is a percentage value from `0` to `100`.
  final void Function(MediaMessage? message, int? progress)?
  onMediaMessageSending;

  /// Called when media upload is canceled.
  final void Function(MediaMessage? message)? onSendingMediaMessageCanceled;

  /// Called when media message sending finishes.
  ///
  /// [code] is `0` on success and non-zero on failure.
  final void Function(int? code, MediaMessage? message) onMediaMessageSent;

  /// Creates a [SendMediaMessageHandler].
  SendMediaMessageHandler({
    this.onMediaMessageSaved,
    this.onMediaMessageSending,
    this.onSendingMediaMessageCanceled,
    required this.onMediaMessageSent,
  });
}

/// Parameters for querying unread counts across multiple channel types.
class ChannelsUnreadCountParams {
  /// The channel types to include.
  final List<ChannelType> channelTypes;

  /// The notification levels to include.
  final List<ChannelNoDisturbLevel> levels;

  /// Creates [ChannelsUnreadCountParams].
  ChannelsUnreadCountParams({required this.channelTypes, required this.levels});
}

/// Parameters for querying message read receipts filtered by user IDs.
class GetMessagesReadReceiptByUsersParams {
  /// The server-side message ID to query.
  final String messageId;

  /// The list of user IDs to check read status for.
  final List<String> userIds;

  /// Creates params with the given [messageId] and [userIds].
  GetMessagesReadReceiptByUsersParams({
    required this.messageId,
    required this.userIds,
  });
}

/// Parameters for inserting messages into the local database of a channel.
class InsertMessagesParams {
  /// The list of message parameters describing the messages to create and insert.
  final List<MessageParams> messageParamsList;

  /// Creates params with the given [messageParamsList].
  InsertMessagesParams({required this.messageParamsList});
}

/// Parameters for deleting messages for the current user by timestamp in a channel.
class DeleteMessagesForMeByTimestampParams {
  /// Messages sent before this timestamp (in milliseconds) will be deleted for the current user.
  final int timestamp;

  /// The policy controlling whether messages are deleted locally, remotely, or both.
  /// Defaults to [MessageOperationPolicy.local].
  final MessageOperationPolicy policy;

  /// Creates params with the given [timestamp] and optional [policy].
  DeleteMessagesForMeByTimestampParams({
    required this.timestamp,
    this.policy = MessageOperationPolicy.local,
  });
}

/// Parameters for setting the notification (do-not-disturb) level for a specific channel type.
class ChannelTypeNoDisturbLevelParams {
  /// The channel type to configure.
  final ChannelType channelType;

  /// The notification (do-not-disturb) level to set.
  final ChannelNoDisturbLevel level;

  /// Creates params with the given [channelType] and [level].
  ChannelTypeNoDisturbLevelParams({
    required this.channelType,
    required this.level,
  });
}

/// Parameters for searching channels by keyword and message types.
class SearchChannelsParams {
  /// The channel types to search within.
  final List<ChannelType> channelTypes;

  /// The message types to filter the search results.
  final List<MessageType> messageTypes;

  /// The keyword to search for in channel content.
  final String keyword;

  /// Creates params with the given [channelTypes], [messageTypes], and [keyword].
  SearchChannelsParams({
    required this.channelTypes,
    required this.messageTypes,
    required this.keyword,
  });
}

/// Parameters for pinning a channel to the top of the channel list.
class PinParams {
  /// Whether to update the channel's operation time when pinning.
  final bool updateOperationTime;

  /// Creates params with the given [updateOperationTime] flag.
  PinParams({required this.updateOperationTime});
}

/// Parameters for sending a non-media message.
///
/// Contains the [messageParams] describing the message to create and send,
/// along with optional push and directed-user configuration. Message-level
/// flags such as `needReceipt` and `mentionedInfo` are carried on
/// [messageParams].
class SendMessageParams {
  /// The parameters describing the message content to create.
  final MessageParams messageParams;

  /// Optional push notification configuration for the message.
  final PushConfig? pushConfig;

  /// Optional list of user IDs for directed group messages.
  /// When set, only the specified users will receive this message.
  final List<String>? directedUserIds;

  /// Creates params with the given [messageParams], optional [pushConfig],
  /// and optional [directedUserIds].
  SendMessageParams({
    required this.messageParams,
    this.pushConfig,
    this.directedUserIds,
  });
}

/// Parameters for sending a media message (e.g., image, voice, file).
///
/// Contains the [messageParams] describing the media message to create and send,
/// along with optional push configuration. Message-level flags such as
/// `needReceipt` and `mentionedInfo` are carried on [messageParams].
class SendMediaMessageParams {
  /// The parameters describing the media message content to create.
  final MessageParams messageParams;

  /// Optional push notification configuration for the message.
  final PushConfig? pushConfig;

  /// Creates params with the given [messageParams] and optional [pushConfig].
  SendMediaMessageParams({required this.messageParams, this.pushConfig});
}

/// Base class for all channels.
///
/// [BaseChannel] defines common properties and capabilities shared by all
/// channels, including sending messages, unread counts, read receipts, pinning,
/// drafts, and notification settings.
///
/// Use specific subclasses such as [DirectChannel], [GroupChannel],
/// [OpenChannel], [CommunityChannel], or [SystemChannel] when channel-specific
/// behavior is needed.
class BaseChannel {
  /// The type of this channel.
  final ChannelType channelType;

  /// The unique identifier of this channel.
  final String channelId;

  /// The number of unread messages in this channel.
  final int? unreadCount;

  /// The total number of messages that contain @mentions in this channel.
  final int? mentionedCount;

  /// The number of messages that specifically @mention the current user.
  final int? mentionedMeCount;

  /// Whether this channel is pinned to the top of the channel list.
  final bool? isPinned;

  /// The saved draft text for this channel, if any.
  final String? draft;

  /// The most recent message in this channel.
  final Message? latestMessage;

  /// The notification (do-not-disturb) level for this channel.
  final ChannelNoDisturbLevel? notificationLevel;

  /// The send time of the first unread message in this channel (in milliseconds).
  final int? firstUnreadMsgSendTime;

  /// The last operation timestamp of this channel, used for sorting.
  final int? operationTime;

  /// The translation strategy applied to messages in this channel.
  final TranslateStrategy? translateStrategy;

  /// Creates a [BaseChannel] with the given [channelType] and [channelId],
  /// along with optional channel metadata.
  BaseChannel(
    this.channelType,
    this.channelId, {
    this.unreadCount,
    this.mentionedCount,
    this.mentionedMeCount,
    this.isPinned,
    this.draft,
    this.latestMessage,
    this.notificationLevel,
    this.firstUnreadMsgSendTime,
    this.operationTime,
    this.translateStrategy,
  });

  /// Returns the identifier of this channel, including sub-channel context when available.
  ChannelIdentifier get channelIdentifier =>
      ChannelIdentifier(channelType: channelType, channelId: channelId);

  /// Converts this channel to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'channelType': channelType.name,
    'channelId': channelId,
    'subChannelId': channelIdentifier.subChannelId,
    'unreadCount': unreadCount,
    'mentionedCount': mentionedCount,
    'mentionedMeCount': mentionedMeCount,
    'isPinned': isPinned,
    'draft': draft,
    'latestMessage': latestMessage?.toJson(),
    'notificationLevel': notificationLevel?.name,
    'firstUnreadMsgSendTime': firstUnreadMsgSendTime,
    'operationTime': operationTime,
    'translateStrategy': translateStrategy?.name,
  };

  RCIMIWEngine get _engine => NCEngine.engine;

  Future<RCIMIWMessage?> _createRawMessage(
    RCIMIWConversationType type,
    String? subId,
    MessageParams mp,
  ) async {
    final identifier = channelIdentifier;
    RCIMIWMessage? raw;
    if (mp is TextMessageParams) {
      raw = await _engine.createTextMessage(
        type,
        identifier.channelId,
        subId,
        mp.text,
      );
    } else if (mp is LocationMessageParams) {
      raw = await _engine.createLocationMessage(
        type,
        identifier.channelId,
        subId,
        mp.longitude,
        mp.latitude,
        mp.poiName,
        mp.thumbnailPath,
      );
    } else if (mp is ReferenceMessageParams) {
      raw = await _engine.createReferenceMessage(
        type,
        identifier.channelId,
        subId,
        mp.referenceMessage.raw,
        mp.text,
      );
    } else if (mp is CustomMessageParams) {
      raw = await _engine.createNativeCustomMessage(
        type,
        identifier.channelId,
        subId,
        mp.messageIdentifier,
        mp.fields,
      );
      (raw as RCIMIWNativeCustomMessage?)?.searchableWords = mp.searchableWords;
    } else if (mp is ImageMessageParams) {
      raw = await _engine.createImageMessage(
        type,
        identifier.channelId,
        subId,
        mp.path,
      );
    } else if (mp is HDVoiceMessageParams) {
      raw = await _engine.createVoiceMessage(
        type,
        identifier.channelId,
        subId,
        mp.path,
        mp.duration,
      );
    } else if (mp is FileMessageParams) {
      raw = await _engine.createFileMessage(
        type,
        identifier.channelId,
        subId,
        mp.path,
      );
    } else if (mp is ShortVideoMessageParams) {
      raw = await _engine.createSightMessage(
        type,
        identifier.channelId,
        subId,
        mp.path,
        mp.duration,
      );
    } else if (mp is GIFMessageParams) {
      raw = await _engine.createGIFMessage(
        type,
        identifier.channelId,
        subId,
        mp.path,
      );
    } else if (mp is CombineMessageParams) {
      raw = await _engine.createCombineV2Message(
        type,
        identifier.channelId,
        subId,
        Converter.toRCConversationType(mp.sourceChannelType),
        mp.summaryList,
        mp.nameList,
        mp.msgList.map((e) => e.toRaw()).toList(),
      );
    } else if (mp is CustomMediaMessageParams) {
      raw = await _engine.createNativeCustomMediaMessage(
        type,
        identifier.channelId,
        subId,
        mp.messageIdentifier,
        mp.path,
        mp.fields,
      );
      (raw as RCIMIWNativeCustomMediaMessage?)?.searchableWords =
          mp.searchableWords;
    }
    raw?.mentionedInfo = mp.mentionedInfo?.toRaw();
    return raw;
  }

  /// Reloads the latest state of this channel.
  ///
  /// The [handler] receives the refreshed [BaseChannel] on success,
  /// or an error on failure.
  Future<int> reload(OperationHandler<BaseChannel> handler) {
    final identifier = channelIdentifier;
    return _engine.getConversation(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWGetConversationCallback(
        onSuccess: (t) {
          if (t == null) {
            handler(null, NCError(code: 34304));
            return;
          }
          handler(Converter.toChannel(t), null);
        },
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the unread message count for this channel.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> getUnreadCount(OperationHandler<int> handler) {
    final identifier = channelIdentifier;
    return _engine.getUnreadCount(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWGetUnreadCountCallback(
        onSuccess: (count) => handler(count, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Clears the unread message count for this channel.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> clearUnreadCount(ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.clearUnreadCount(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      0,
      callback: IRCIMIWClearUnreadCountCallback(
        onUnreadCountCleared: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the first unread message in this channel.
  ///
  /// The [handler] receives the first unread [Message] on success,
  /// or an error on failure.
  Future<int> getFirstUnreadMessage(OperationHandler<Message> handler) {
    final identifier = channelIdentifier;
    return _engine.getFirstUnreadMessage(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWGetFirstUnreadMessageCallback(
        onSuccess: (t) => handler(t != null ? Message.fromRaw(t) : null, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Pins this channel to the top of the channel list.
  ///
  /// [params] controls whether to update the operation time.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> pin(PinParams params, ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.changeConversationTopStatusWithUpdateTme(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      true,
      params.updateOperationTime,
      callback: IRCIMIWChangeConversationTopStatusCallback(
        onConversationTopStatusChanged:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Unpins this channel from the top of the channel list.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> unpin(ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.changeConversationTopStatusWithUpdateTme(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      false,
      false,
      callback: IRCIMIWChangeConversationTopStatusCallback(
        onConversationTopStatusChanged:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Deletes this channel from the channel list.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> delete(ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.removeConversation(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWRemoveConversationCallback(
        onConversationRemoved: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the notification (do-not-disturb) level for this channel.
  ///
  /// [level] specifies the desired notification level.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> setNoDisturbLevel(
    ChannelNoDisturbLevel level,
    ErrorHandler handler,
  ) {
    final identifier = channelIdentifier;
    final rawLevel = RCIMIWPushNotificationLevel.values[level.index];
    if (identifier.channelType == ChannelType.community) {
      final subId = identifier.subChannelId;
      if (subId != null && subId.isNotEmpty) {
        return _engine.changeUltraGroupChannelDefaultNotificationLevel(
          identifier.channelId,
          subId,
          rawLevel,
          callback:
              IRCIMIWChangeUltraGroupChannelDefaultNotificationLevelCallback(
                onUltraGroupChannelDefaultNotificationLevelChanged:
                    (code) => handler(Converter.toNCError(code)),
              ),
        );
      }
      return _engine.changeUltraGroupDefaultNotificationLevel(
        identifier.channelId,
        rawLevel,
        callback: IRCIMIWChangeUltraGroupDefaultNotificationLevelCallback(
          onUltraGroupDefaultNotificationLevelChanged:
              (code) => handler(Converter.toNCError(code)),
        ),
      );
    }
    return _engine.changeConversationNotificationLevel(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      rawLevel,
      callback: IRCIMIWChangeConversationNotificationLevelCallback(
        onConversationNotificationLevelChanged:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Saves a draft message text for this channel.
  ///
  /// [draft] is the text content to save as a draft.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> saveDraft(String draft, ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.saveDraftMessage(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      draft,
      callback: IRCIMIWSaveDraftMessageCallback(
        onDraftMessageSaved: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Clears the saved draft message for this channel.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> clearDraft(ErrorHandler handler) {
    final identifier = channelIdentifier;
    return _engine.clearDraftMessage(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWClearDraftMessageCallback(
        onDraftMessageCleared: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sends a non-media message in this channel.
  ///
  /// The SDK internally creates the message from [params.messageParams] using
  /// channel information from this channel object, applies shared options
  /// such as `mentionedInfo` and `needReceipt` from [params.messageParams],
  /// then sends it.
  /// The created message is returned via the [callback].
  ///
  /// If [params.directedUserIds] is set, the message will be sent as a
  /// directed group message to the specified users only.
  ///
  /// Supported [MessageParams] types: [TextMessageParams],
  /// [LocationMessageParams], [ReferenceMessageParams],
  /// [CustomMessageParams].
  Future<int> sendMessage(
    SendMessageParams params, {
    SendMessageCallback? callback,
  }) async {
    final identifier = channelIdentifier;
    final type = Converter.toRCConversationType(identifier.channelType);
    final subId = identifier.subChannelId;

    final raw = await _createRawMessage(type, subId, params.messageParams);
    if (raw == null) return -1;
    raw.pushOptions = params.pushConfig?.toRaw();
    raw.needReceipt = params.messageParams.needReceipt;

    final isDirected = (params.directedUserIds ?? []).isNotEmpty;
    if (!isDirected) {
      return _engine.sendMessage(
        raw,
        callback: RCIMIWSendMessageCallback(
          onMessageSaved:
              callback?.onMessageSaved != null
                  ? (msg) => callback!.onMessageSaved!(
                    msg != null ? Converter.fromRawMessage(msg) : null,
                  )
                  : null,
          onMessageSent:
              (code, msg) => callback?.onMessageSent(
                code,
                msg != null ? Converter.fromRawMessage(msg) : null,
              ),
        ),
      );
    } else {
      return _engine.sendGroupMessageToDesignatedUsers(
        raw,
        params.directedUserIds ?? [],
        callback: RCIMIWSendGroupMessageToDesignatedUsersCallback(
          onMessageSaved:
              callback?.onMessageSaved != null
                  ? (msg) => callback!.onMessageSaved!(
                    msg != null ? Converter.fromRawMessage(msg) : null,
                  )
                  : null,
          onMessageSent:
              (code, msg) => callback?.onMessageSent(
                code,
                msg != null ? Converter.fromRawMessage(msg) : null,
              ),
        ),
      );
    }
  }

  /// Sends a media message (e.g., image, voice, video, file) in this channel.
  ///
  /// The SDK internally creates the media message from [params.messageParams]
  /// using channel information from this channel object, applies shared options
  /// such as `mentionedInfo` and `needReceipt` from [params.messageParams],
  /// then sends it.
  /// The created message is returned via the [handler] callbacks.
  ///
  /// Supported [MessageParams] types: [ImageMessageParams],
  /// [HDVoiceMessageParams], [FileMessageParams], [ShortVideoMessageParams],
  /// [GIFMessageParams], [CombineMessageParams], [CustomMediaMessageParams].
  Future<int> sendMediaMessage(
    SendMediaMessageParams params, {
    SendMediaMessageHandler? handler,
  }) async {
    final identifier = channelIdentifier;
    final type = Converter.toRCConversationType(identifier.channelType);
    final subId = identifier.subChannelId;

    final raw =
        await _createRawMessage(type, subId, params.messageParams)
            as RCIMIWMediaMessage?;
    if (raw == null) return -1;
    raw.pushOptions = params.pushConfig?.toRaw();
    raw.needReceipt = params.messageParams.needReceipt;

    RCIMIWSendMediaMessageListener? rawHandler;
    if (handler != null) {
      rawHandler = RCIMIWSendMediaMessageListener(
        onMediaMessageSaved:
            handler.onMediaMessageSaved != null
                ? (msg) => handler.onMediaMessageSaved!(
                  msg != null
                      ? Converter.fromRawMessage(msg) as MediaMessage
                      : null,
                )
                : null,
        onMediaMessageSending:
            handler.onMediaMessageSending != null
                ? (msg, progress) => handler.onMediaMessageSending!(
                  msg != null
                      ? Converter.fromRawMessage(msg) as MediaMessage
                      : null,
                  progress,
                )
                : null,
        onSendingMediaMessageCanceled:
            handler.onSendingMediaMessageCanceled != null
                ? (msg) => handler.onSendingMediaMessageCanceled!(
                  msg != null
                      ? Converter.fromRawMessage(msg) as MediaMessage
                      : null,
                )
                : null,
        onMediaMessageSent:
            (code, msg) => handler.onMediaMessageSent(
              code,
              msg != null
                  ? Converter.fromRawMessage(msg) as MediaMessage
                  : null,
            ),
      );
    }
    return _engine.sendMediaMessage(raw, listener: rawHandler);
  }

  /// Cancels an in-progress media message upload.
  ///
  /// [message] is the media message whose upload should be canceled.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> cancelSendingMessage(MediaMessage message, ErrorHandler handler) {
    return _engine.cancelSendingMediaMessage(
      message.raw as RCIMIWMediaMessage,
      callback: IRCIMIWCancelSendingMediaMessageCallback(
        onCancelSendingMediaMessageCalled:
            (code, msg) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Deletes the specified messages for the current user only.
  ///
  /// Deletes the remote message first and then deletes its local copy so the
  /// message is removed only for the current user.
  ///
  /// [messages] is the list of messages to delete.
  /// The [handler] is called with an [NCError]; on full success, `error.code` is `0`.
  Future<int> deleteMessagesForMe(
    List<Message> messages,
    ErrorHandler handler,
  ) {
    final identifier = channelIdentifier;
    final raws = messages.map((m) => m.raw).toList();
    return _engine.deleteMessages(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      raws,
      callback: IRCIMIWDeleteMessagesCallback(
        onMessagesDeleted: (code, msgs) {
          final remoteCode = code ?? 0;
          if (remoteCode != 0) {
            handler(Converter.toNCError(remoteCode));
            return;
          }
          _engine.deleteLocalMessages(
            raws,
            callback: IRCIMIWDeleteLocalMessagesCallback(
              onLocalMessagesDeleted: (localCode, localMsgs) {
                handler(Converter.toNCError(localCode ?? 0));
              },
            ),
          );
        },
      ),
    );
  }

  /// Deletes messages from local storage only by their client-side IDs.
  ///
  /// [messageClientIds] is the list of message client IDs to delete locally.
  /// The [handler] is called with an [NCError]; on success, `error.code` is `0`.
  static Future<int> deleteLocalMessages(
    List<int> messageClientIds,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.deleteLocalMessageByIds(
      messageClientIds,
      callback: IRCIMIWDeleteLocalMessageByIdsCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Deletes messages for the current user in this channel according to the given parameters.
  ///
  /// [params] specifies the timestamp cutoff and operation policy.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> deleteMessagesForMeByTimestamp(
    DeleteMessagesForMeByTimestampParams params,
    ErrorHandler handler,
  ) {
    final identifier = channelIdentifier;
    final rawPolicy = RCIMIWMessageOperationPolicy.values[params.policy.index];
    if (identifier.channelType == ChannelType.community) {
      return _engine.clearUltraGroupMessages(
        identifier.channelId,
        identifier.subChannelId ?? '',
        params.timestamp,
        rawPolicy,
        callback: IRCIMIWClearUltraGroupMessagesCallback(
          onUltraGroupMessagesCleared:
              (code) => handler(Converter.toNCError(code)),
        ),
      );
    }
    return _engine.clearMessages(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      params.timestamp,
      rawPolicy,
      callback: IRCIMIWClearMessagesCallback(
        onMessagesCleared: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sends a read receipt response for the specified message IDs.
  ///
  /// This acknowledges that the current user has read the given messages,
  /// notifying the senders.
  ///
  /// [messageIds] is the list of message IDs to mark as read.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> sendReadReceiptResponse(
    List<String> messageIds,
    ErrorHandler handler,
  ) {
    final identifier = channelIdentifier;
    return _engine.sendReadReceiptResponseV5(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      messageIds,
      callback: IRCIMIWSendReadReceiptResponseV5Callback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves read receipt information for the specified message IDs.
  ///
  /// [messageIds] is the list of message IDs to query.
  /// The [handler] receives a list of [ReadReceiptInfo] on success, or an error on failure.
  Future<int> getMessageReadReceiptInfo(
    List<String> messageIds,
    OperationHandler<List<ReadReceiptInfo>> handler,
  ) {
    final identifier = channelIdentifier;
    return _engine.getMessageReadReceiptInfoV5(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      messageIds,
      callback: IRCIMIWGetMessageReadReceiptInfoV5Callback(
        onSuccess:
            (t) => handler(
              t?.map((e) => ReadReceiptInfo.fromRaw(e)).toList(),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves read receipt information for messages identified by [MessageIdentifier]s.
  ///
  /// [identifiers] is the list of message identifiers to query.
  /// The [handler] receives a list of [ReadReceiptInfo] on success, or an error on failure.
  static Future<int> getMessageReadReceiptInfoByIdentifiers(
    List<MessageIdentifier> identifiers,
    OperationHandler<List<ReadReceiptInfo>> handler,
  ) {
    return NCEngine.engine.getMessageReadReceiptInfoV5ByIdentifiers(
      identifiers.map((e) => e.toRaw()).toList(),
      callback: IRCIMIWGetMessageReadReceiptInfoV5Callback(
        onSuccess:
            (t) => handler(t?.map(ReadReceiptInfo.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves read receipt details for a specific message, filtered by user IDs.
  ///
  /// [params] specifies the message ID and the list of user IDs to check.
  /// The [handler] receives a [MessageReadReceiptUsersResult] on success, or an error on failure.
  Future<int> getMessagesReadReceiptByUsers(
    GetMessagesReadReceiptByUsersParams params,
    OperationHandler<MessageReadReceiptUsersResult> handler,
  ) {
    final identifier = channelIdentifier;
    return NCEngine.engine.getMessagesReadReceiptByUsersV5(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      params.messageId,
      params.userIds,
      callback: IRCIMIWGetMessagesReadReceiptByUsersV5Callback(
        onSuccess:
            (t) => handler(
              t != null ? MessageReadReceiptUsersResult.fromRaw(t) : null,
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the tags associated with this channel.
  ///
  /// The [handler] receives a list of [Tag] on success, or an error on failure.
  Future<int> getTags(OperationHandler<List<Tag>> handler) {
    return _engine.getTagsFromConversation(
      Converter.toRCConversationType(channelType),
      channelId,
      callback: IRCIMIWGetTagsFromConversationCallback(
        onSuccess:
            (t) => handler(
              t
                  ?.map((e) => Tag.fromRaw(e.tagInfo ?? RCIMIWTagInfo.create()))
                  .toList(),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Inserts messages into the local database of this channel without sending them.
  ///
  /// Useful for importing historical messages or creating local-only messages.
  /// The SDK creates message objects internally from [params.messageParamsList],
  /// using channel information from this channel object.
  ///
  /// [params] carries the list of message parameters to create and insert.
  /// The [handler] receives the inserted messages on success, or an error on failure.
  Future<int> insertMessages(
    InsertMessagesParams params,
    OperationHandler<List<Message>> handler,
  ) async {
    final identifier = channelIdentifier;
    final type = Converter.toRCConversationType(identifier.channelType);
    final subId = identifier.subChannelId;

    final List<RCIMIWMessage> rawMessages = [];
    for (final mp in params.messageParamsList) {
      final raw = await _createRawMessage(type, subId, mp);
      if (raw != null) rawMessages.add(raw);
    }

    if (rawMessages.isEmpty) return -1;

    return _engine.insertMessages(
      rawMessages,
      callback: IRCIMIWInsertMessagesCallback(
        onMessagesInserted:
            (code, msgs) => handler(
              msgs?.map((e) => Message.fromRaw(e)).toList(),
              Converter.toNCError(code),
            ),
      ),
    );
  }

  /// Retrieves all channels that have unread messages for the given channel types.
  ///
  /// [channelTypes] is the list of channel types to query.
  /// The [handler] receives a list of channels with unread messages, or an error on failure.
  static Future<int> getUnreadChannels(
    List<ChannelType> channelTypes,
    OperationHandler<List<BaseChannel>> handler,
  ) {
    return NCEngine.engine.getUnreadConversations(
      Converter.toRCConversationTypes(channelTypes),
      callback: IRCIMIWGetUnreadConversationsCallback(
        onSuccess: (t) => handler(Converter.toChannels(t), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the total unread message count across all channels.
  ///
  /// The [handler] receives the total count on success, or an error on failure.
  static Future<int> getTotalUnreadCount(OperationHandler<int> handler) {
    return NCEngine.engine.getTotalUnreadCount(
      null,
      callback: IRCIMIWGetTotalUnreadCountCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Synchronizes the local channel list with the remote server.
  ///
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  static Future<int> syncRemoteChannels(ErrorHandler handler) {
    return NCEngine.engine.getRemoteConversationList(
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves channels by the given identifiers.
  ///
  /// [identifiers] is the list of channel identifiers to fetch.
  /// The [handler] receives the matching channels on success, or an error on failure.
  static Future<int> getChannels(
    List<ChannelIdentifier> identifiers,
    OperationHandler<List<BaseChannel>> handler,
  ) {
    if (identifiers.isEmpty) {
      handler(null, Converter.toNCError(34232));
      return Future.value(34232);
    }
    final types =
        identifiers
            .map((i) => Converter.toRCConversationType(i.channelType))
            .toList();
    final targetIds = identifiers.map((i) => i.channelId).toList();
    final channelIds = identifiers.map((i) => i.subChannelId ?? '').toList();
    return NCEngine.engine.getConversationsByIdentifiers(
      types,
      targetIds,
      channelIds,
      callback: IRCIMIWGetConversationsCallback(
        onSuccess: (t) => handler(Converter.toChannels(t), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves all pinned (top) channels for the given channel types.
  ///
  /// [channelTypes] is the list of channel types to query.
  /// The [handler] receives the pinned channels on success, or an error on failure.
  static Future<int> getPinnedChannels(
    List<ChannelType> channelTypes,
    OperationHandler<List<BaseChannel>> handler,
  ) {
    return NCEngine.engine.getTopConversations(
      Converter.toRCConversationTypes(channelTypes),
      null,
      callback: IRCIMIWGetTopConversationsCallback(
        onSuccess: (t) => handler(Converter.toChannels(t), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Deletes all channels of the specified types from the channel list.
  ///
  /// [types] is the list of channel types to delete.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  static Future<int> deleteChannels(
    List<ChannelIdentifier> identifiers,
    ErrorHandler handler,
  ) {
    if (identifiers.isEmpty) {
      handler(Converter.toNCError(34232));
      return Future.value(34232);
    }
    final types =
        identifiers
            .map((i) => Converter.toRCConversationType(i.channelType))
            .toList();
    final targetIds = identifiers.map((i) => i.channelId).toList();
    final channelIds = identifiers.map((i) => i.subChannelId ?? '').toList();
    return NCEngine.engine.removeConversationsByIdentifiers(
      types,
      targetIds,
      channelIds,
      callback: IRCIMIWCompletionCallback(
        onCompleted: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the notification (do-not-disturb) level for an entire channel type.
  ///
  /// [params] specifies the channel type and desired notification level.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  static Future<int> setChannelTypeNoDisturbLevel(
    ChannelTypeNoDisturbLevelParams params,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.changeConversationTypeNotificationLevel(
      Converter.toRCConversationType(params.channelType),
      RCIMIWPushNotificationLevel.values[params.level.index],
      callback: IRCIMIWChangeConversationTypeNotificationLevelCallback(
        onConversationTypeNotificationLevelChanged:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the notification (do-not-disturb) level for a given channel type.
  ///
  /// [channelType] is the channel type to query.
  /// The [handler] receives the [ChannelNoDisturbLevel] on success, or an
  /// error on failure.
  static Future<int> getChannelTypeNoDisturbLevel(
    ChannelType channelType,
    OperationHandler<ChannelNoDisturbLevel> handler,
  ) {
    return NCEngine.engine.getConversationTypeNotificationLevel(
      Converter.toRCConversationType(channelType),
      callback: IRCIMIWGetConversationTypeNotificationLevelCallback(
        onSuccess:
            (level) => handler(
              level != null ? ChannelNoDisturbLevel.values[level.index] : null,
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Searches channels by keyword and message types.
  ///
  /// [params] specifies the channel types, message types, and search keyword.
  /// The [handler] receives matching [SearchChannelResult]s on success, or an error on failure.
  static Future<int> searchChannels(
    SearchChannelsParams params,
    OperationHandler<List<SearchChannelResult>> handler,
  ) {
    return NCEngine.engine.searchConversations(
      Converter.toRCConversationTypes(params.channelTypes),
      null,
      params.messageTypes
          .map((t) => RCIMIWMessageType.values[t.index])
          .toList(),
      params.keyword,
      callback: IRCIMIWSearchConversationsCallback(
        onSuccess:
            (t) => handler(
              t?.map((e) => SearchChannelResult.fromRaw(e)).toList(),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves a single message by its client-side ID or server-side message ID.
  ///
  /// If [GetMessageByIdParams.messageId] is provided, it takes priority
  /// over [GetMessageByIdParams.messageClientId].
  ///
  /// The [handler] receives the [Message] on success, or an error on failure.
  static Future<int> getMessageById(
    GetMessageByIdParams params,
    OperationHandler<Message> handler,
  ) {
    final engine = NCEngine.engine;
    if (params.messageId != null) {
      return engine.getMessageByUId(
        params.messageId!,
        callback: IRCIMIWGetMessageCallback(
          onSuccess:
              (t) => handler(t != null ? Message.fromRaw(t) : null, null),
          onError: (code) => handler(null, Converter.toNCError(code)),
        ),
      );
    }
    return engine.getMessageById(
      params.messageClientId ?? 0,
      callback: IRCIMIWGetMessageCallback(
        onSuccess: (t) => handler(t != null ? Message.fromRaw(t) : null, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Creates a paginated query for listing channels.
  ///
  /// [params] configures the channel types and pagination options.
  static ChannelsQuery createChannelsQuery(ChannelsQueryParams params) {
    return ChannelsQuery(params);
  }

  /// Creates a paginated query for listing users who have read a specific message.
  ///
  /// [params] configures the message and pagination options.
  static MessagesReadReceiptUsersQuery createMessagesReadReceiptUsersQuery(
    MessagesReadReceiptUsersQueryParams params,
  ) {
    return MessagesReadReceiptUsersQuery(params);
  }

  /// Creates a paginated query for loading messages in a channel.
  ///
  /// [params] configures the channel, direction, and pagination options.
  static MessagesQuery createMessagesQuery(MessagesQueryParams params) {
    return MessagesQuery(params);
  }

  /// Creates a query for searching messages by keyword in a channel.
  ///
  /// [params] configures the channel, keyword, and pagination options.
  static SearchMessagesQuery createSearchMessagesQuery(
    SearchMessagesQueryParams params,
  ) {
    return SearchMessagesQuery(params);
  }

  /// Creates a query for searching messages sent by a specific user.
  ///
  /// [params] configures the channel, user ID, and pagination options.
  static SearchMessagesByUserQuery createSearchMessagesByUserQuery(
    SearchMessagesByUserQueryParams params,
  ) {
    return SearchMessagesByUserQuery(params);
  }

  /// Creates a query for searching messages within a specific time range.
  ///
  /// [params] configures the channel, time range, and pagination options.
  static SearchMessagesByTimeRangeQuery createSearchMessagesByTimeRangeQuery(
    SearchMessagesByTimeRangeQueryParams params,
  ) {
    return SearchMessagesByTimeRangeQuery(params);
  }

  /// Recalls (deletes for all users) a sent message.
  ///
  /// [message] is the message to recall.
  /// The [handler] receives the recalled message on success, or `null` on failure.
  static Future<int> deleteMessageForAll(
    Message message,
    OperationHandler<Message> handler,
  ) {
    return NCEngine.engine.recallMessageWithOption(
      message.raw,
      true,
      callback: IRCIMIWRecallMessageCallback(
        onMessageRecalled:
            (code, msg) => handler(
              msg != null ? Converter.fromRawMessage(msg) : null,
              Converter.toNCError(code),
            ),
      ),
    );
  }

  /// Removes the specified tags from this channel.
  ///
  /// [tagIds] is the list of tag IDs to remove.
  /// The [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> deleteTags(List<String> tagIds, ErrorHandler handler) {
    return _engine.removeTagsFromConversation(
      Converter.toRCConversationType(channelType),
      channelId,
      tagIds,
      callback: IRCIMIWRemoveTagsFromConversationCallback(
        onTagsFromConversationRemoved:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves messages around a specific timestamp in this channel.
  ///
  /// [params] specifies the reference time and how many messages to fetch
  /// before and after that time.
  /// The [handler] receives the list of [Message]s on success, or an error on failure.
  Future<int> getMessagesAroundTime(
    GetMessagesAroundTimeParams params,
    OperationHandler<List<Message>> handler,
  ) {
    final identifier = channelIdentifier;
    return NCEngine.engine.getMessagesAroundTime(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      params.sentTime,
      params.beforeCount,
      params.afterCount,
      callback: IRCIMIWGetMessagesAroundTimeCallback(
        onSuccess:
            (t) => handler(t?.map(Converter.fromRawMessage).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves all unread messages that contain @mentions in this channel.
  ///
  /// The [handler] receives the list of mentioned [Message]s on success,
  /// or an error on failure.
  Future<int> getUnreadMentionedMessages(
    OperationHandler<List<Message>> handler,
  ) {
    final identifier = channelIdentifier;
    return NCEngine.engine.getUnreadMentionedMessages(
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      identifier.subChannelId,
      callback: IRCIMIWGetUnreadMentionedMessagesCallback(
        onSuccess:
            (t) => handler(t?.map(Converter.fromRawMessage).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the unread message count filtered by channel types and notification levels.
  ///
  /// [params] specifies the channel types and notification levels to filter by.
  /// The [handler] receives the count on success, or an error on failure.
  static Future<int> getChannelsUnreadCountByNoDisturbLevel(
    ChannelsUnreadCountParams params,
    OperationHandler<int> handler,
  ) {
    return NCEngine.engine.getUnreadCountByLevels(
      params.channelTypes
          .map((c) => Converter.toRCConversationType(c))
          .toList(),
      params.levels
          .map((l) => RCIMIWPushNotificationLevel.values[l.index])
          .toList(),
      callback: IRCIMIWGetUnreadCountByLevelsCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }
}
