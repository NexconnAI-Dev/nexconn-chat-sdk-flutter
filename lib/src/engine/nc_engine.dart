/// Core engine definitions for the Nexconn Flutter SDK.
///
/// This file contains [NCEngine] and the core types related to initialization,
/// connection, quiet hours, push, user features, and translation.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../enum/channel_type.dart';
import '../enum/connection_status.dart';
import '../enum/friend_add_permission.dart';
import '../enum/friend_application_status.dart';
import '../enum/friend_application_type.dart';
import '../enum/group_operation_type.dart';
import '../enum/group_operation.dart';
import '../enum/log_level.dart';
import '../enum/custom_message_persistent_flag.dart';
import '../enum/metadata_operation_type.dart';
import '../enum/open_channel_status.dart';
import '../enum/no_disturb_level.dart';
import '../enum/no_disturb_time_level.dart';
import '../enum/subscribe_type.dart';
import '../enum/translate_mode.dart';
import '../enum/translate_strategy.dart';
import '../channel/base_channel.dart' show ChannelIdentifier;
import '../enum/user_profile_visibility.dart';
import '../error/nc_error.dart';
import '../handler/channel_handler.dart';
import '../handler/connection_handler.dart';
import '../handler/group_channel_handler.dart';
import '../handler/message_handler.dart';
import '../handler/open_channel_handler.dart';
import '../handler/translate_handler.dart';
import '../handler/user_handler.dart';
import '../internal/converter.dart';
import '../internal/handler_registry.dart';
import '../internal/types.dart';
import '../message/stream_message.dart';
import '../model/blocked_message_info.dart';
import '../model/app_settings.dart';
import '../model/engine_options.dart';
import '../model/friend_info.dart';
import '../model/friend_relation_info.dart';
import '../model/group_application_info.dart';
import '../model/group_info.dart';
import '../model/group_member_info.dart';
import '../model/open_channel_sync_event.dart';
import '../model/participant_action.dart';
import '../model/participant_ban_event.dart';
import '../model/participant_block_event.dart';
import '../model/read_receipt_response_v5.dart';
import '../model/speech_to_text_info.dart';
import '../model/subscribe_change_event.dart';
import '../model/subscribe_event_request.dart';
import '../model/subscribe_status_info.dart';
import '../model/translate_item.dart';
import '../model/translate_params.dart';
import '../model/typing_status.dart';
import '../model/user_profile.dart';
import '../query/friend_query.dart';
import '../enum/area_code.dart';

part 'nc_engine_channel.dart';
part 'nc_engine_message.dart';
part 'nc_engine_open_channel.dart';
part 'nc_engine_group.dart';
part 'nc_engine_user.dart';
part 'nc_engine_translate.dart';

/// Parameters used to initialize the engine.
class InitParams {
  /// The unique application key assigned by the Nexconn platform.
  final String appKey;

  /// Custom navigation server URL. Uses default if not specified.
  final String? naviServer;

  /// Custom file server URL for media uploads/downloads.
  final String? fileServer;

  /// Custom statistics server URL.
  final String? statisticServer;

  /// Custom log server URL for remote logging.
  final String? logServer;

  /// Geographic area code for data routing compliance.
  final AreaCode? areaCode;

  /// Whether to kick a previously connected device when reconnecting.
  final bool? reconnectKickEnable;

  /// Media compression options for image/video messages.
  final CompressOptions? compressOptions;

  /// SDK log verbosity level.
  final LogLevel? logLevel;

  /// Push notification configuration options.
  final PushOptions? pushOptions;

  /// Whether to enable push notifications.
  final bool? enablePush;

  /// Creates initialization parameters.
  ///
  /// [appKey] is required and must match the key from the Nexconn console.
  InitParams({
    required this.appKey,
    this.naviServer,
    this.fileServer,
    this.statisticServer,
    this.logServer,
    this.areaCode,
    this.reconnectKickEnable,
    this.compressOptions,
    this.logLevel,
    this.pushOptions,
    this.enablePush,
  });
}

