import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Represents information about an individual message within a combined (forwarded) message.
///
/// Used when constructing or displaying combined messages that aggregate multiple messages into a single forwarded unit.
class CombineMessageInfo {
  /// The user ID of the message sender.
  final String? fromUserId;

  /// The channel ID where the original message was sent.
  final String? channelId;

  /// The timestamp of the original message (in milliseconds).
  final int? timestamp;

  /// The message type identifier (e.g., "NC:TxtMsg", "NC:ImgMsg").
  final String? objectName;

  /// The message content as a key-value map.
  final Map? content;

  /// Creates a [CombineMessageInfo] with optional message details.
  CombineMessageInfo({
    this.fromUserId,
    this.channelId,
    this.timestamp,
    this.objectName,
    this.content,
  });

  /// Creates a [CombineMessageInfo] from an existing SDK object.
  static CombineMessageInfo fromRaw(RCIMIWCombineMsgInfo raw) {
    return CombineMessageInfo(
      fromUserId: raw.fromUserId,
      channelId: raw.targetId,
      timestamp: raw.timestamp,
      objectName: raw.objectName,
      content: raw.content,
    );
  }

  /// Converts this object to the SDK data object.
  RCIMIWCombineMsgInfo toRaw() {
    return RCIMIWCombineMsgInfo.create(
      fromUserId: fromUserId,
      targetId: channelId,
      timestamp: timestamp,
      objectName: objectName,
      content: content,
    );
  }
}
