import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/reference_message_status.dart';
import 'message.dart';

/// Parameters for creating a [ReferenceMessage].
class ReferenceMessageParams extends MessageParams {
  /// The original message being referenced (replied to).
  final Message referenceMessage;

  /// The reply text content.
  final String text;

  /// Creates [ReferenceMessageParams] with the required reference message and reply text.
  ReferenceMessageParams({
    required this.referenceMessage,
    required this.text,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A reference (reply) message in the Nexconn IM SDK.
///
/// Extends [Message] to represent a reply that references another message.
/// Contains both the reply text and the original referenced message.
class ReferenceMessage extends Message {
  /// Creates a [ReferenceMessage] by wrapping a raw message object.
  ReferenceMessage.wrap(super.raw) : super.wrap();

  /// Creates a [ReferenceMessage] from an existing SDK object.
  static ReferenceMessage fromRaw(RCIMIWReferenceMessage raw) =>
      ReferenceMessage.wrap(raw);

  RCIMIWReferenceMessage get _refRaw => raw as RCIMIWReferenceMessage;

  /// Returns the successful edited content when the native SDK keeps it in
  /// [RCIMIWMessage.modifyInfo] instead of replacing the outer message body.
  RCIMIWReferenceMessage get _effectiveRefRaw {
    final info = raw.modifyInfo;
    final content = info?.content;
    if (raw.hasChanged == true &&
        info?.status == RCIMIWMessageModifyStatus.success &&
        content is RCIMIWReferenceMessage) {
      return content;
    }
    return _refRaw;
  }

  RCIMIWMessage? get _effectiveReferencedRaw {
    final effective = _effectiveRefRaw;
    final referenced = effective.referenceMessage;
    if (referenced == null || identical(effective, _refRaw)) return referenced;

    final original = _refRaw.referenceMessage;
    if (original != null) {
      _restoreMissingReferencedMessageIdentity(referenced, original);
    }
    return referenced;
  }

  static void _restoreMissingReferencedMessageIdentity(
    RCIMIWMessage target,
    RCIMIWMessage source,
  ) {
    if (target.conversationType == null ||
        target.conversationType == RCIMIWConversationType.invalid) {
      target.conversationType = source.conversationType;
    }
    if (target.messageType == null ||
        target.messageType == RCIMIWMessageType.unknown) {
      target.messageType = source.messageType;
    }
    if (target.targetId?.isNotEmpty != true) {
      target.targetId = source.targetId;
    }
    if (target.channelId == null ||
        (target.channelId!.isEmpty && source.channelId?.isNotEmpty == true)) {
      target.channelId = source.channelId;
    }
    target.messageId ??= source.messageId;
    if (target.messageUId?.isNotEmpty != true) {
      target.messageUId = source.messageUId;
    }
    target.offLine ??= source.offLine;
    target.groupReadReceiptInfo ??= source.groupReadReceiptInfo;
    target.receivedTime ??= source.receivedTime;
    target.sentTime ??= source.sentTime;
    target.destructDuration ??= source.destructDuration;
    target.receivedStatus ??= source.receivedStatus;
    target.receivedStatusInfo ??= source.receivedStatusInfo;
    target.sentStatus ??= source.sentStatus;
    if (target.senderUserId?.isNotEmpty != true) {
      target.senderUserId = source.senderUserId;
    }
    target.direction ??= source.direction;
    target.userInfo ??= source.userInfo;
    target.mentionedInfo ??= source.mentionedInfo;
    target.pushOptions ??= source.pushOptions;
    target.extra ??= source.extra;
    target.localExtra ??= source.localExtra;
    target.expansion ??=
        source.expansion == null
            ? null
            : Map<dynamic, dynamic>.of(source.expansion!);
    target.canIncludeExpansion ??= source.canIncludeExpansion;
    target.auditInfo ??= source.auditInfo;
    target.directedUserIds ??=
        source.directedUserIds == null
            ? null
            : List<String>.of(source.directedUserIds!);
    target.needReceipt ??= source.needReceipt;
    target.sentReceipt ??= source.sentReceipt;
    target.hasChanged ??= source.hasChanged;

    if (target is RCIMIWReferenceMessage && source is RCIMIWReferenceMessage) {
      target.referMsgStatus ??= source.referMsgStatus;
      final targetReference = target.referenceMessage;
      final sourceReference = source.referenceMessage;
      if (targetReference != null && sourceReference != null) {
        _restoreMissingReferencedMessageIdentity(
          targetReference,
          sourceReference,
        );
      }
    }
  }

  /// The reply text content.
  String? get text => _effectiveRefRaw.text;

  /// Sets the reply text content.
  set text(String? v) => _effectiveRefRaw.text = v;

  /// The original message that this message references (replies to).
  Message? get referenceMsg {
    final referenced = _effectiveReferencedRaw;
    return referenced == null ? null : Message.fromRaw(referenced);
  }

  /// Replaces the embedded referenced message snapshot after a refresh.
  set referenceMsg(Message? value) {
    final effective = _effectiveRefRaw;
    _refRaw.referenceMessage = value?.raw;
    if (!identical(effective, _refRaw)) {
      effective.referenceMessage = value?.raw;
    }
  }

  /// The current state of the referenced message.
  ReferenceMessageStatus? get referenceMessageStatus {
    final outer = _fromRawReferenceStatus(_refRaw.referMsgStatus);
    final effective = _fromRawReferenceStatus(_effectiveRefRaw.referMsgStatus);
    return _strongerReferenceStatus(outer, effective);
  }

  set referenceMessageStatus(ReferenceMessageStatus? value) {
    final effective = _effectiveRefRaw;
    final rawValue = _toRawReferenceStatus(value);
    _refRaw.referMsgStatus = rawValue;
    if (!identical(effective, _refRaw)) {
      effective.referMsgStatus = rawValue;
    }
  }

  static ReferenceMessageStatus? _strongerReferenceStatus(
    ReferenceMessageStatus? first,
    ReferenceMessageStatus? second,
  ) {
    if (first == null) return second;
    if (second == null) return first;
    return _referenceStatusRank(first) >= _referenceStatusRank(second)
        ? first
        : second;
  }

  static int _referenceStatusRank(ReferenceMessageStatus value) {
    return switch (value) {
      ReferenceMessageStatus.defaultValue => 0,
      ReferenceMessageStatus.modified => 1,
      ReferenceMessageStatus.recalled => 2,
      ReferenceMessageStatus.deleted => 3,
    };
  }

  static ReferenceMessageStatus? _fromRawReferenceStatus(
    RCIMIWReferenceMessageStatus? value,
  ) {
    switch (value) {
      case null:
        return null;
      case RCIMIWReferenceMessageStatus.defaultValue:
        return ReferenceMessageStatus.defaultValue;
      case RCIMIWReferenceMessageStatus.modified:
        return ReferenceMessageStatus.modified;
      case RCIMIWReferenceMessageStatus.recalled:
        return ReferenceMessageStatus.recalled;
      case RCIMIWReferenceMessageStatus.deleted:
        return ReferenceMessageStatus.deleted;
    }
  }

  static RCIMIWReferenceMessageStatus? _toRawReferenceStatus(
    ReferenceMessageStatus? value,
  ) {
    switch (value) {
      case null:
        return null;
      case ReferenceMessageStatus.defaultValue:
        return RCIMIWReferenceMessageStatus.defaultValue;
      case ReferenceMessageStatus.modified:
        return RCIMIWReferenceMessageStatus.modified;
      case ReferenceMessageStatus.recalled:
        return RCIMIWReferenceMessageStatus.recalled;
      case ReferenceMessageStatus.deleted:
        return RCIMIWReferenceMessageStatus.deleted;
    }
  }

  @override
  Map<String, dynamic> extraJson() => {
    'text': text,
    'referenceMessage': referenceMsg?.toJson(),
    'referenceMessageStatus': referenceMessageStatus?.name,
  };
}
