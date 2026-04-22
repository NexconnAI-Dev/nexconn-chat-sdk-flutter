import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../enum/channel_type.dart';
import '../internal/converter.dart';

/// Uniquely identifies a message within the Nexconn IM system.
///
/// Combines channel type, channel ID, and message ID to form a complete reference to a specific message.
class MessageIdentifier {
  /// The type of channel the message belongs to (e.g., private, group).
  final ChannelType channelType;

  /// The channel ID containing the message.
  final String channelId;

  /// The optional sub-channel ID (used for community channels).
  final String? subChannelId;

  /// The unique message identifier.
  final String messageId;

  /// Creates a [MessageIdentifier] with the required identifiers.
  MessageIdentifier({
    required this.channelType,
    required this.channelId,
    this.subChannelId,
    required this.messageId,
  });

  /// Converts this object to the SDK data object.
  RCIMIWMessageIdentifier toRaw() {
    return RCIMIWMessageIdentifier.create(
      conversationType: Converter.toRCConversationType(channelType),
      targetId: channelId,
      channelId: subChannelId,
      messageUId: messageId,
    );
  }
}
