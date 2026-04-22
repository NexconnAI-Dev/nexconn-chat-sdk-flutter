import '../error/nc_error.dart';
import '../message/message.dart';
import '../message/stream_message.dart';
import '../model/blocked_message_info.dart';
import '../model/read_receipt_response_v5.dart';
import '../model/speech_to_text_info.dart';

/// Event fired when a new message is received.
class MessageReceivedEvent {
  /// The received message.
  final Message message;

  /// The number of remaining messages in the current batch.
  final int? left;

  /// Whether this message was received while offline.
  final bool? offline;

  /// Whether this message belongs to a batch package.
  final bool? hasPackage;

  /// Creates a [MessageReceivedEvent].
  const MessageReceivedEvent({
    required this.message,
    this.left,
    this.offline,
    this.hasPackage,
  });
}

/// Event fired when messages are deleted (including recalled messages).
class MessageDeletedEvent {
  /// The deleted messages.
  final List<Message>? messages;

  /// Creates a [MessageDeletedEvent].
  const MessageDeletedEvent({this.messages});
}

/// Event fired when message metadata is updated.
class MessageMetadataUpdatedEvent {
  /// The updated metadata key-value pairs.
  final Map? metadata;

  /// The message whose metadata was updated.
  final Message? message;

  /// Creates a [MessageMetadataUpdatedEvent].
  const MessageMetadataUpdatedEvent({this.metadata, this.message});
}

/// Event fired when message metadata keys are deleted.
class MessageMetadataDeletedEvent {
  /// The message whose metadata keys were removed.
  final Message? message;

  /// The list of removed metadata keys.
  final List<String>? keys;

  /// Creates a [MessageMetadataDeletedEvent].
  const MessageMetadataDeletedEvent({this.message, this.keys});
}

/// Event fired when message metadata changes in a community channel.
class CommunityChannelMessageMetadataChangedEvent {
  /// The messages with changed metadata.
  final List<Message> messages;

  /// Creates a [CommunityChannelMessageMetadataChangedEvent].
  const CommunityChannelMessageMetadataChangedEvent({required this.messages});
}

/// Event fired when read receipt responses are received.
class MessageReceiptResponseEvent {
  /// The list of read receipt responses.
  final List<MessageReadReceiptResponse>? responses;

  /// Creates a [MessageReceiptResponseEvent].
  const MessageReceiptResponseEvent({this.responses});
}

/// Event fired when offline message synchronization completes.
class OfflineMessageSyncCompletedEvent {
  /// Creates an [OfflineMessageSyncCompletedEvent].
  const OfflineMessageSyncCompletedEvent();
}

/// Event fired when speech-to-text conversion completes.
class SpeechToTextCompletedEvent {
  /// The speech-to-text result information.
  final SpeechToTextInfo? info;

  /// The identifier of the message that was converted.
  final String messageId;

  /// The raw result code from the server.
  final int? code;

  /// The error if the conversion failed, or `null` on success.
  final NCError? error;

  /// Creates a [SpeechToTextCompletedEvent].
  const SpeechToTextCompletedEvent({
    this.info,
    required this.messageId,
    this.code,
    this.error,
  });
}

/// Event fired when a message is blocked by the server's content moderation.
class MessageBlockedEvent {
  /// The blocked message details.
  final BlockedMessageInfo? info;

  /// Creates a [MessageBlockedEvent].
  const MessageBlockedEvent({this.info});
}

/// Event fired when a stream message request is initialized.
class StreamMessageRequestInitEvent {
  /// The identifier of the stream message being initialized.
  final String messageId;

  /// Creates a [StreamMessageRequestInitEvent].
  const StreamMessageRequestInitEvent({required this.messageId});
}

/// A chunk of content received during stream message delivery.
class StreamMessageRequestChunkInfo {
  /// The text content of this chunk.
  final String? content;

  /// Creates a [StreamMessageRequestChunkInfo].
  const StreamMessageRequestChunkInfo({this.content});
}

/// Event fired when a stream message receives incremental data.
class StreamMessageDeltaEvent {
  /// The stream message being updated.
  final StreamMessage? message;

  /// The incremental chunk data received.
  final StreamMessageRequestChunkInfo? chunkInfo;

  /// Creates a [StreamMessageDeltaEvent].
  const StreamMessageDeltaEvent({this.message, this.chunkInfo});
}

/// Event fired when a stream message request completes.
class StreamMessageRequestCompleteEvent {
  /// The identifier of the completed stream message.
  final String messageId;

