import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class OpenChannelPage extends StatefulWidget {
  const OpenChannelPage({super.key});

  @override
  State<OpenChannelPage> createState() => _OpenChannelPageState();
}

class _OpenChannelPageState extends State<OpenChannelPage> {
  static const _mentionTypeLabel = 'MentionType(0:none,1:all,2:user)';
  static const _mentionUserIdLabel = 'MentionUserId';

  @override
  void initState() {
    super.initState();
  }

  ({MentionedInfoParams? value, bool isValid}) _mentionedInfoFromArgs(
    Map<String, String> args, {
    required String action,
  }) {
    final type = (args[_mentionTypeLabel] ?? '0').trim();
    switch (type) {
      case '':
      case '0':
        return (value: null, isValid: true);
      case '1':
        return (
          value: const MentionedInfoParams(type: MentionedType.all),
          isValid: true,
        );
      case '2':
        final userId = (args[_mentionUserIdLabel] ?? '').trim();
        if (userId.isEmpty) {
          showResult('$action [onError]', {'error': 'MentionUserId 不能为空'});
          return (value: null, isValid: false);
        }
        return (
          value: MentionedInfoParams(
            type: MentionedType.part,
            userIdList: [userId],
          ),
          isValid: true,
        );
      default:
        showResult('$action [onError]', {'error': 'MentionType 仅支持 0/1/2'});
        return (value: null, isValid: false);
    }
  }

  Future<String?> _pickChannelId() async {
    final args = await showParamsDialog(
      context,
      title: '输入聊天室ID',
      params: [(label: 'ChannelId', hint: 'chatRoomId', isNumber: false)],
    );
    return args?['ChannelId'];
  }

