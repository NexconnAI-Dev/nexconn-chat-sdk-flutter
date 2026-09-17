part of 'nc_engine.dart';

void _notifyMessageReceived(
  RCIMIWMessage? message,
  int? left,
  bool? offline,
  bool? hasPackage,
) {
  dynamic wrapped;
  try {
    wrapped = message != null ? Converter.fromRawMessage(message) : null;
  } catch (e, s) {
    debugPrint(
      '[NCEngine] fromRawMessage failed (${message.runtimeType}): $e\n$s',
    );
  }
  if (wrapped == null) return;
  debugPrint(
    '[NCEngine] onMessageReceived: type=${message.runtimeType}, handlers=${NCEngine._messageHandlers.length}',
  );
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageReceived?.call(
      MessageReceivedEvent(
        message: wrapped,
        left: left,
        offline: offline,
        hasPackage: hasPackage,
      ),
    ),
  );
}

void _notifyMessageDeleted(List<RCIMIWMessage>? messages) {
  final wrapped = messages?.map(Converter.fromRawMessage).toList();
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageDeleted?.call(MessageDeletedEvent(messages: wrapped)),
  );
}

void _notifyMessageMetadataUpdated(Map? metadata, RCIMIWMessage? message) {
  final wrapped = message != null ? Converter.fromRawMessage(message) : null;
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageMetadataUpdated?.call(
      MessageMetadataUpdatedEvent(metadata: metadata, message: wrapped),
    ),
  );
}

void _notifyMessageMetadataDeleted(RCIMIWMessage? message, List<String>? keys) {
  final wrapped = message != null ? Converter.fromRawMessage(message) : null;
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageMetadataDeleted?.call(
      MessageMetadataDeletedEvent(message: wrapped, keys: keys),
    ),
  );
}

void _notifyCommunityChannelMessageMetadataChanged(
  List<RCIMIWMessage>? messages,
) {
  final wrapped = messages?.map(Converter.fromRawMessage).toList();
  if (wrapped == null || wrapped.isEmpty) return;
  NCEngine._messageHandlers.notify(
    (h) => h.onCommunityChannelMessageMetadataChanged?.call(
      CommunityChannelMessageMetadataChangedEvent(messages: wrapped),
    ),
  );
}

void _notifyMessageReceiptResponse(
  List<RCIMIWReadReceiptResponseV5>? responses,
) {
  final wrapped = responses?.map(MessageReadReceiptResponse.fromRaw).toList();
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageReceiptResponse?.call(
      MessageReceiptResponseEvent(responses: wrapped),
    ),
  );
}

void _notifyOfflineMessageSyncCompleted() {
  NCEngine._messageHandlers.notify(
    (h) => h.onOfflineMessageSyncCompleted?.call(
      const OfflineMessageSyncCompletedEvent(),
    ),
  );
}

void _notifySpeechToTextCompleted(
  RCIMIWSpeechToTextInfo? info,
  String? messageId,
  int? code,
) {
  final wrapped = info != null ? SpeechToTextInfo.fromRaw(info) : null;
  NCEngine._messageHandlers.notify(
    (h) => h.onSpeechToTextCompleted?.call(
      SpeechToTextCompletedEvent(
        info: wrapped,
        messageId: messageId ?? '',
        code: code,
        error: Converter.toNCError(code),
      ),
    ),
  );
}

void _notifyMessageBlocked(RCIMIWBlockedMessageInfo? info) {
  final wrapped = info != null ? BlockedMessageInfo.fromRaw(info) : null;
  NCEngine._messageHandlers.notify(
    (h) => h.onMessageBlocked?.call(MessageBlockedEvent(info: wrapped)),
  );
}

void _notifyStreamMessageRequestInit(String? messageId) {
  NCEngine._messageHandlers.notify(
    (h) => h.onStreamMessageRequestInit?.call(
      StreamMessageRequestInitEvent(messageId: messageId ?? ''),
    ),
  );
}

void _notifyStreamMessageRequestDelta(
  RCIMIWMessage? message,
  RCIMIWStreamMessageChunkInfo? chunkInfo,
) {
  final wrapped =
      message is RCIMIWStreamMessage ? StreamMessage.fromRaw(message) : null;
  NCEngine._messageHandlers.notify(
    (h) => h.onStreamMessageRequestDelta?.call(
      StreamMessageDeltaEvent(
        message: wrapped,
        chunkInfo:
            chunkInfo != null
                ? StreamMessageRequestChunkInfo(content: chunkInfo.content)
                : null,
      ),
    ),
  );
}

void _notifyStreamMessageRequestComplete(String? messageId, int? code) {
  NCEngine._messageHandlers.notify(
    (h) => h.onStreamMessageRequestComplete?.call(
      StreamMessageRequestCompleteEvent(
        messageId: messageId ?? '',
        code: code ?? 0,
      ),
    ),
  );
}