  /// The result code of the stream request. `0` indicates success; any other
  /// value is an error code.
  final int code;

  /// Creates a [StreamMessageRequestCompleteEvent].
  const StreamMessageRequestCompleteEvent({
    required this.messageId,
    required this.code,
  });

  /// Convenience getter: the [NCError] when [code] is non-zero, otherwise `null`.
  NCError? get error => code == 0 ? null : NCError(code: code);
}

/// Callback invoked when a new message is received.
typedef OnMessageReceived = void Function(MessageReceivedEvent event);

/// Callback invoked when messages are deleted.
typedef OnMessageDeleted = void Function(MessageDeletedEvent event);

/// Callback invoked when message metadata is updated.
typedef OnMessageMetadataUpdated =
    void Function(MessageMetadataUpdatedEvent event);

/// Callback invoked when message metadata keys are deleted.
typedef OnMessageMetadataDeleted =
    void Function(MessageMetadataDeletedEvent event);

/// Callback invoked when community channel message metadata changes.
typedef OnCommunityChannelMessageMetadataChanged =
    void Function(CommunityChannelMessageMetadataChangedEvent event);

/// Callback invoked when read receipt responses are received.
typedef OnMessageReceiptResponse =
    void Function(MessageReceiptResponseEvent event);

/// Callback invoked when offline message synchronization completes.
typedef OnOfflineMessageSyncCompleted =
    void Function(OfflineMessageSyncCompletedEvent event);

/// Callback invoked when speech-to-text conversion completes.
typedef OnSpeechToTextCompleted =
    void Function(SpeechToTextCompletedEvent event);

/// Callback invoked when a message is blocked by content moderation.
typedef OnMessageBlocked = void Function(MessageBlockedEvent event);

/// Callback invoked when a stream message request is initialized.
typedef OnStreamMessageRequestInit =
    void Function(StreamMessageRequestInitEvent event);

/// Callback invoked when a stream message receives incremental data.
typedef OnStreamMessageRequestDelta =
    void Function(StreamMessageDeltaEvent event);

/// Callback invoked when a stream message request completes.
typedef OnStreamMessageRequestComplete =
    void Function(StreamMessageRequestCompleteEvent event);

/// Handler for message-related global events.
///
/// Register this handler via [NCEngine.addMessageHandler] to receive
/// notifications about incoming messages, deletions, metadata changes,
/// read receipts, stream messages, and other message lifecycle events.
class MessageHandler {
  /// Called when a new message is received.
  final OnMessageReceived? onMessageReceived;

  /// Called when messages are deleted or recalled.
  final OnMessageDeleted? onMessageDeleted;

  /// Called when message metadata is updated.
  final OnMessageMetadataUpdated? onMessageMetadataUpdated;

  /// Called when message metadata keys are deleted.
  final OnMessageMetadataDeleted? onMessageMetadataDeleted;

  /// Called when community channel message metadata changes.
  final OnCommunityChannelMessageMetadataChanged?
  onCommunityChannelMessageMetadataChanged;

  /// Called when read receipt responses are received.
  final OnMessageReceiptResponse? onMessageReceiptResponse;

  /// Called when offline message synchronization completes.
  final OnOfflineMessageSyncCompleted? onOfflineMessageSyncCompleted;

  /// Called when speech-to-text conversion completes.
  final OnSpeechToTextCompleted? onSpeechToTextCompleted;

  /// Called when a message is blocked by content moderation.
  final OnMessageBlocked? onMessageBlocked;

  /// Called when a stream message request is initialized.
  final OnStreamMessageRequestInit? onStreamMessageRequestInit;

  /// Called when a stream message receives incremental data.
  final OnStreamMessageRequestDelta? onStreamMessageRequestDelta;

  /// Called when a stream message request completes.
  final OnStreamMessageRequestComplete? onStreamMessageRequestComplete;

  /// Creates a [MessageHandler].
  MessageHandler({
    this.onMessageReceived,
    this.onMessageDeleted,
    this.onMessageMetadataUpdated,
    this.onMessageMetadataDeleted,
    this.onCommunityChannelMessageMetadataChanged,
    this.onMessageReceiptResponse,
    this.onOfflineMessageSyncCompleted,
    this.onSpeechToTextCompleted,
    this.onMessageBlocked,
    this.onStreamMessageRequestInit,
    this.onStreamMessageRequestDelta,
    this.onStreamMessageRequestComplete,
  });
}
