import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/open_channel_member_action_info.dart';

/// Represents an action performed by a participant in an open channel.
class OpenChannelParticipantActionInfo {
  final RCIMIWChatRoomMemberAction _raw;
  OpenChannelParticipantActionInfo._(this._raw);

  /// Creates a [OpenChannelParticipantActionInfo] from an existing SDK object.
  static OpenChannelParticipantActionInfo fromRaw(
    RCIMIWChatRoomMemberAction raw,
  ) => OpenChannelParticipantActionInfo._(raw);

  /// The user ID of the participant who performed the action.
  String? get userId => _raw.userId;

  /// The type of action performed (e.g., join, leave).
  OpenChannelParticipantActionType? get actionType =>
      _raw.actionType != null
          ? OpenChannelParticipantActionType.values[_raw.actionType!.index]
          : null;

  /// The associated SDK object for advanced usage.
  RCIMIWChatRoomMemberAction get raw => _raw;
}
