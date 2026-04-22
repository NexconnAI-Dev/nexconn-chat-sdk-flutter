import '../channel/base_channel.dart' show ChannelIdentifier;
import '../enum/no_disturb_level.dart';
import '../enum/translate_strategy.dart';
import '../error/nc_error.dart';
import '../model/typing_status.dart';

/// Event fired when a channel's translation strategy is synced from the server.
class ChannelTranslateStrategySyncEvent {
  /// The channel whose translation strategy was synced.
  final ChannelIdentifier channelIdentifier;

  /// The synced translation strategy.
  final TranslateStrategy? strategy;

  /// Creates a [ChannelTranslateStrategySyncEvent].
  const ChannelTranslateStrategySyncEvent({
    required this.channelIdentifier,
    this.strategy,
  });
}

/// Event fired when a channel's pinned state is synced from the server.
class ChannelPinnedSyncEvent {
  /// The channel whose pinned state was synced.
  final ChannelIdentifier channelIdentifier;

  /// Whether the channel is pinned.
  final bool isPinned;

  /// Creates a [ChannelPinnedSyncEvent].
  const ChannelPinnedSyncEvent({
    required this.channelIdentifier,
    required this.isPinned,
  });
}

/// Event fired when a channel's do-not-disturb level is synced from the server.
class ChannelNoDisturbLevelSyncEvent {
  /// The channel whose do-not-disturb level was synced.
  final ChannelIdentifier channelIdentifier;

  /// The synced do-not-disturb level.
  final ChannelNoDisturbLevel level;

  /// Creates a [ChannelNoDisturbLevelSyncEvent].
  const ChannelNoDisturbLevelSyncEvent({
    required this.channelIdentifier,
    required this.level,
  });
}

/// Event fired when user typing status changes in a channel.
class TypingStatusChangedEvent {
  /// The channel where typing status changed.
  final ChannelIdentifier channelIdentifier;

  /// The list of users' typing status information.
  final List<ChannelUserTypingStatusInfo>? userTypingStatus;

  /// Creates a [TypingStatusChangedEvent].
  const TypingStatusChangedEvent({
    required this.channelIdentifier,
    this.userTypingStatus,
  });
}

/// Event fired when remote channel list synchronization completes.
class RemoteChannelsSyncCompletedEvent {
  /// The error if synchronization failed, or `null` on success.
  final NCError? error;

  /// Creates a [RemoteChannelsSyncCompletedEvent].
  const RemoteChannelsSyncCompletedEvent({this.error});
}

/// Event fired when community channel list synchronization completes.
class CommunityChannelsSyncCompletedEvent {
  /// Creates a [CommunityChannelsSyncCompletedEvent].
  const CommunityChannelsSyncCompletedEvent();
}

/// Callback invoked when a channel's translation strategy is synced.
typedef OnChannelTranslateStrategySync =
    void Function(ChannelTranslateStrategySyncEvent event);

/// Callback invoked when a channel's pinned state is synced.
typedef OnChannelPinnedSync = void Function(ChannelPinnedSyncEvent event);

/// Callback invoked when a channel's do-not-disturb level is synced.
typedef OnChannelNoDisturbLevelSync =
    void Function(ChannelNoDisturbLevelSyncEvent event);

/// Callback invoked when user typing status changes in a channel.
typedef OnTypingStatusChanged = void Function(TypingStatusChangedEvent event);

/// Callback invoked when remote channel list synchronization completes.
typedef OnRemoteChannelsSyncCompleted =
    void Function(RemoteChannelsSyncCompletedEvent event);

/// Callback invoked when community channel list synchronization completes.
typedef OnCommunityChannelsSyncCompleted =
    void Function(CommunityChannelsSyncCompletedEvent event);

/// Handler for channel-level global events.
///
/// Register this handler via [NCEngine.addChannelHandler] to receive
/// notifications about channel property synchronization, typing status
/// changes, and channel list sync completions.
class ChannelHandler {
  /// Called when a channel's pinned state is synced from the server.
  final OnChannelPinnedSync? onChannelPinnedSync;

  /// Called when a channel's do-not-disturb level is synced from the server.
  final OnChannelNoDisturbLevelSync? onChannelNoDisturbLevelSync;

  /// Called when user typing status changes in a channel.
  final OnTypingStatusChanged? onTypingStatusChanged;

  /// Called when remote channel list synchronization completes.
  final OnRemoteChannelsSyncCompleted? onRemoteChannelsSyncCompleted;

  /// Called when a channel's translation strategy is synced from the server.
  final OnChannelTranslateStrategySync? onChannelTranslateStrategySync;

  /// Called when community channel list synchronization completes.
  final OnCommunityChannelsSyncCompleted? onCommunityChannelsSyncCompleted;

  /// Creates a [ChannelHandler].
  ChannelHandler({
    this.onChannelPinnedSync,
    this.onChannelNoDisturbLevelSync,
    this.onTypingStatusChanged,
    this.onRemoteChannelsSyncCompleted,
    this.onChannelTranslateStrategySync,
    this.onCommunityChannelsSyncCompleted,
  });
}
