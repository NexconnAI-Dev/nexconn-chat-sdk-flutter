import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../channel/base_channel.dart';
import '../enum/channel_type.dart';
import '../enum/message_type.dart';
import '../enum/message_direction.dart';
import '../enum/sent_status.dart';
import '../enum/received_status.dart';
import '../engine/nc_engine.dart';
import '../internal/converter.dart';
import '../internal/types.dart';
import 'mentioned_info.dart';
import 'received_status_info.dart';
import 'group_read_receipt_info.dart';
import 'user_info.dart';

/// Base class for all message creation parameters.
///
/// Each message type provides its own parameter subclass to describe message
/// content. Shared send-time options, such as [mentionedInfo] and
/// [needReceipt], are defined here.
///
/// Channel information is not stored in this object. It is obtained from the
/// [BaseChannel] at send time.
abstract class MessageParams {
  /// Optional mention information carried with the message.
  final MentionedInfoParams? mentionedInfo;

  /// Whether this outgoing message requires a read receipt.
  final bool? needReceipt;

  const MessageParams({this.mentionedInfo, this.needReceipt});
}

/// Base class for all message instances.
///
/// This class wraps message data and exposes common properties such as channel
/// information, timestamps, sender, direction, and metadata.
class Message {
  /// The associated SDK object for advanced usage.
  final RCIMIWMessage raw;

  /// Creates a [Message] from an existing message object.
  Message.wrap(this.raw);

  /// Creates the appropriate [Message] subclass from message data.
  static Message fromRaw(RCIMIWMessage raw) => Converter.fromRawMessage(raw);

  /// Serializes the message into a JSON-compatible `Map`.
  ///
  /// When [filterEmpty] is `true`, null values are removed while empty nested
  /// `Map` and `List` values are preserved.
  Map<String, dynamic> toJson({bool filterEmpty = true}) {
    final json = <String, dynamic>{
      'channelType': channelType?.name,
      'channelId': channelId,
      'subChannelId': subChannelId,
      'messageType': messageType?.name,
      'clientId': clientId,
      'messageId': messageId,
      'offLine': offLine,
      'groupReadReceiptInfo': groupReadReceiptInfo?.toJson(),
      'receivedTime': receivedTime,
      'sentTime': sentTime,
      'receivedStatus': receivedStatus?.name,
      'receivedStatusInfo': receivedStatusInfo?.toJson(),
      'sentStatus': sentStatus?.name,
      'senderUserId': senderUserId,
      'direction': direction?.name,
      'userInfo': userInfo?.toJson(),
      'mentionedInfo': mentionedInfo?.toJson(),
      'extra': extra,
      'localExtra': localExtra,
      'metadata': metadata,
      'canIncludeMetadata': canIncludeMetadata,
      'directedUserIds': directedUserIds,
      'needReceipt': needReceipt,
      'sentReceipt': sentReceipt,
      ...extraJson(),
    };
    return filterEmpty ? _compactJsonMap(json) : json;
  }

  /// Additional subtype-specific fields merged into the result of [toJson].
  Map<String, dynamic> extraJson() => const {};

