import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../channel/base_channel.dart' show ChannelIdentifier;
import '../internal/converter.dart';
import 'message_read_receipt_user.dart';

/// Represents a read receipt response for a specific message.
class MessageReadReceiptResponse {
  final RCIMIWReadReceiptResponseV5 _raw;
  MessageReadReceiptResponse._(this._raw);

  /// Creates a [MessageReadReceiptResponse] from an existing SDK object.
  static MessageReadReceiptResponse fromRaw(RCIMIWReadReceiptResponseV5 raw) =>
      MessageReadReceiptResponse._(raw);

  /// The channel identifier where the message was sent.
  ChannelIdentifier? get channelIdentifier {
    final type = _raw.conversationType;
    final targetId = _raw.targetId;
    if (type == null ||
        (type != RCIMIWConversationType.private &&
            type != RCIMIWConversationType.group) ||
        targetId == null ||
        targetId.isEmpty) {
      return null;
    }
    return ChannelIdentifier(
      channelType: Converter.fromRCConversationType(type),
      channelId: targetId,
      subChannelId: _raw.channelId?.isEmpty == true ? null : _raw.channelId,
    );
  }

  /// The unique message identifier.
  String? get messageId => _raw.messageUId;

  /// The number of users who have read the message.
  int? get readCount => _raw.readCount;

  /// The number of users who have not read the message.
  int? get unreadCount => _raw.unreadCount;

  /// The total number of users in the channel.
  int? get totalCount => _raw.totalCount;

  /// The list of users with their read receipt details.
  List<MessageReadReceiptUser>? get users =>
      _raw.users?.map(MessageReadReceiptUser.fromRaw).toList();

  /// The associated SDK object for advanced usage.
  RCIMIWReadReceiptResponseV5 get raw => _raw;
}
