import '../enum/friend_application_status.dart';
import '../enum/friend_application_type.dart';
import '../enum/subscribe_type.dart';
import '../model/subscribe_change_event.dart';
import '../model/subscribe_status_info.dart';

/// Event fired when user subscription statuses change.
class SubscriptionChangedEvent {
  /// The updated subscription status information.
  final List<SubscribeStatusInfo>? events;

  /// Creates a [SubscriptionChangedEvent].
  const SubscriptionChangedEvent({this.events});
}

/// Event fired when subscription data synchronization completes.
class SubscriptionSyncCompletedEvent {
  /// The subscription type that completed synchronization.
  final SubscribeType? type;

  /// Creates a [SubscriptionSyncCompletedEvent].
  const SubscriptionSyncCompletedEvent({this.type});
}

/// Event fired when subscriptions are changed on another device.
class SubscriptionChangedOnOtherDevicesEvent {
  /// The subscription change events from the other device.
  final List<SubscribeChangeEvent>? events;

  /// Creates a [SubscriptionChangedOnOtherDevicesEvent].
  const SubscriptionChangedOnOtherDevicesEvent({this.events});
}

/// Event fired when a friend is added.
class FriendAddEvent {
  /// The user identifier of the new friend.
  final String? userId;

  /// The display name of the new friend.
  final String? name;

  /// The avatar URL of the new friend.
  final String? avatarUrl;

  /// The timestamp when the friend was added.
  final int? operationTime;

  /// Creates a [FriendAddEvent].
  const FriendAddEvent({
    this.userId,
    this.name,
    this.avatarUrl,
    this.operationTime,
  });
}

/// Event fired when friends are removed.
class FriendRemoveEvent {
  /// The user identifiers of the removed friends.
  final List<String>? userIds;

  /// The timestamp when the friends were removed.
  final int? operationTime;

  /// Creates a [FriendRemoveEvent].
  const FriendRemoveEvent({this.userIds, this.operationTime});
}

/// Event fired when a friend application status changes.
class FriendApplicationStatusChangedEvent {
  /// The user identifier associated with the application.
  final String? userId;

  /// The type of the friend application (sent or received).
  final FriendApplicationType? applicationType;

  /// The current status of the friend application.
  final FriendApplicationStatus? applicationStatus;

  /// The timestamp when the status changed.
  final int? operationTime;

  /// Additional information attached to the application.
  final String? extra;

  /// Creates a [FriendApplicationStatusChangedEvent].
  const FriendApplicationStatusChangedEvent({
    this.userId,
    this.applicationType,
    this.applicationStatus,
    this.operationTime,
    this.extra,
  });
}

/// Event fired when friend information is changed, synced from the server.
class FriendInfoChangedSyncEvent {
  /// The user identifier of the friend whose information changed.
  final String? userId;

  /// The updated remark name for the friend.
  final String? remark;

  /// The updated extended profile data.
  final Map? extProfile;

  /// The timestamp when the change occurred.
  final int? operationTime;

  /// Creates a [FriendInfoChangedSyncEvent].
  const FriendInfoChangedSyncEvent({
    this.userId,
    this.remark,
    this.extProfile,
    this.operationTime,
  });
}

/// Event fired when the friend list is cleared from the server.
class FriendClearedEvent {
  /// The timestamp when the friend list was cleared.
  final int? operationTime;

  /// Creates a [FriendClearedEvent].
  const FriendClearedEvent({this.operationTime});
}

/// Callback invoked when user subscription statuses change.
typedef OnSubscriptionChanged = void Function(SubscriptionChangedEvent event);

/// Callback invoked when subscription data synchronization completes.
typedef OnSubscriptionSyncCompleted =
    void Function(SubscriptionSyncCompletedEvent event);

/// Callback invoked when subscriptions are changed on another device.
typedef OnSubscriptionChangedOnOtherDevices =
    void Function(SubscriptionChangedOnOtherDevicesEvent event);

/// Callback invoked when a friend is added.
typedef OnFriendAdd = void Function(FriendAddEvent event);

/// Callback invoked when friends are removed.
typedef OnFriendRemove = void Function(FriendRemoveEvent event);

/// Callback invoked when a friend application status changes.
typedef OnFriendApplicationStatusChanged =
    void Function(FriendApplicationStatusChangedEvent event);

/// Callback invoked when friend information changes, synced from the server.
typedef OnFriendInfoChangedSync =
    void Function(FriendInfoChangedSyncEvent event);

/// Callback invoked when the friend list is cleared from the server.
typedef OnFriendCleared = void Function(FriendClearedEvent event);

/// Handler for user and friend related global events.
///
/// Register this handler via [NCEngine.addUserHandler] to receive
/// notifications about subscription changes, friend additions, deletions,
/// application status changes, and friend list clearing.
class UserHandler {
  /// Called when user subscription statuses change.
  final OnSubscriptionChanged? onSubscriptionChanged;

  /// Called when subscription data synchronization completes.
  final OnSubscriptionSyncCompleted? onSubscriptionSyncCompleted;

  /// Called when subscriptions are changed on another device.
  final OnSubscriptionChangedOnOtherDevices?
  onSubscriptionChangedOnOtherDevices;

  /// Called when a friend is added.
  final OnFriendAdd? onFriendAdd;

  /// Called when friends are removed.
  final OnFriendRemove? onFriendRemove;

  /// Called when a friend application status changes.
  final OnFriendApplicationStatusChanged? onFriendApplicationStatusChanged;

  /// Called when friend information changes, synced from the server.
  final OnFriendInfoChangedSync? onFriendInfoChangedSync;

  /// Called when the friend list is cleared from the server.
  final OnFriendCleared? onFriendCleared;

  /// Creates a [UserHandler].
  UserHandler({
    this.onSubscriptionChanged,
    this.onSubscriptionSyncCompleted,
    this.onSubscriptionChangedOnOtherDevices,
    this.onFriendAdd,
    this.onFriendRemove,
    this.onFriendApplicationStatusChanged,
    this.onFriendInfoChangedSync,
    this.onFriendCleared,
  });
}