/// Parameters used to establish a connection.
class ConnectParams {
  /// The authentication token obtained from the server.
  final String token;

  /// Connection timeout in seconds. Defaults to 0 (keep retrying).
  final int timeout;

  /// Creates connection parameters.
  ///
  /// [token] is the user authentication token issued by the app server.
  ConnectParams({required this.token, this.timeout = 0});
}

/// Parameters used to configure quiet hours.
class NoDisturbTimeParams {
  /// Start time of the quiet period in "HH:MM:SS" format.
  final String startTime;

  /// Duration of the quiet period in minutes.
  final int spanMinutes;

  /// The notification suppression level during quiet hours.
  final NoDisturbTimeLevel level;

  /// Time zone identifier (e.g. "Asia/Shanghai"). Uses device default if null.
  final String? timezone;

  /// Creates Do Not Disturb time parameters.
  NoDisturbTimeParams({
    required this.startTime,
    required this.spanMinutes,
    required this.level,
    this.timezone,
  });
}

/// The current quiet-hours configuration.
class NoDisturbTimeInfo {
  /// Start time of the quiet period in "HH:MM:SS" format.
  final String? startTime;

  /// Duration of the quiet period in minutes.
  final int? spanMinutes;

  /// The notification suppression level during quiet hours.
  final NoDisturbTimeLevel? level;

  /// Time zone identifier (e.g. "Asia/Shanghai"), if reported by the server.
  final String? timezone;

  /// Creates a [NoDisturbTimeInfo].
  NoDisturbTimeInfo({
    this.startTime,
    this.spanMinutes,
    this.level,
    this.timezone,
  });

  /// Converts this quiet-hours configuration to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'spanMinutes': spanMinutes,
    'level': level?.name,
    'timezone': timezone,
  };
}

/// Core singleton engine for the SDK.
///
/// [NCEngine] manages the engine lifecycle, connection state, global event
/// registration, push configuration, and quiet-hours settings.
class NCEngine {
  NCEngine._();

  static RCIMIWEngine? _engine;

  /// Whether the engine has been initialized.
  static bool get isInitialized => _engine != null;

  /// Returns the current engine instance.
  ///
  /// Throws an assertion if [initialize] has not been called yet.
  static RCIMIWEngine get engine {
    assert(_engine != null, 'NCEngine.initialize() must be called first');
    return _engine!;
  }

  /// User module for profile, friends, blocklist, and subscription operations.
  static final user = UserModule._();

  /// Translation module for message and text translation features.
  static final translate = TranslateModule._();

  static final _connectionStatusHandlers =
      HandlerRegistry<OnConnectionStatusChanged>();
  static final _translateHandlers = HandlerRegistry<TranslateHandler>();
  static final _channelHandlers = HandlerRegistry<ChannelHandler>();
  static final _messageHandlers = HandlerRegistry<MessageHandler>();
  static final _openChannelHandlers = HandlerRegistry<OpenChannelHandler>();
  static final _groupChannelHandlers = HandlerRegistry<GroupChannelHandler>();
  static final _userHandlers = HandlerRegistry<UserHandler>();

  /// Registers a connection status change handler with the given [identifier].
  static void addConnectionStatusHandler(
    String identifier,
    OnConnectionStatusChanged handler,
  ) => _connectionStatusHandlers.add(identifier, handler);

  /// Removes the connection status handler associated with [identifier].
  static void removeConnectionStatusHandler(String identifier) =>
      _connectionStatusHandlers.remove(identifier);

  /// Registers a channel event handler with the given [identifier].
  static void addChannelHandler(String identifier, ChannelHandler handler) =>
      _channelHandlers.add(identifier, handler);

  /// Removes the channel handler associated with [identifier].
  static void removeChannelHandler(String identifier) =>
      _channelHandlers.remove(identifier);

