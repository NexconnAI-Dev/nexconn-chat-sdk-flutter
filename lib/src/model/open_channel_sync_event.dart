import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/open_channel_sync_status.dart';
import '../enum/open_channel_sync_status_reason.dart';

/// Represents a multi-device login synchronization event for an open channel.
class OpenChannelSyncEvent {
  final RCIMIWChatRoomSyncEvent _raw;
  OpenChannelSyncEvent._(this._raw);

  /// Creates a [OpenChannelSyncEvent] from an existing SDK object.
  static OpenChannelSyncEvent fromRaw(RCIMIWChatRoomSyncEvent raw) =>
      OpenChannelSyncEvent._(raw);

  /// The open channel ID associated with the sync event.
  String? get channelId => _raw.chatroomId;

  /// The synchronization status (e.g., joined, left).
  OpenChannelSyncStatus? get status =>
      _raw.status != null
          ? OpenChannelSyncStatus.values[_raw.status!.index]
          : null;

  /// The reason for the sync status change.
  OpenChannelSyncStatusReason? get reason =>
      _raw.reason != null
          ? OpenChannelSyncStatusReason.values[_raw.reason!.index]
          : null;

  /// The timestamp of the sync event (in milliseconds).
  int? get time => _raw.time;

  /// Additional custom data associated with the sync event.
  String? get extra => _raw.extra;

  /// The associated SDK object for advanced usage.
  RCIMIWChatRoomSyncEvent get raw => _raw;
}