  void _enterChannel() async {
    final args = await showParamsDialog(
      context,
      title: '加入聊天室',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'MessageCount', hint: '20', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channelId = args['ChannelId'] ?? '';
    final messageCount = int.tryParse(args['MessageCount'] ?? '20') ?? 20;
    final channel = OpenChannel(channelId);
    showInput('onChatRoomJoined', {
      'channelId': channelId,
      'messageCount': messageCount,
    });
    await channel.enterChannel(
      EnterOpenChannelParams(messageCount: messageCount),
      (error) => showResult('onChatRoomJoined', error?.toJson()),
    );
  }

  void _exitChannel() async {
    final channelId = await _pickChannelId();
    if (channelId == null || !mounted) return;
    final channel = OpenChannel(channelId);
    showInput('onChatRoomLeft', {'channelId': channelId});
    await channel.exitChannel(
      (error) => showResult('onChatRoomLeft', error?.toJson()),
    );
  }

  void _setMetadata() async {
    final args = await showParamsDialog(
      context,
      title: '设置聊天室KV',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'Key', hint: 'key', isNumber: false),
        (label: 'Value', hint: 'value', isNumber: false),
        (label: 'DeleteWhenLeft(0/1)', hint: '0', isNumber: true),
        (label: 'Overwrite(0/1)', hint: '1', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channel = OpenChannel(args['ChannelId'] ?? '');
    showInput('onChatRoomEntriesAdded', {
      'channelId': args['ChannelId'] ?? '',
      'entries': {args['Key'] ?? '': args['Value'] ?? ''},
      'deleteWhenLeft': args['DeleteWhenLeft(0/1)'] == '1',
      'overwrite': args['Overwrite(0/1)'] != '0',
    });
    await channel.setMetadata(
      OpenChannelSetMetadataParams(
        metadata: {args['Key'] ?? '': args['Value'] ?? ''},
        deleteWhenLeft: args['DeleteWhenLeft(0/1)'] == '1',
        overwrite: args['Overwrite(0/1)'] != '0',
      ),
      (error) => showResult('onChatRoomEntriesAdded', error?.toJson()),
    );
  }

  void _getMetadata() async {
    final args = await showParamsDialog(
      context,
      title: '获取聊天室KV',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'Key', hint: '(optional, empty=all)', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final key = (args['Key'] ?? '').isNotEmpty ? args['Key'] : null;
    final channel = OpenChannel(args['ChannelId'] ?? '');
    showInput('getMetadata', {
      'channelId': args['ChannelId'] ?? '',
      'key': key,
    });
    await channel.getMetadata(
      key: key,
      handler: (data, error) {
        if (error?.code == 34004) {
          showResult('getMetadata', {'data': <String, String>{}});
          return;
        }
        showResult(
          'getMetadata',
          hasError(error) ? error?.toJson() : {'data': data},
        );
      },
    );
  }

  void _deleteMetadata() async {
    final args = await showParamsDialog(
      context,
      title: '删除聊天室KV',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'Keys(comma)', hint: 'key1,key2', isNumber: false),
        (label: 'Force(0/1)', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final keys = (args['Keys(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = OpenChannel(args['ChannelId'] ?? '');
    showInput('onChatRoomEntriesRemoved', {
      'channelId': args['ChannelId'] ?? '',
      'keys': keys,
      'force': args['Force(0/1)'] == '1',
    });
    await channel.deleteMetadata(
      OpenChannelDeleteMetadataParams(
        keys: keys,
        isForce: args['Force(0/1)'] == '1',
      ),
      (error) => showResult('onChatRoomEntriesRemoved', error?.toJson()),
    );
  }

  void _sendTextMessage() async {
    final args = await showParamsDialog(
      context,
      title: '发送聊天室文本消息',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'Text', hint: 'hello chatroom', isNumber: false),
        (label: _mentionTypeLabel, hint: '0', isNumber: true),
        (
          label: _mentionUserIdLabel,
          hint: 'userId when type=2',
          isNumber: false,
        ),
      ],
    );
    if (args == null || !mounted) return;
    final mention = _mentionedInfoFromArgs(args, action: 'sendTextMessage');
    if (!mention.isValid) return;
    final channelId = args['ChannelId'] ?? '';
    final channel = OpenChannel(channelId);
    showInput('onMessageSent', {
      'channelId': channelId,
      'text': args['Text'] ?? '',
      'mentionedInfo': mention.value?.toJson(),
    });
    await channel.sendMessage(
      SendMessageParams(
        messageParams: TextMessageParams(
          text: args['Text'] ?? '',
          mentionedInfo: mention.value,
        ),
      ),
      callback: SendMessageCallback(
        onMessageSent: (code, m) {
          showResult('onMessageSent', {'code': code});
        },
      ),
    );
  }

  void _openChannelMessagesQuery() async {
    final args = await showParamsDialog(
      context,
      title: '聊天室历史消息查询',
      params: [
        (label: 'ChannelId', hint: 'chatRoomId', isNumber: false),
        (label: 'Count', hint: '20', isNumber: true),
        (label: 'IsAscending(0=false,1=true)', hint: '0', isNumber: true),
        (label: 'StartTime', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channel = OpenChannel(args['ChannelId'] ?? '');
    final isAscending =
        (int.tryParse(args['IsAscending(0=false,1=true)'] ?? '0') ?? 0) == 1;
    final startTime = int.tryParse(args['StartTime'] ?? '0') ?? 0;
    showInput('openChannelMessagesQuery', {
      'channelId': args['ChannelId'] ?? '',
      'count': int.tryParse(args['Count'] ?? '20') ?? 20,
      'isAscending': isAscending,
      'startTime': startTime,
    });
    final query =
        channel.createOpenChannelMessagesQuery(OpenChannelMessagesQueryParams(
      channelId: args['ChannelId'] ?? '',
      pageSize: int.tryParse(args['Count'] ?? '20') ?? 20,
      isAscending: isAscending,
      startTime: startTime,
    ));
    await query.loadNextPage((page, error) {
      showResult(
          'openChannelMessagesQuery',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': page?.data.length,
                  'messages': page?.data.map((m) => m.toJson()).toList(),
                });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('聊天室相关')),
      body: ListView(
        children: [
          ApiSection(
            title: '聊天室操作',
            children: [
              ApiButton(label: '加入聊天室', onPressed: _enterChannel),
              ApiButton(label: '离开聊天室', onPressed: _exitChannel),
            ],
          ),
          ApiSection(
            title: 'KV 属性(Metadata)',
            children: [
              ApiButton(label: '设置KV', onPressed: _setMetadata),
              ApiButton(label: '获取KV', onPressed: _getMetadata),
              ApiButton(label: '删除KV', onPressed: _deleteMetadata),
            ],
          ),
          ApiSection(
            title: '消息',
            children: [
              ApiButton(label: '发送文本消息', onPressed: _sendTextMessage),
              ApiButton(label: '历史消息查询', onPressed: _openChannelMessagesQuery),
            ],
          ),
        ],
      ),
    );
  }
}