  /// Registers a message event handler with the given [identifier].
  static void addMessageHandler(String identifier, MessageHandler handler) =>
      _messageHandlers.add(identifier, handler);

  /// Removes the message handler associated with [identifier].
  static void removeMessageHandler(String identifier) =>
      _messageHandlers.remove(identifier);

  /// Registers an open channel event handler with the given [identifier].
  static void addOpenChannelHandler(
    String identifier,
    OpenChannelHandler handler,
  ) => _openChannelHandlers.add(identifier, handler);

  /// Removes the open channel handler associated with [identifier].
  static void removeOpenChannelHandler(String identifier) =>
      _openChannelHandlers.remove(identifier);

  /// Registers a group-channel event handler with the given [identifier].
  static void addGroupChannelHandler(
    String identifier,
    GroupChannelHandler handler,
  ) => _groupChannelHandlers.add(identifier, handler);

  /// Removes the group-channel handler associated with [identifier].
  static void removeGroupChannelHandler(String identifier) =>
      _groupChannelHandlers.remove(identifier);

  /// Registers a user event handler with the given [identifier].
  static void addUserHandler(String identifier, UserHandler handler) =>
      _userHandlers.add(identifier, handler);

  /// Removes the user handler associated with [identifier].
  static void removeUserHandler(String identifier) =>
      _userHandlers.remove(identifier);

  /// Registers a translation event handler with the given [identifier].
  static void addTranslateHandler(
    String identifier,
    TranslateHandler handler,
  ) => _translateHandlers.add(identifier, handler);

  /// Removes the translation handler associated with [identifier].
  static void removeTranslateHandler(String identifier) =>
      _translateHandlers.remove(identifier);

  /// Registers a custom message type.
  ///
  /// This must be called before sending or receiving that custom message type.
  static Future<int> registerCustomMessage(
    String messageIdentifier,
    CustomMessagePersistentFlag persistentFlag,
  ) {
    return engine.registerNativeCustomMessage(
      messageIdentifier,
      RCIMIWNativeCustomMessagePersistentFlag.values[persistentFlag.index],
    );
  }

  /// Registers a custom media message type.
  ///
  /// This works like [registerCustomMessage], but for file-based message types.
  static Future<int> registerCustomMediaMessage(
    String messageIdentifier,
    CustomMessagePersistentFlag persistentFlag,
  ) {
    return engine.registerNativeCustomMediaMessage(
      messageIdentifier,
      RCIMIWNativeCustomMessagePersistentFlag.values[persistentFlag.index],
    );
  }

  /// Initializes the engine with [params].
  ///
  /// This must be called before any other SDK API. It creates the engine
  /// instance and binds all global event callbacks.
  static Future<void> initialize(InitParams params) async {
    _engine = await RCIMIWEngine.create(
      params.appKey,
      RCIMIWEngineOptions.create(
        naviServer: params.naviServer,
        fileServer: params.fileServer,
        statisticServer: params.statisticServer,
        logServer: params.logServer,
        areaCode:
            params.areaCode != null ? _toRawAreaCode(params.areaCode!) : null,
        kickReconnectDevice: params.reconnectKickEnable,
        compressOptions: params.compressOptions?.toRaw(),
        logLevel:
            params.logLevel != null
                ? RCIMIWLogLevel.values[params.logLevel!.index]
                : null,
        pushOptions: params.pushOptions?.toRaw(),
        enablePush: params.enablePush,
        enableIPC: false,
      ),
    );
    _bindGlobalCallbacks();
  }

  static RCIMIWAreaCode _toRawAreaCode(AreaCode code) {
    switch (code) {
      case AreaCode.bj:
        return RCIMIWAreaCode.bj;
      case AreaCode.sg:
        return RCIMIWAreaCode.sg;
      case AreaCode.na:
        return RCIMIWAreaCode.na;
      case AreaCode.sa:
        return RCIMIWAreaCode.sa;
      case AreaCode.om:
        return RCIMIWAreaCode.om;
    }
  }

