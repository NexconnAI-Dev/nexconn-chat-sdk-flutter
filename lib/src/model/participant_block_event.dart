import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/participant_operate_type.dart';

/// Represents ban information for participants in an open channel.
class OpenChannelParticipantBannedInfo {
  final RCIMIWChatRoomMemberBlockEvent _raw;
  OpenChannelParticipantBannedInfo._(this._raw);

  /// Creates a [OpenChannelParticipantBannedInfo] from an existing SDK object.
  static OpenChannelParticipantBannedInfo fromRaw(
    RCIMIWChatRoomMemberBlockEvent raw,
  ) => OpenChannelParticipantBannedInfo._(raw);

  /// The open channel ID where the event occurred.
  String? get channelId => _raw.chatroomId;

  /// The type of ban operation (e.g., block, unblock).
  OpenChannelParticipantBanType? get banType =>
      _raw.operateType != null
          ? OpenChannelParticipantBanType.values[_raw.operateType!.index]
          : null;

  /// The duration of the ban in milliseconds.
  int? get durationTime => _raw.durationTime;

  /// The timestamp when the ban operation was performed (in milliseconds).
  int? get operateTime => _raw.operateTime;

  /// The list of user IDs affected by the ban.
  List<String>? get userIdList => _raw.userIdList;

  /// Additional custom data associated with the ban event.
  String? get extra => _raw.extra;

  /// The associated SDK object for advanced usage.
  RCIMIWChatRoomMemberBlockEvent get raw => _raw;
}
