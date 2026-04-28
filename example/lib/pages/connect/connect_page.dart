import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../app_data.dart';
import '../../widgets/api_widgets.dart';

Map<String, dynamic>? _msgJson(Message? msg) => msg?.toJson();

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  String _connectionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    NCEngine.addConnectionStatusHandler('connect_page', (event) {
      if (mounted) {
        setState(() => _connectionStatus = event.status.name);
      }
    });
    if (NCEngine.isInitialized) {
      _refreshConnectionStatus();
    } else {
      _connectionStatus = ConnectionStatus.unknown.name;
    }
  }

  void _refreshConnectionStatus() async {
    try {
      final status = await NCEngine.getConnectionStatus();
      if (mounted) {
        setState(() => _connectionStatus = status.name);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connectionStatus = ConnectionStatus.unknown.name);
      }
      showResult('Get Connection Status', {'error': '$e'});
    }
  }

  @override
  void dispose() {
    NCEngine.removeConnectionStatusHandler('connect_page');
    super.dispose();
  }

  void _initEngine() async {
    final args = await showParamsDialog(
      context,
      title: 'Init Engine',
      params: [
        (
          label: 'AppKey',
          hint: AppData.appKey.isNotEmpty ? AppData.appKey : 'appKey',
          isNumber: false
        ),
        (
          label: 'NaviServer',
          hint:
              AppData.naviServer.isNotEmpty ? AppData.naviServer : '(optional)',
          isNumber: false
        ),
      ],
    );
    if (args == null || !mounted) return;
    final appKey =
        args['AppKey']!.isNotEmpty ? args['AppKey']! : AppData.appKey;
    final naviServer = args['NaviServer']!.isNotEmpty
        ? args['NaviServer']
        : (AppData.naviServer.isNotEmpty ? AppData.naviServer : null);
    try {
      showInput('Init Engine', {'appKey': appKey, 'naviServer': naviServer});
      await NCEngine.initialize(
          InitParams(appKey: appKey, naviServer: naviServer));
      showResult('Init Engine',
          {'appKey': appKey, 'naviServer': naviServer, 'result': 'success'});
    } catch (e) {
      showResult('Init Engine', {'error': '$e'});
    }
  }

  void _destroy() async {
    showInput('Destroy Engine', const {});
    await NCEngine.destroy();
    showResult('Destroy Engine', {'result': 'success'});
  }

  void _connect() async {
    final args = await showParamsDialog(
      context,
      title: 'Connect',
      params: [
        (label: 'Token (1/2/3 or full token)', hint: '1', isNumber: false),
        (label: 'Timeout', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final rawToken = args['Token (1/2/3 or full token)'] ?? '';
    final token = rawToken.isNotEmpty
        ? AppData.tokenByShortcut(rawToken)
        : AppData.token1;
    final timeout = int.tryParse(args['Timeout'] ?? '0') ?? 0;
    showInput('Connect', {
      'tokenInput': rawToken,
      'token': token,
      'timeout': timeout,
    });
    try {
      await NCEngine.connect(
        ConnectParams(token: token, timeout: timeout),
        (userId, error) {
          showResult('Connect', {
            ...?error?.toJson(),
            'userId': userId,
          });
        },
      );
    } catch (e) {
      if (mounted) {
        showResult('Connect', {'error': '$e'});
      }
    }
  }

  void _disconnect() async {
    final args = await showParamsDialog(
      context,
      title: 'Disconnect',
      params: [
        (label: 'DisablePush(0/1)', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final disablePush = args['DisablePush(0/1)'] == '1';
    showInput('Disconnect', {'disablePush': disablePush});
    await NCEngine.disconnect(disablePush: disablePush);
    showResult('Disconnect', {'disablePush': disablePush, 'result': 'success'});
  }

  void _getConnectionStatus() async {
    showInput('Get Connection Status', const {});
    try {
      final status = await NCEngine.getConnectionStatus();
      if (mounted) {
        setState(() => _connectionStatus = status.name);
      }
      showResult('Get Connection Status', {'status': status.name});
    } catch (e) {
      if (mounted) {
        setState(() => _connectionStatus = ConnectionStatus.unknown.name);
      }
      showResult('Get Connection Status', {'error': '$e'});
    }
  }

  void _setNoDisturbTime() async {
    final args = await showParamsDialog(
      context,
      title: 'Set No-Disturb Time',
      params: [
        (label: 'StartTime', hint: '22:00:00 (HH:MM:SS)', isNumber: false),
        (label: 'SpanMinutes', hint: '480', isNumber: true),
        (label: 'Level(0-3)', hint: '2', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final startTime = args['StartTime'] ?? '22:00:00';
    final hmsRegex = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$');
    if (!hmsRegex.hasMatch(startTime)) {
      showResult('Set No-Disturb Time', {
        'error': 'StartTime must be in HH:MM:SS format (e.g. 22:00:00)',
        'input': startTime,
      });
      return;
    }
    showInput('Set No-Disturb Time', {
      'startTime': startTime,
      'spanMinutes': int.tryParse(args['SpanMinutes'] ?? '480') ?? 480,
      'level': NoDisturbTimeLevel
          .values[int.tryParse(args['Level(0-3)'] ?? '2') ?? 2].name,
    });
    await NCEngine.setNoDisturbTime(
      NoDisturbTimeParams(
        startTime: startTime,
        spanMinutes: int.tryParse(args['SpanMinutes'] ?? '480') ?? 480,
        level: NoDisturbTimeLevel
            .values[int.tryParse(args['Level(0-3)'] ?? '2') ?? 2],
      ),
      (error) => showResult('Set No-Disturb Time', error?.toJson()),
    );
  }

  void _removeNoDisturbTime() async {
    showInput('Remove No-Disturb Time', const {});
    await NCEngine.removeNoDisturbTime(
      (error) => showResult('Remove No-Disturb Time', error?.toJson()),
    );
  }

  void _getNoDisturbTime() async {
    showInput('Get No-Disturb Time', const {});
    await NCEngine.getNoDisturbTime((info, error) {
      showResult('Get No-Disturb Time', {
        ...?error?.toJson(),
        ...?info?.toJson(),
      });
    });
  }

  void _setListeners() {
    showInput('Set Listeners', const {});
    NCEngine.addMessageHandler(
      'global_msg',
      MessageHandler(
        onMessageReceived: (event) {
          showResult('onMessageReceived', {
            'left': event.left,
            'offline': event.offline,
            'hasPackage': event.hasPackage,
            'message': _msgJson(event.message),
          });
        },
        onMessageDeleted: (event) {
          showResult('onMessageDeleted', {
            'count': event.messages?.length ?? 0,
            'messages': event.messages?.map((e) => _msgJson(e)).toList() ?? [],
          });
        },
        onCommunityChannelMessageMetadataChanged: (event) {
          showResult('onCommunityChannelMessageMetadataChanged', {
            'count': event.messages.length,
            'messages': event.messages.map((e) => _msgJson(e)).toList(),
          });
        },
      ),
    );
    NCEngine.addChannelHandler(
      'global_ch',
      ChannelHandler(
        onChannelPinnedSync: (event) {
          showResult('onChannelPinnedSync', {
            'channelType': event.channelIdentifier.channelType.name,
            'channelId': event.channelIdentifier.channelId,
            'isPinned': event.isPinned,
          });
        },
        onChannelNoDisturbLevelSync: (event) {
          showResult('onChannelNoDisturbLevelSync', {
            'channelType': event.channelIdentifier.channelType.name,
            'channelId': event.channelIdentifier.channelId,
            'level': event.level.name,
          });
        },
        onRemoteChannelsSyncCompleted: (event) {
          showResult('onRemoteChannelsSyncCompleted', {
            'error': event.error?.toJson(),
          });
        },
      ),
    );
    NCEngine.addOpenChannelHandler(
      'global_open',
      OpenChannelHandler(
        onStatusChanged: (event) {
          showResult('onStatusChanged',
              {'channelId': event.channelId, 'status': event.status?.name});
        },
        onMetadataChanged: (event) {
          showResult('onMetadataChanged', {
            'changeInfo': event.changeInfo
                .map((info) => {
                      'channelId': info.channelId,
                      'key': info.key,
                      'value': info.value,
                      'operation': info.operationType?.name,
                    })
                .toList(),
          });
        },
      ),
    );
    NCEngine.addGroupChannelHandler(
      'global_group',
      GroupChannelHandler(
        onGroupOperation: (event) {
          showResult('onGroupOperation', {
            'groupId': event.groupId,
            'operation': event.operation?.name,
            'operatorId': event.operatorInfo?.userId,
            'groupName': event.groupInfo?.groupName,
            'memberIds': event.memberInfos?.map((e) => e.userId).toList(),
          });
        },
        onGroupInfoChanged: (event) {
          showResult('onGroupInfoChanged', {
            'operatorId': event.operatorInfo?.userId,
            'groupId':
                event.fullGroupInfo?.groupId ?? event.changedGroupInfo?.groupId,
            'groupName': event.fullGroupInfo?.groupName,
            'changedGroupName': event.changedGroupInfo?.groupName,
          });
        },
        onGroupMemberInfoChanged: (event) {
          showResult('onGroupMemberInfoChanged', {
            'groupId': event.groupId,
            'operatorId': event.operatorInfo?.userId,
            'memberId': event.memberInfo?.userId,
            'nickname': event.memberInfo?.nickname,
          });
        },
        onGroupApplicationEvent: (event) {
          showResult('onGroupApplicationEvent', {
            'groupId': event.info?.groupId,
            'status': event.info?.status?.name
          });
        },
        onGroupFavoritesChangedSync: (event) {
          showResult('onGroupFavoritesChangedSync', {
            'groupId': event.groupId,
            'operation': event.operationType?.name,
            'userIds': event.userIds
          });
        },
      ),
    );
    NCEngine.addUserHandler(
      'global_user',
      UserHandler(
        onSubscriptionChanged: (event) {
          showResult('onSubscriptionChanged', {
            'count': event.events?.length ?? 0,
            'events': event.events?.map((e) => e.toJson()).toList() ?? [],
          });
        },
        onSubscriptionSyncCompleted: (event) {
          showResult('onSubscriptionSyncCompleted', {
            'type': event.type?.name,
          });
        },
        onSubscriptionChangedOnOtherDevices: (event) {
          showResult('onSubscriptionChangedOnOtherDevices', {
            'count': event.events?.length ?? 0,
            'events': event.events?.map((e) => e.toJson()).toList() ?? [],
          });
        },
        onFriendAdd: (event) {
          showResult('onFriendAdd', {
            'userId': event.userId,
            'name': event.name,
          });
        },
        onFriendRemove: (event) {
          showResult('onFriendRemove', {'userIds': event.userIds});
        },
        onFriendApplicationStatusChanged: (event) {
          showResult('onFriendApplicationStatusChanged', {
            'userId': event.userId,
            'type': event.applicationType?.name,
            'status': event.applicationStatus?.name
          });
        },
      ),
    );
    NCEngine.addTranslateHandler(
      'global_translate',
      TranslateHandler(
        onTranslationCompleted: (event) {
          showResult(
            'onTranslationCompleted',
            {
              'count': event.results?.length,
              'results': event.results?.map((e) => e.toJson()).toList(),
            },
          );
        },
        onTranslationLanguageChanged: (event) {
          showResult(
              'onTranslationLanguageChanged', {'language': event.language});
        },
        onAutoTranslateStateChanged: (event) {
          showResult(
              'onAutoTranslateStateChanged', {'isEnabled': event.isEnabled});
        },
      ),
    );
    showResult('Set Listeners', {'result': 'all listeners registered'});
  }

  void _removeListeners() {
    showInput('Remove Listeners', const {});
    NCEngine.removeMessageHandler('global_msg');
    NCEngine.removeChannelHandler('global_ch');
    NCEngine.removeOpenChannelHandler('global_open');
    NCEngine.removeGroupChannelHandler('global_group');
    NCEngine.removeUserHandler('global_user');
    NCEngine.removeTranslateHandler('global_translate');
    showResult('Remove Listeners', {'result': 'all listeners removed'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              'Connection Status: $_connectionStatus',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ApiSection(
                  title: 'Engine',
                  children: [
                    ApiButton(label: 'Init Engine', onPressed: _initEngine),
                    ApiButton(label: 'Destroy Engine', onPressed: _destroy),
                  ],
                ),
                ApiSection(
                  title: 'Connection Management',
                  children: [
                    ApiButton(label: 'Connect', onPressed: _connect),
                    ApiButton(label: 'Disconnect', onPressed: _disconnect),
                    ApiButton(label: 'Get Connection Status', onPressed: _getConnectionStatus),
                  ],
                ),
                ApiSection(
                  title: 'Event Listeners',
                  children: [
                    ApiButton(label: 'Set Listeners', onPressed: _setListeners),
                    ApiButton(label: 'Remove Listeners', onPressed: _removeListeners),
                  ],
                ),
                ApiSection(
                  title: 'Push & No-Disturb',
                  children: [
                    ApiButton(label: 'Set No-Disturb Time', onPressed: _setNoDisturbTime),
                    ApiButton(
                        label: 'Remove No-Disturb Time', onPressed: _removeNoDisturbTime),
                    ApiButton(label: 'Get No-Disturb Time', onPressed: _getNoDisturbTime),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