  /// Destroys the engine instance and releases all resources.
  ///
  /// After calling this, [initialize] must be called again before using the SDK.
  static Future<void> destroy() async {
    _engine?.destroy();
    _engine = null;
  }

  /// Connects to the Nexconn IM server using the provided [params].
  ///
  /// The [handler] callback receives the connected user ID on success,
  /// or an [NCError] on failure.
  static Future<int> connect(
    ConnectParams params,
    OperationHandler<String> handler,
  ) async {
    if (_engine == null) {
      handler(
        null,
        NCError(
          code: -1,
          message: 'NCEngine.initialize() must be called first',
        ),
      );
      return -1;
    }

    if (Platform.isIOS) {
      await engine.setModuleName('nexconnchatflutter', '26.2.0');
    }

    final code = await _engine!.connect(
      params.token,
      params.timeout,
      callback: RCIMIWConnectCallback(
        onDatabaseOpened: (code) {},
        onConnected: (code, userId) {
          handler(userId, Converter.toNCError(code));
        },
      ),
    );
    if (code != 0) {
      handler(null, Converter.toNCError(code));
    }
    return code;
  }

  /// Disconnects from the Nexconn IM server.
  ///
  /// If [disablePush] is true, push notifications will not be received
  /// while disconnected. Defaults to false (push remains active).
  static Future<int> disconnect({bool disablePush = false}) {
    return engine.disconnect(!disablePush);
  }

  /// Returns the current connection status.
  static Future<ConnectionStatus> getConnectionStatus() async {
    if (_engine == null) {
      return ConnectionStatus.unknown;
    }
    final status = await engine.getConnectionStatus();
    return Converter.fromRCConnectionStatus(status);
  }

  /// Returns the application-level settings from the server.
  ///
  /// Includes feature flags such as speech-to-text availability
  /// and the message modification time window.
  static Future<AppSettings?> getAppSettings() async {
    final raw = await engine.getAppSettings();
    return raw != null ? AppSettings.fromRaw(raw) : null;
  }