  static Map<String, dynamic> _compactJsonMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final value = _compactJsonValue(entry.value);
      if (value != null) {
        result[entry.key] = value;
      }
    }
    return result;
  }

  static dynamic _compactJsonValue(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return _compactJsonMap(
        value.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    if (value is List) {
      return value
          .map(_compactJsonValue)
          .where((item) => item != null)
          .toList();
    }
    return value;
  }

  /// The channel identifier containing channel type, channel ID, and optional sub-channel ID.
  ChannelIdentifier? get channelIdentifier => ChannelIdentifier(
    channelType: Converter.fromRCConversationType(raw.conversationType!),
    channelId: raw.targetId ?? '',
    subChannelId: raw.channelId,
  );

  /// The type of channel (e.g., private, group, system) this message belongs to.
  ChannelType? get channelType =>
      raw.conversationType != null
          ? Converter.fromRCConversationType(raw.conversationType!)
          : null;

  /// The type of this message (e.g., text, image, voice).
  MessageType? get messageType =>
      raw.messageType != null
          ? MessageType.values[raw.messageType!.index]
          : null;

  /// The target channel ID this message is associated with.
  String? get channelId => raw.targetId;

  /// The sub-channel ID, used for community channels or threaded channels.
  String? get subChannelId => raw.channelId;

  /// The local client-side message ID (auto-incremented integer).
  int? get clientId => raw.messageId;

  /// The server-generated globally unique message ID.
  String? get messageId => raw.messageUId;

  /// Whether this message was received while the user was offline.
  bool? get offLine => raw.offLine;

  /// Group read receipt information, available for group messages with read receipts enabled.
  GroupReadReceiptInfo? get groupReadReceiptInfo =>
      raw.groupReadReceiptInfo != null
          ? GroupReadReceiptInfo.fromRaw(raw.groupReadReceiptInfo!)
          : null;

  /// The timestamp (in milliseconds) when this message was received.
  int? get receivedTime => raw.receivedTime;

  /// The timestamp (in milliseconds) when this message was sent.
  int? get sentTime => raw.sentTime;

  /// The received status of this message (e.g., unread, read).
  ReceivedStatus? get receivedStatus =>
      raw.receivedStatus != null
          ? ReceivedStatus.values[raw.receivedStatus!.index]
          : null;

  /// Detailed received status info including read, listened, downloaded, and retrieved flags.
  ReceivedStatusInfo? get receivedStatusInfo =>
      raw.receivedStatusInfo != null
          ? ReceivedStatusInfo.fromRaw(raw.receivedStatusInfo!)
          : null;

  /// The sent status of this message (e.g., sending, sent, failed, canceled).
  SentStatus? get sentStatus =>
      raw.sentStatus != null ? SentStatus.values[raw.sentStatus!.index] : null;

  /// The user ID of the message sender.
  String? get senderUserId => raw.senderUserId;

  /// The direction of this message (send or receive).
  MessageDirection? get direction =>
      raw.direction != null
          ? MessageDirection.values[raw.direction!.index]
          : null;

  /// The sender's user information embedded in the message.
  UserInfo? get userInfo =>
      raw.userInfo != null ? UserInfo.fromRaw(raw.userInfo!) : null;

  /// The @mention information associated with this message.
  MentionedInfo? get mentionedInfo =>
      raw.mentionedInfo != null
          ? MentionedInfo.fromRaw(raw.mentionedInfo!)
          : null;

  /// The server-side extra information attached to this message.
  String? get extra => raw.extra;

  /// Sets the server-side extra information.
  set extra(String? v) => raw.extra = v;

  /// The local-only extra information stored on the device.
  String? get localExtra => raw.localExtra;

  /// Sets the local-only extra information.
  set localExtra(String? v) => raw.localExtra = v;

  /// The key-value metadata (expansion) associated with this message.
  Map? get metadata => raw.expansion;

  /// Sets the key-value metadata (expansion) for this message.
  set metadata(Map? v) => raw.expansion = v;

  /// Whether this message can include metadata (expansion).
  bool? get canIncludeMetadata => raw.canIncludeExpansion;

  /// Sets whether this message can include metadata (expansion).
  set canIncludeMetadata(bool? v) => raw.canIncludeExpansion = v;

  /// The list of user IDs that this directed message targets.
  /// Only the specified users will receive this message.
  List<String>? get directedUserIds => raw.directedUserIds;

  /// Sets the list of directed user IDs for this message.
  set directedUserIds(List<String>? v) => raw.directedUserIds = v;

  /// Whether this message requires a read receipt.
  bool? get needReceipt => raw.needReceipt;

  /// Sets whether this message requires a read receipt.
  set needReceipt(bool? v) => raw.needReceipt = v;

  /// Whether a read receipt has been sent for this message.
  bool? get sentReceipt => raw.sentReceipt;

  /// Updates the metadata (expansion) key-value pairs for this message on the server.
  ///
  /// [metadata] is the map of key-value pairs to set or update.
  /// [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> setMetadata(Map<String, String> metadata, ErrorHandler handler) {
    if (channelType == ChannelType.community) {
      return NCEngine.engine.updateUltraGroupMessageExpansion(
        messageId!,
        metadata,
        callback: IRCIMIWUpdateUltraGroupMessageExpansionCallback(
          onUltraGroupMessageExpansionUpdated:
              (code) => handler(Converter.toNCError(code)),
        ),
      );
    }
    return NCEngine.engine.updateMessageExpansion(
      messageId!,
      metadata,
      callback: IRCIMIWUpdateMessageExpansionCallback(
        onMessageExpansionUpdated: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes specific metadata keys from this message on the server.
  ///
  /// [keys] is the list of metadata keys to remove.
  /// [handler] is called with an [NCError].
  /// On success, `error.code` is `0`.
  Future<int> deleteMetadata(List<String> keys, ErrorHandler handler) {
    if (channelType == ChannelType.community) {
      return NCEngine.engine.removeUltraGroupMessageExpansionForKeys(
        messageId!,
        keys,
        callback: IRCIMIWRemoveUltraGroupMessageExpansionForKeysCallback(
          onUltraGroupMessageExpansionForKeysRemoved:
              (code) => handler(Converter.toNCError(code)),
        ),
      );
    }
    return NCEngine.engine.removeMessageExpansionForKeys(
      messageId!,
      keys,
      callback: IRCIMIWRemoveMessageExpansionForKeysCallback(
        onMessageExpansionForKeysRemoved:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }
}
