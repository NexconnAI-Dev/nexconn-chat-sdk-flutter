part of 'nc_engine.dart';

/// Parameters for sending a friend request.
class AddFriendParams {
  /// The target user's ID.
  final String userId;

  /// Extra message attached to the friend request.
  final String extra;

  /// Creates parameters for adding a friend.
  AddFriendParams({required this.userId, this.extra = ''});
}

/// Parameters for updating a friend's remark and extended profile data.
///
/// Only `userId`, `remark`, and `extProfile` can be updated here.
class SetFriendInfoParams {
  /// The target user's ID.
  final String userId;

  /// Optional remark to associate with this friend.
  final String? remark;

  /// Optional extended profile key-value pairs.
  final Map<String, String>? extProfile;

  /// Creates params with the given [userId], optional [remark] and [extProfile].
  SetFriendInfoParams({required this.userId, this.remark, this.extProfile});
}

/// Module for user-related operations including profile management,
/// friend management, blocklist, and event subscription.
///
/// Access this module via [NCEngine.user].
class UserModule {
  UserModule._();

  RCIMIWEngine get _engine => NCEngine.engine;

  /// Creates a paginated query for friend applications.
  FriendApplicationsQuery createFriendApplicationsQuery(
    FriendApplicationsQueryParams params,
  ) {
    return FriendApplicationsQuery(params);
  }

  /// Creates a paginated query for subscribe status.
  SubscribeQuery createSubscribeQuery(SubscribeQueryParams params) {
    return SubscribeQuery(params);
  }

  /// Subscribes to presence events for the specified users.
  ///
  /// The [handler] receives a list of failed user IDs on partial failure,
  /// or an [NCError] on complete failure.
  Future<int> subscribeEvent(
    SubscribeEventParams params,
    OperationHandler<List<String>?> handler,
  ) {
    return _engine.subscribeEvent(
      params.raw,
      callback: IRCIMIWSubscribeEventCallback(
        onSuccess: () => handler(null, null),
        onError:
            (code, failedUserIds) =>
                handler(failedUserIds, Converter.toNCError(code)),
      ),
    );
  }

  /// Unsubscribes from presence events for the specified users.
  Future<int> unsubscribeEvent(
    UnsubscribeEventParams params,
    OperationHandler<List<String>?> handler,
  ) {
    return _engine.unSubscribeEvent(
      params.raw,
      callback: IRCIMIWSubscribeEventCallback(
        onSuccess: () => handler(null, null),
        onError:
            (code, failedUserIds) =>
                handler(failedUserIds, Converter.toNCError(code)),
      ),
    );
  }

