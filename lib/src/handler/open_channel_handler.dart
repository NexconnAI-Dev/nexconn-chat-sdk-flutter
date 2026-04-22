import '../enum/metadata_operation_type.dart';
import '../enum/open_channel_status.dart';
import '../model/open_channel_sync_event.dart';
import '../model/participant_action.dart';
import '../model/participant_ban_event.dart';
import '../model/participant_block_event.dart';

/// Event fired when the current user enters an open channel.
class OpenChannelEnteringEvent {
  /// The ID of the open channel being entered.
  final String? channelId;

  /// Creates an [OpenChannelEnteringEvent].
  const OpenChannelEnteringEvent({this.channelId});
}

/// Event fired when the participant list of an open channel changes.
class OpenChannelParticipantChangedEvent {
  /// The ID of the open channel.
  final String? channelId;

  /// The participant actions that caused this change.
  final List<OpenChannelParticipantActionInfo>? actions;

  /// The current participant count after the change.
  final int? participantCount;

  /// Creates an [OpenChannelParticipantChangedEvent].
  const OpenChannelParticipantChangedEvent({
    this.channelId,
    this.actions,
    this.participantCount,
  });
}

/// Event fired when the status of an open channel changes.
class OpenChannelStatusChangedEvent {
  /// The ID of the open channel.
  final String? channelId;

  /// The new channel status.
  final OpenChannelStatus? status;

  /// Creates an [OpenChannelStatusChangedEvent].
  const OpenChannelStatusChangedEvent({this.channelId, this.status});
}

/// Details for a single open channel metadata change.
class OpenChannelMetadataChangeInfo {
  /// The ID of the open channel.
  final String? channelId;

  /// The key that changed.
  final String? key;

  /// The new value for the key.
  ///
  /// This may be empty for delete operations.
  final String? value;

  /// The metadata operation type.
  final OpenChannelMetadataOperationType? operationType;

  /// Creates an [OpenChannelMetadataChangeInfo].
  const OpenChannelMetadataChangeInfo({
    this.channelId,
    this.key,
    this.value,
    this.operationType,
  });
}

/// Event fired when open channel metadata changes.
class OpenChannelMetadataChangedEvent {
  /// The list of metadata change details.
  ///
  /// When one update contains multiple key-value pairs, each pair is exposed
  /// as its own [OpenChannelMetadataChangeInfo].
  final List<OpenChannelMetadataChangeInfo> changeInfo;

  /// Creates an [OpenChannelMetadataChangedEvent].
  const OpenChannelMetadataChangedEvent({this.changeInfo = const []});
}

/// Event fired when open channel metadata synchronization completes.
class OpenChannelMetadataSyncedEvent {
  /// The ID of the open channel whose metadata finished syncing.
  final String? channelId;

  /// Creates an [OpenChannelMetadataSyncedEvent].
  const OpenChannelMetadataSyncedEvent({this.channelId});
}

/// Event fired when mute status changes in an open channel.
class OpenChannelParticipantMutedEvent {
  /// The mute change details.
  final OpenChannelParticipantMutedInfo? info;

  /// Creates an [OpenChannelParticipantMutedEvent].
  const OpenChannelParticipantMutedEvent({this.info});
}

/// Event fired when ban status changes in an open channel.
class OpenChannelParticipantBannedEvent {
  /// The ban change details.
  final OpenChannelParticipantBannedInfo? info;

  /// Creates an [OpenChannelParticipantBannedEvent].
  const OpenChannelParticipantBannedEvent({this.info});
}

/// Event fired when an open channel action is synchronized from another device.
class OpenChannelMultiLoginSyncEvent {
  /// The synchronized event details from another device.
  final OpenChannelSyncEvent? event;

  /// Creates an [OpenChannelMultiLoginSyncEvent].
  const OpenChannelMultiLoginSyncEvent({this.event});
}

/// Callback invoked when the current user enters an open channel.
typedef OnOpenChannelEntering = void Function(OpenChannelEnteringEvent event);

/// Callback invoked when the participant list of an open channel changes.
typedef OnOpenChannelParticipantChanged =
    void Function(OpenChannelParticipantChangedEvent event);

/// Callback invoked when the status of an open channel changes.
typedef OnOpenChannelStatusChanged =
    void Function(OpenChannelStatusChangedEvent event);

/// Callback invoked when open channel metadata changes.
typedef OnOpenChannelMetadataChanged =
    void Function(OpenChannelMetadataChangedEvent event);

/// Callback invoked when open channel metadata synchronization completes.
typedef OnOpenChannelMetadataSynced =
    void Function(OpenChannelMetadataSyncedEvent event);

/// Callback invoked when mute status changes in an open channel.
typedef OnOpenChannelParticipantMuted =
    void Function(OpenChannelParticipantMutedEvent event);

/// Callback invoked when ban status changes in an open channel.
typedef OnOpenChannelParticipantBanned =
    void Function(OpenChannelParticipantBannedEvent event);

/// Callback invoked when an open channel action is synchronized from another device.
typedef OnOpenChannelNotifyMultiLoginSync =
    void Function(OpenChannelMultiLoginSyncEvent event);

/// Handler for global open channel events.
class OpenChannelHandler {
  /// Called when the current user enters an open channel.
  final OnOpenChannelEntering? onEntering;

  /// Called when the participant list of an open channel changes.
  final OnOpenChannelParticipantChanged? onParticipantChanged;

  /// Called when the status of an open channel changes.
  final OnOpenChannelStatusChanged? onStatusChanged;

  /// Called when open channel metadata changes.
  final OnOpenChannelMetadataChanged? onMetadataChanged;

  /// Called when open channel metadata synchronization completes.
  final OnOpenChannelMetadataSynced? onMetadataSynced;

  /// Called when mute status changes in an open channel.
  final OnOpenChannelParticipantMuted? onParticipantMuted;

  /// Called when ban status changes in an open channel.
  final OnOpenChannelParticipantBanned? onParticipantBanned;

  /// Called when an open channel action is synchronized from another device.
  final OnOpenChannelNotifyMultiLoginSync? onNotifyMultiLoginSync;

  /// Creates an [OpenChannelHandler].
  OpenChannelHandler({
    this.onEntering,
    this.onParticipantChanged,
    this.onStatusChanged,
    this.onMetadataChanged,
    this.onMetadataSynced,
    this.onParticipantMuted,
    this.onParticipantBanned,
    this.onNotifyMultiLoginSync,
  });
}
