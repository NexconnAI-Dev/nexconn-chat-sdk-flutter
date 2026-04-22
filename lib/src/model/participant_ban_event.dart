import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/participant_ban_type.dart';

/// Represents mute information for participants in an open channel.
class OpenChannelParticipantMutedInfo {
  final RCIMIWChatRoomMemberBanEvent _raw;
  OpenChannelParticipantMutedInfo._(this._raw);

  /// Creates a [OpenChannelParticipantMutedInfo] from an existing SDK object.
  static OpenChannelParticipantMutedInfo fromRaw(
    RCIMIWChatRoomMemberBanEvent raw,
  ) => OpenChannelParticipantMutedInfo._(raw);

  /// The open channel ID where the event occurred.
  String? get channelId => _raw.chatroomId;

  /// The type of mute action.
  OpenChannelParticipantMuteType? get muteType =>
      _raw.banType != null
          ? OpenChannelParticipantMuteType.values[_raw.banType!.index]
          : null;

  /// The duration of the mute in milliseconds.
  int? get durationTime => _raw.durationTime;

  /// The timestamp when the mute operation was performed (in milliseconds).
  int? get operateTime => _raw.operateTime;

  /// The list of user IDs affected by the mute.
  List<String>? get userIdList => _raw.userIdList;

  /// Additional custom data associated with the mute event.
  String? get extra => _raw.extra;

  /// The associated SDK object for advanced usage.
  RCIMIWChatRoomMemberBanEvent get raw => _raw;
}