  /// Queries the subscription status for the specified event parameters.
  ///
  /// Returns a list of [SubscribeStatusInfo] on success.
  Future<int> getSubscribeEvent(
    GetSubscribeEventParams params,
    OperationHandler<List<SubscribeStatusInfo>> handler,
  ) {
    return _engine.querySubscribeEvent(
      params.raw,
      callback: IRCIMIWQuerySubscribeEventCallback(
        onSuccess: (events) {
          final wrapped =
              events?.map((e) => SubscribeStatusInfo.fromRaw(e)).toList();
          handler(wrapped, null);
        },
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Adds a user to the blocklist.
  ///
  /// Blocked users cannot send messages to the current user.
  Future<int> addToBlocklist(String userId, ErrorHandler handler) {
    return _engine.addToBlacklist(
      userId,
      callback: IRCIMIWAddToBlacklistCallback(
        onBlacklistAdded: (code, uid) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes a user from the blocklist.
  Future<int> removeFromBlocklist(String userId, ErrorHandler handler) {
    return _engine.removeFromBlacklist(
      userId,
      callback: IRCIMIWRemoveFromBlacklistCallback(
        onBlacklistRemoved: (code, uid) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the full blocklist of user IDs.
  Future<int> getBlocklist(OperationHandler<List<String>> handler) {
    return _engine.getBlacklist(
      callback: IRCIMIWGetBlacklistCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Checks whether a user is in the blocklist.
  ///
  /// The [handler] receives `true` if the user is blocked, `false` otherwise.
  Future<int> checkBlocked(String userId, OperationHandler<bool> handler) {
    return _engine.getBlacklistStatus(
      userId,
      callback: IRCIMIWGetBlacklistStatusCallback(
        onSuccess: (t) => handler(t == RCIMIWBlacklistStatus.inBlacklist, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Updates the current user's profile.
  Future<int> updateMyUserProfile(UserProfile profile, ErrorHandler handler) {
    return _engine.updateMyUserProfile(
      profile.raw,
      callback: IRCIMIWUpdateMyUserProfileCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code, errorKeys) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the current user's profile.
  Future<int> getMyUserProfile(OperationHandler<UserProfile> handler) {
    return _engine.getMyUserProfile(
      callback: IRCIMIWGetMyUserProfileCallback(
        onSuccess:
            (profile) => handler(
              profile != null ? UserProfile.fromRaw(profile) : null,
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves user profiles for the given [userIds].
  Future<int> getUserProfiles(
    List<String> userIds,
    OperationHandler<List<UserProfile>> handler,
  ) {
    return _engine.getUserProfiles(
      userIds,
      callback: IRCIMIWGetUserProfilesCallback(
        onSuccess:
            (profiles) =>
                handler(profiles?.map(UserProfile.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Updates the visibility setting of the current user's profile.
  Future<int> updateMyUserProfileVisibility(
    UserProfileVisibility visibility,
    ErrorHandler handler,
  ) {
    return _engine.updateMyUserProfileVisibility(
      RCIMIWUserProfileVisibility.values[visibility.index],
      callback: IRCIMIWUpdateMyUserProfileVisibilityCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the current user's profile visibility setting.
  Future<int> getMyUserProfileVisibility(OperationHandler<int> handler) {
    return _engine.getMyUserProfileVisibility(
      callback: IRCIMIWGetMyUserProfileVisibilityCallback(
        onSuccess: (visibility) => handler(visibility, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Sends a friend request to the specified user.
  ///
  /// The [handler] receives a process code on success (indicating whether
  /// the request was sent or auto-accepted).
  Future<int> addFriend(AddFriendParams params, OperationHandler<int> handler) {
    return _engine.addFriend(
      params.userId,
      RCIMIWFriendType.both,
      params.extra,
      callback: IRCIMIWAddFriendCallback(
        onSuccess: (processCode) => handler(processCode, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Removes friends by the given user IDs.
  Future<int> removeFriends(List<String> userIds, ErrorHandler handler) {
    return _engine.deleteFriends(
      userIds,
      RCIMIWFriendType.both,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Accepts a pending friend application from the specified user.
  Future<int> acceptFriendApplication(String userId, ErrorHandler handler) {
    return _engine.acceptFriendApplication(
      userId,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Refuses a pending friend application from the specified user.
  Future<int> refuseFriendApplication(String userId, ErrorHandler handler) {
    return _engine.refuseFriendApplication(
      userId,
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Updates a friend's remark and extended profile.
  ///
  /// Only [SetFriendInfoParams.userId], [SetFriendInfoParams.remark], and
  /// [SetFriendInfoParams.extProfile] are applied.
  Future<int> setFriendInfo(SetFriendInfoParams params, ErrorHandler handler) {
    final raw = RCIMIWFriendInfo.create(
      userId: params.userId,
      remark: params.remark,
      extFields: params.extProfile,
    );
    return _engine.setFriendInfo(
      raw,
      callback: IRCIMIWSetFriendInfoCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code, errorKeys) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Checks the friend relationship status for the given user IDs.
  ///
  /// Returns a list of [FriendRelationInfo] describing each relationship.
  Future<int> checkFriends(
    List<String> userIds,
    OperationHandler<List<FriendRelationInfo>> handler,
  ) {
    return _engine.checkFriendsRelation(
      userIds,
      RCIMIWFriendType.both,
      callback: IRCIMIWCheckFriendsRelationCallback(
        onSuccess:
            (t) => handler(t?.map(FriendRelationInfo.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the friend list.
  Future<int> getFriends(OperationHandler<List<FriendInfo>> handler) {
    return _engine.getFriends(
      RCIMIWFriendType.both,
      callback: IRCIMIWGetFriendsCallback(
        onSuccess: (t) => handler(t?.map(FriendInfo.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves detailed friend info for the given [userIds].
  Future<int> getFriendsInfo(
    List<String> userIds,
    OperationHandler<List<FriendInfo>> handler,
  ) {
    return _engine.getFriendsInfo(
      userIds,
      callback: IRCIMIWGetFriendsInfoCallback(
        onSuccess: (t) => handler(t?.map(FriendInfo.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Searches friends by [name] (matches display name, remark, etc.).
  Future<int> searchFriendsInfo(
    String name,
    OperationHandler<List<FriendInfo>> handler,
  ) {
    return _engine.searchFriendsInfo(
      name,
      callback: IRCIMIWSearchFriendsInfoCallback(
        onSuccess: (t) => handler(t?.map(FriendInfo.fromRaw).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the permission policy for receiving friend requests.
  Future<int> setFriendAddPermission(
    FriendAddPermission permission,
    ErrorHandler handler,
  ) {
    if (permission == FriendAddPermission.notSet) {
      final error = Converter.toNCError(-101);
      handler(error);
      return Future.value(-101);
    }
    return _engine.setFriendAllowType(
      RCIMIWFriendAllowType.values[permission.index],
      callback: IRCIMIWOperationCallback(
        onSuccess: () => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the current friend request permission policy.
  Future<int> getFriendAddPermission(
    OperationHandler<FriendAddPermission> handler,
  ) {
    return _engine.getFriendAllowType(
      callback: IRCIMIWGetFriendAllowTypeCallback(
        onSuccess:
            (t) => handler(
              t != null ? FriendAddPermission.values[t.index] : null,
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }
}

void _notifySubscriptionChanged(List<RCIMIWSubscribeInfoEvent>? events) {
  final wrapped = events?.map((e) => SubscribeStatusInfo.fromRaw(e)).toList();
  NCEngine._userHandlers.notify(
    (h) => h.onSubscriptionChanged?.call(
      SubscriptionChangedEvent(events: wrapped),
    ),
  );
}

void _notifySubscriptionSyncCompleted(RCIMIWSubscribeType? type) {
  final wrapped = type != null ? SubscribeType.values[type.index] : null;
  NCEngine._userHandlers.notify(
    (h) => h.onSubscriptionSyncCompleted?.call(
      SubscriptionSyncCompletedEvent(type: wrapped),
    ),
  );
}

void _notifySubscriptionChangedOnOtherDevices(
  List<RCIMIWSubscribeEvent>? events,
) {
  final wrapped = events?.map((e) => SubscribeChangeEvent.fromRaw(e)).toList();
  NCEngine._userHandlers.notify(
    (h) => h.onSubscriptionChangedOnOtherDevices?.call(
      SubscriptionChangedOnOtherDevicesEvent(events: wrapped),
    ),
  );
}

void _notifyFriendRemove(List<String>? userIds, int? operationTime) {
  NCEngine._userHandlers.notify(
    (h) => h.onFriendRemove?.call(
      FriendRemoveEvent(userIds: userIds, operationTime: operationTime),
    ),
  );
}

void _notifyFriendAdd(
  String? userId,
  String? name,
  String? avatarUrl,
  int? operationTime,
) {
  NCEngine._userHandlers.notify(
    (h) => h.onFriendAdd?.call(
      FriendAddEvent(
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        operationTime: operationTime,
      ),
    ),
  );
}

void _notifyFriendCleared(int? operationTime) {
  NCEngine._userHandlers.notify(
    (h) => h.onFriendCleared?.call(
      FriendClearedEvent(operationTime: operationTime),
    ),
  );
}

void _notifyFriendApplicationStatusChanged(
  String? userId,
  RCIMIWFriendApplicationType? applicationType,
  RCIMIWFriendApplicationStatus? status,
  int? operationTime,
  String? extra,
) {
  final wrappedApplicationType =
      applicationType != null
          ? FriendApplicationType.values[applicationType.index]
          : null;
  final wrappedStatus =
      status != null ? FriendApplicationStatus.values[status.index] : null;
  NCEngine._userHandlers.notify(
    (h) => h.onFriendApplicationStatusChanged?.call(
      FriendApplicationStatusChangedEvent(
        userId: userId,
        applicationType: wrappedApplicationType,
        applicationStatus: wrappedStatus,
        operationTime: operationTime,
        extra: extra,
      ),
    ),
  );
}

void _notifyFriendInfoChangedSync(
  String? userId,
  String? remark,
  Map? extProfile,
  int? operationTime,
) {
  NCEngine._userHandlers.notify(
    (h) => h.onFriendInfoChangedSync?.call(
      FriendInfoChangedSyncEvent(
        userId: userId,
        remark: remark,
        extProfile: extProfile,
        operationTime: operationTime,
      ),
    ),
  );
}