  /// Sets the Do Not Disturb quiet hours configuration.
  ///
  /// During quiet hours, notifications are suppressed according to [params].
  static Future<int> setNoDisturbTime(
    NoDisturbTimeParams params,
    ErrorHandler handler,
  ) {
    return engine.setNotificationQuietHoursWithSetting(
      RCIMIWNotificationQuietHoursSetting.create(
        startTime: params.startTime,
        spanMinutes: params.spanMinutes,
        level: RCIMIWPushNotificationQuietHoursLevel.values[params.level.index],
        timeZone: params.timezone,
      ),
      callback: IRCIMIWSetNotificationQuietHoursWithSettingCallback(
        onNotificationQuietHoursWithSettingSet:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes the currently configured Do Not Disturb quiet hours.
  static Future<int> removeNoDisturbTime(ErrorHandler handler) {
    return engine.removeNotificationQuietHours(
      callback: IRCIMIWRemoveNotificationQuietHoursCallback(
        onNotificationQuietHoursRemoved:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the current Do Not Disturb quiet hours settings.
  ///
  /// The [handler] receives a [NoDisturbTimeInfo] on success,
  /// or an [NCError] on failure.
  static Future<int> getNoDisturbTime(
    OperationHandler<NoDisturbTimeInfo> handler,
  ) {
    return engine.getNotificationQuietHours(
      callback: IRCIMIWGetNotificationQuietHoursCallback(
        onSuccess:
            (startTime, spanMinutes, level) => handler(
              NoDisturbTimeInfo(
                startTime: startTime,
                spanMinutes: spanMinutes,
                level:
                    level != null
                        ? NoDisturbTimeLevel.values[level.index]
                        : null,
              ),
              null,
            ),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Changes the SDK log verbosity level at runtime.
  static Future<int> setLogLevel(LogLevel level) {
    return engine.changeLogLevel(RCIMIWLogLevel.values[level.index]);
  }

  /// Returns the time delta (in milliseconds) between the local device clock
  /// and the IM server clock.
  ///
  /// Compute the corrected server time as
  /// `DateTime.now().millisecondsSinceEpoch - getServerTimeDelta()`.
  static Future<int> getServerTimeDelta() {
    return engine.getDeltaTime();
  }

  static void _bindGlobalCallbacks() {
    final e = engine;

    e.onConnectionStatusChanged = (status) {
      _connectionStatusHandlers.notify(
        (h) => h(
          ConnectionStatusChangedEvent(
            status: Converter.fromRCConnectionStatus(status),
          ),
        ),
      );
    };

    e.onMessageReceived = (message, left, offline, hasPackage) {
      _notifyMessageReceived(message, left, offline, hasPackage);
    };

    e.onRemoteMessageRecalled = (message) {
      _notifyMessageDeleted(message != null ? [message] : null);
    };

    e.onRemoteMessageExpansionUpdated = (metadata, message) {
      _notifyMessageMetadataUpdated(metadata, message);
    };

    e.onRemoteMessageExpansionForKeyRemoved = (message, keys) {
      _notifyMessageMetadataDeleted(message, keys);
    };

    e.onMessageReadReceiptV5Received = (responses) {
      _notifyMessageReceiptResponse(responses);
    };

    e.onOfflineMessageSyncCompleted = () {
      _notifyOfflineMessageSyncCompleted();
    };

    e.onMessageBlocked = (info) {
      _notifyMessageBlocked(info);
    };

    e.onStreamMessageRequestInit = (messageId) {
      _notifyStreamMessageRequestInit(messageId);
    };

    e.onStreamMessageRequestData = (message, chunkInfo) {
      _notifyStreamMessageRequestDelta(message, chunkInfo);
    };

    e.onStreamMessageRequestComplete = (messageId, code) {
      _notifyStreamMessageRequestComplete(messageId, code);
    };

    e.onConversationTopStatusSynced = (type, channelId, subChannelId, top) {
      if (type != null) {
        _notifyChannelPinnedSync(
          Converter.fromRCConversationType(type),
          channelId,
          subChannelId,
          top,
        );
      }
    };

    e.onConversationNotificationLevelSynced = (
      type,
      channelId,
      subChannelId,
      level,
    ) {
      if (type != null) {
        _notifyChannelNotificationLevelSync(
          Converter.fromRCConversationType(type),
          channelId,
          subChannelId,
          level,
        );
      }
    };

    e.onTypingStatusChanged = (
      type,
      channelId,
      subChannelId,
      userTypingStatus,
    ) {
      if (type != null) {
        _notifyTypingStatusChanged(
          Converter.fromRCConversationType(type),
          channelId,
          subChannelId,
          userTypingStatus,
        );
      }
    };

    e.onRemoteConversationListSynced = (code) {
      _notifyRemoteChannelsSyncCompleted(code);
    };

    e.onChatRoomJoining = (channelId) {
      _notifyOpenChannelEntering(channelId);
    };

    e.onChatRoomMemberChanged = (channelId, actions) {
      _notifyOpenChannelParticipantChanged(channelId, actions);
    };

    e.onChatRoomStatusChanged = (channelId, status) {
      _notifyOpenChannelStatusChanged(channelId, status);
    };

    e.onChatRoomEntriesChanged = (operationType, roomId, entries) {
      _notifyOpenChannelMetadataUpdated(operationType, roomId, entries);
    };

    e.onChatRoomNotifyBan = (event) {
      _notifyOpenChannelParticipantMuted(event);
    };

    e.onChatRoomNotifyBlock = (event) {
      _notifyOpenChannelParticipantBanned(event);
    };

    e.onChatRoomNotifyMultiLoginSync = (event) {
      _notifyOpenChannelMultiLoginSync(event);
    };

    e.onGroupOperation = (
      groupId,
      operatorInfo,
      groupInfo,
      operation,
      memberInfos,
      operationTime,
    ) {
      _notifyGroupOperation(
        groupId,
        operatorInfo,
        groupInfo,
        operation,
        memberInfos,
        operationTime,
      );
    };

    e.onGroupInfoChanged = (
      operatorInfo,
      fullGroupInfo,
      changedGroupInfo,
      operationTime,
    ) {
      _notifyGroupInfoChanged(
        operatorInfo,
        fullGroupInfo,
        changedGroupInfo,
        operationTime,
      );
    };

    e.onGroupMemberInfoChanged = (
      groupId,
      operatorInfo,
      memberInfo,
      operationTime,
    ) {
      _notifyGroupMemberInfoChanged(
        groupId,
        operatorInfo,
        memberInfo,
        operationTime,
      );
    };

    e.onGroupApplicationEvent = (info) {
      _notifyGroupApplicationEvent(info);
    };

    e.onGroupRemarkChangedSync =
        (groupId, operationType, groupRemark, operationTime) {};

    e.onGroupFollowsChangedSync = (
      groupId,
      operationType,
      userIds,
      operationTime,
    ) {
      _notifyGroupFavoritesChangedSync(
        groupId,
        operationType,
        userIds,
        operationTime,
      );
    };

    e.onEventChange = (subscribeEvents) {
      _notifySubscriptionChanged(subscribeEvents);
    };

    e.onSubscriptionSyncCompleted = (type) {
      _notifySubscriptionSyncCompleted(type);
    };

    e.onSubscriptionChangedOnOtherDevices = (subscribeEvents) {
      _notifySubscriptionChangedOnOtherDevices(subscribeEvents);
    };

    e.onFriendDeleted = (_, userIds, operationTime) {
      _notifyFriendRemove(userIds, operationTime);
    };

    e.onFriendAdded = (_, userId, name, avatarUrl, operationTime) {
      _notifyFriendAdd(userId, name, avatarUrl, operationTime);
    };

    e.onFriendsClearedFromServer = (operationTime) {
      _notifyFriendCleared(operationTime);
    };

    e.onFriendApplicationStatusChanged = (
      userId,
      applicationType,
      status,
      _,
      operationTime,
      extra,
    ) {
      _notifyFriendApplicationStatusChanged(
        userId,
        applicationType,
        status,
        operationTime,
        extra,
      );
    };

    e.onFriendInfoChangedSync = (userId, remark, extProfile, operationTime) {
      _notifyFriendInfoChangedSync(userId, remark, extProfile, operationTime);
    };

    e.onTranslationDidFinished = (items) {
      _notifyTranslationCompleted(items);
    };

    e.onTranslationLanguageDidChange = (language) {
      _notifyTranslationLanguageChanged(language);
    };

    e.onAutoTranslateStateDidChange = (isEnable) {
      _notifyAutoTranslateStateChanged(isEnable);
    };

    e.onConversationTranslationStrategySynced = (
      type,
      targetId,
      channelId,
      strategy,
    ) {
      _notifyChannelTranslateStrategySync(type, targetId, channelId, strategy);
    };

    e.onSpeechToTextCompleted = (info, messageId, code) {
      _notifySpeechToTextCompleted(info, messageId, code);
    };

    e.onUltraGroupReadTimeReceived = (channelId, subChannelId, timestamp) {};
    e.onUltraGroupTypingStatusChanged = (info) {};

    e.onUltraGroupConversationsSynced = () {
      _notifyCommunityChannelsSyncCompleted();
    };

    e.onRemoteUltraGroupMessageExpansionUpdated = (messages) {
      _notifyCommunityChannelMessageMetadataChanged(messages);
    };
    e.onRemoteUltraGroupMessageModified = (messages) {};
    e.onRemoteUltraGroupMessageRecalled = (messages) {
      _notifyMessageDeleted(messages);
    };

    e.onChatRoomEntriesSynced = (roomId) {
      _notifyOpenChannelMetadataSynced(roomId);
    };
  }
}
