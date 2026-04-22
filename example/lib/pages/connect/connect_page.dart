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
      showResult('获取连接状态', {'error': '$e'});
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
      title: '初始化引擎',
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
      showInput('初始化引擎', {'appKey': appKey, 'naviServer': naviServer});
      await NCEngine.initialize(
          InitParams(appKey: appKey, naviServer: naviServer));
      showResult('初始化引擎',
          {'appKey': appKey, 'naviServer': naviServer, 'result': 'success'});
    } catch (e) {
      showResult('初始化引擎', {'error': '$e'});
    }
  }

  void _destroy() async {
    showInput('销毁引擎', const {});
    await NCEngine.destroy();
    showResult('销毁引擎', {'result': 'success'});
  }

  void _connect() async {
    final args = await showParamsDialog(
      context,
      title: '连接',
      params: [
        (label: 'Token(1/2/3或完整token)', hint: '1', isNumber: false),
        (label: 'Timeout', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final rawToken = args['Token(1/2/3或完整token)'] ?? '';
    final token = rawToken.isNotEmpty
        ? AppData.tokenByShortcut(rawToken)
        : AppData.token1;
    final timeout = int.tryParse(args['Timeout'] ?? '0') ?? 0;
    showInput('连接', {
      'tokenInput': rawToken,
      'token': token,
      'timeout': timeout,
    });
    try {
      await NCEngine.connect(
        ConnectParams(token: token, timeout: timeout),
        (userId, error) {
          showResult('连接', {
            ...?error?.toJson(),
            'userId': userId,
          });
        },
      );
    } catch (e) {
      if (mounted) {
        showResult('连接', {'error': '$e'});
      }
    }
  }

  void _disconnect() async {
    final args = await showParamsDialog(
      context,
      title: '断开连接',
      params: [
        (label: 'DisablePush(0/1)', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final disablePush = args['DisablePush(0/1)'] == '1';
    showInput('断开连接', {'disablePush': disablePush});
    await NCEngine.disconnect(disablePush: disablePush);
    showResult('断开连接', {'disablePush': disablePush, 'result': 'success'});
  }

  void _getConnectionStatus() async {
    showInput('获取连接状态', const {});
    try {
      final status = await NCEngine.getConnectionStatus();
      if (mounted) {
        setState(() => _connectionStatus = status.name);
      }
      showResult('获取连接状态', {'status': status.name});
    } catch (e) {
      if (mounted) {
        setState(() => _connectionStatus = ConnectionStatus.unknown.name);
      }
      showResult('获取连接状态', {'error': '$e'});
    }
  }

  void _setNoDisturbTime() async {
    final args = await showParamsDialog(
      context,
      title: '设置免打扰时段',
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
      showResult('设置免打扰时段', {
        'error': 'StartTime 必须为 HH:MM:SS 格式（例如 22:00:00）',
        'input': startTime,
      });
      return;
    }
    showInput('设置免打扰时段', {
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
      (error) => showResult('设置免打扰时段', error?.toJson()),
    );
  }

  void _removeNoDisturbTime() async {
    showInput('移除免打扰时段', const {});
    await NCEngine.removeNoDisturbTime(
      (error) => showResult('移除免打扰时段', error?.toJson()),
    );
  }

  void _getNoDisturbTime() async {
    showInput('获取免打扰时段', const {});
    await NCEngine.getNoDisturbTime((info, error) {
      showResult('获取免打扰时段', {
        ...?error?.toJson(),
        ...?info?.toJson(),
      });
    });
  }

  void _setListeners() {
    showInput('设置监听', const {});
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
    showResult('设置监听', {'result': 'all listeners registered'});
  }

  void _removeListeners() {
    showInput('移除监听', const {});
    NCEngine.removeMessageHandler('global_msg');
    NCEngine.removeChannelHandler('global_ch');
    NCEngine.removeOpenChannelHandler('global_open');
    NCEngine.removeGroupChannelHandler('global_group');
    NCEngine.removeUserHandler('global_user');
    NCEngine.removeTranslateHandler('global_translate');
    showResult('移除监听', {'result': 'all listeners removed'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('连接相关')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              '连接状态: $_connectionStatus',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ApiSection(
                  title: '引擎管理',
                  children: [
                    ApiButton(label: '初始化引擎', onPressed: _initEngine),
                    ApiButton(label: '销毁引擎', onPressed: _destroy),
                  ],
                ),
                ApiSection(
                  title: '连接管理',
                  children: [
                    ApiButton(label: '连接', onPressed: _connect),
                    ApiButton(label: '断开连接', onPressed: _disconnect),
                    ApiButton(label: '获取连接状态', onPressed: _getConnectionStatus),
                  ],
                ),
                ApiSection(
                  title: '事件监听',
                  children: [
                    ApiButton(label: '设置监听', onPressed: _setListeners),
                    ApiButton(label: '移除监听', onPressed: _removeListeners),
                  ],
                ),
                ApiSection(
                  title: '推送与免打扰',
                  children: [
                    ApiButton(label: '设置免打扰时段', onPressed: _setNoDisturbTime),
                    ApiButton(
                        label: '移除免打扰时段', onPressed: _removeNoDisturbTime),
                    ApiButton(label: '获取免打扰时段', onPressed: _getNoDisturbTime),
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
