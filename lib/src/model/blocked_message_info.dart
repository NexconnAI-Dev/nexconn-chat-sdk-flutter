import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../channel/base_channel.dart' show ChannelIdentifier;
import '../enum/message_block_type.dart';
import '../internal/converter.dart';

/// Contains information about a message that was blocked or filtered by the server's content moderation.
class BlockedMessageInfo {
  final RCIMIWBlockedMessageInfo _raw;
  BlockedMessageInfo._(this._raw);

  /// Creates a [BlockedMessageInfo] from an existing SDK object.
  static BlockedMessageInfo fromRaw(RCIMIWBlockedMessageInfo raw) =>
      BlockedMessageInfo._(raw);

  /// The channel identifier where the message was blocked.
  ChannelIdentifier? get channelIdentifier {
    final type = _raw.conversationType;
    if (type == null) return null;
    return ChannelIdentifier(
      channelType: Converter.fromRCConversationType(type),
      channelId: _raw.targetId ?? '',
    );
  }

  /// The unique identifier of the blocked message.
  String? get messageId => _raw.blockedMsgUId;

  /// The type of block applied to the message (e.g., sensitive word, global).
  MessageBlockType? get blockType =>
      _raw.blockType != null
          ? MessageBlockType.values[_raw.blockType!.index]
          : null;

  /// Additional information about the block reason.
  String? get extra => _raw.extra;

  /// The associated SDK object for advanced usage.
  RCIMIWBlockedMessageInfo get raw => _raw;
}
