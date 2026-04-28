import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  ChannelNoDisturbLevel? _parseNoDisturbLevel(
    String? rawLevel,
    String action,
  ) {
    final value = int.tryParse(rawLevel ?? '');
    if (value == null || value < 0 || value > 4) {
      showResult('$action [onError]', {'error': 'Level only supports 0-4'});
      return null;
    }
    return ChannelNoDisturbLevel.values[value];
  }

  void _reload() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('reload', channelInput(picked));
    await channel.reload((result, error) {
      if (mounted) {
        showResult(
            'reload', hasError(error) ? error?.toJson() : result?.toJson());
      }
    });
  }

  void _clearUnreadCount() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('clearUnreadCount', channelInput(picked));
    await channel.clearUnreadCount(
      (error) => showResult('clearUnreadCount', error?.toJson()),
    );
  }

  void _getUnreadMentionedMessages() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('getUnreadMentionedMessages', channelInput(picked));
    await channel.getUnreadMentionedMessages((messages, error) {
      if (mounted) {
        final items = messages?.map((e) => e.toJson()).toList() ?? [];
        showResult(
          'getUnreadMentionedMessages',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': items.length,
                  'messages': items,
                },
        );
      }
    });
  }

  void _pin() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Pin',
      params: [(label: 'UpdateOperationTime(0/1)', hint: '1', isNumber: true)],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput(
        'pin',
        mergeInputMaps([
          channelInput(picked),
          {'updateOperationTime': args['UpdateOperationTime(0/1)'] == '1'},
        ]));
    await channel.pin(
      PinParams(updateOperationTime: args['UpdateOperationTime(0/1)'] == '1'),
      (error) => showResult('pin', error?.toJson()),
    );
  }

  void _unpin() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('unpin', channelInput(picked));
    await channel.unpin(
      (error) => showResult('unpin', error?.toJson()),
    );
  }

  void _delete() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('delete channel', channelInput(picked));
    await channel.delete(
      (error) => showResult('delete channel', error?.toJson()),
    );
  }

  void _saveDraft() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Save Draft',
      params: [(label: 'Draft', hint: 'draft text', isNumber: false)],
      trimValues: false,
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput(
        'saveDraft',
        mergeInputMaps([
          channelInput(picked),
          {'draft': args['Draft'] ?? ''},
        ]));
    await channel.saveDraft(
      args['Draft'] ?? '',
      (error) => showResult('saveDraft', error?.toJson()),
    );
  }

  void _clearDraft() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('clearDraft', channelInput(picked));
    await channel.clearDraft(
      (error) => showResult('clearDraft', error?.toJson()),
    );
  }

  void _setNotificationLevel() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Set No-Disturb Level',
      params: [(label: 'Level(0-4)', hint: '2', isNumber: true)],
    );
    if (args == null || !mounted) return;
    final level = _parseNoDisturbLevel(
      args['Level(0-4)'],
      'setNotificationLevel',
    );
    if (level == null) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput(
        'setNotificationLevel',
        mergeInputMaps([
          channelInput(picked),
          {'level': level.name},
        ]));
    await channel.setNoDisturbLevel(
      level,
      (error) => showResult('setNotificationLevel', error?.toJson()),
    );
  }

  void _getChannels() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Get Channel List',
      params: [
        (label: 'ChannelId', hint: '', isNumber: false),
        (label: 'SubChannelId(optional)', hint: '', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channelId = args['ChannelId']?.trim() ?? '';
    final subChannelId = args['SubChannelId(optional)']?.trim();
    final identifiers = types
        .map(
          (t) => ChannelIdentifier(
            channelType: t,
            channelId: channelId,
            subChannelId: subChannelId != null && subChannelId.isNotEmpty
                ? subChannelId
                : null,
          ),
        )
        .toList();
    showInput('getChannels', {
      'identifiers': identifiers
          .map((i) => {
                'channelType': i.channelType.name,
                'channelId': i.channelId,
                'subChannelId': i.subChannelId,
              })
          .toList(),
    });
    await BaseChannel.getChannels(
      identifiers,
      (channels, error) {
        if (mounted) {
          final items = channels?.map((e) => e.toJson()).toList() ?? [];
          showResult(
              'getChannels',
              hasError(error)
                  ? error?.toJson()
                  : {
                      'count': items.length,
                      'channels': items,
                    });
        }
      },
    );
  }

  void _getTotalUnreadCount() async {
    showInput('getTotalUnreadCount', const {});
    await BaseChannel.getTotalUnreadCount((count, error) {
      if (mounted) {
        showResult('getTotalUnreadCount',
            hasError(error) ? error?.toJson() : {'count': count});
      }
    });
  }

  void _getUnreadCountByType() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    showInput('getUnreadCountByType', {
      'channelTypes': types.map((e) => e.name).toList(),
    });
    await BaseChannel.getUnreadChannels(types, (channels, error) {
      if (mounted) {
        final total = channels?.fold<int>(
              0,
              (sum, c) => sum + (c.unreadCount ?? 0),
            ) ??
            0;
        showResult('getUnreadCountByType',
            hasError(error) ? error?.toJson() : {'count': total});
      }
    });
  }

  void _getPinnedChannels() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    showInput('getPinnedChannels', {
      'channelTypes': types.map((e) => e.name).toList(),
    });
    await BaseChannel.getPinnedChannels(types, (channels, error) {
      if (mounted) {
        final items = channels?.map((e) => e.toJson()).toList() ?? [];
        showResult(
            'getPinnedChannels',
            hasError(error)
                ? error?.toJson()
                : {
                    'count': items.length,
                    'channels': items,
                  });
      }
    });
  }

  void _deleteChannels() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Batch Delete Channels',
      params: [
        (label: 'ChannelId', hint: '', isNumber: false),
        (label: 'SubChannelId(optional)', hint: '', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channelId = args['ChannelId']?.trim() ?? '';
    final subChannelId = args['SubChannelId(optional)']?.trim();
    final identifiers = types
        .map(
          (t) => ChannelIdentifier(
            channelType: t,
            channelId: channelId,
            subChannelId: subChannelId != null && subChannelId.isNotEmpty
                ? subChannelId
                : null,
          ),
        )
        .toList();
    showInput('deleteChannels', {
      'identifiers': identifiers
          .map((i) => {
                'channelType': i.channelType.name,
                'channelId': i.channelId,
                'subChannelId': i.subChannelId,
              })
          .toList(),
    });
    await BaseChannel.deleteChannels(identifiers, (error) {
      if (mounted) showResult('deleteChannels', error?.toJson());
    });
  }

  void _syncRemoteChannels() async {
    showInput('syncRemoteChannels', const {});
    await BaseChannel.syncRemoteChannels((error) {
      if (mounted) showResult('syncRemoteChannels', error?.toJson());
    });
  }

  void _setChannelTypeNoDisturbLevel() async {
    final type = await pickChannelType(context);
    if (type == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Set Channel-Type No-Disturb',
      params: [(label: 'Level(0-4)', hint: '2', isNumber: true)],
    );
    if (args == null || !mounted) return;
    final level = _parseNoDisturbLevel(
      args['Level(0-4)'],
      'setChannelTypeNoDisturbLevel',
    );
    if (level == null) return;
    showInput('setChannelTypeNoDisturbLevel', {
      'channelType': type.name,
      'level': level.name,
    });
    await BaseChannel.setChannelTypeNoDisturbLevel(
      ChannelTypeNoDisturbLevelParams(channelType: type, level: level),
      (error) => showResult('setChannelTypeNoDisturbLevel', error?.toJson()),
    );
  }

  void _searchChannels() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Search Channels',
      params: [(label: 'Keyword', hint: 'keyword', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('searchChannels', {
      'channelTypes': types.map((e) => e.name).toList(),
      'keyword': args['Keyword'] ?? '',
      'messageTypes': [MessageType.text.name],
    });
    await BaseChannel.searchChannels(
      SearchChannelsParams(
          channelTypes: types,
          messageTypes: [MessageType.text],
          keyword: args['Keyword'] ?? ''),
      (results, error) {
        if (mounted) {
          final items = results?.map((e) => e.toJson()).toList() ?? [];
          showResult(
              'searchChannels',
              hasError(error)
                  ? error?.toJson()
                  : {
                      'count': items.length,
                      'results': items,
                    });
        }
      },
    );
  }

  void _getUnreadChannels() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    showInput('getUnreadChannels', {
      'channelTypes': types.map((e) => e.name).toList(),
    });
    await BaseChannel.getUnreadChannels(types, (channels, error) {
      if (mounted) {
        final items = channels?.map((e) => e.toJson()).toList() ?? [];
        showResult(
            'getUnreadChannels',
            hasError(error)
                ? error?.toJson()
                : {
                    'count': items.length,
                    'channels': items,
                  });
      }
    });
  }

  void _createChannelsQuery() async {
    final types = await pickChannelTypes(context);
    if (types == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Create Channels Query',
      params: [(label: 'Count', hint: '20', isNumber: true)],
    );
    if (args == null || !mounted) return;
    final count = int.tryParse(args['Count'] ?? '20') ?? 20;
    showInput('channelListQuery.load', {
      'channelTypes': types.map((e) => e.name).toList(),
      'count': count,
    });
    final query = BaseChannel.createChannelsQuery(
        ChannelsQueryParams(channelTypes: types, pageSize: count));
    await query.loadNextPage((page, error) {
      if (mounted) {
        final items = page?.data.map((e) => e.toJson()).toList() ?? [];
        showResult(
            'channelListQuery.load',
            hasError(error)
                ? error?.toJson()
                : {
                    'count': items.length,
                    'channels': items,
                  });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel')),
      body: ListView(
        children: [
          ApiSection(
            title: 'Single Channel Actions',
            children: [
              ApiButton(label: 'reload', onPressed: _reload),
              ApiButton(
                  label: 'clearUnreadCount', onPressed: _clearUnreadCount),
              ApiButton(
                  label: 'getUnreadMentionedMessages',
                  onPressed: _getUnreadMentionedMessages),
              ApiButton(label: 'pin', onPressed: _pin),
              ApiButton(label: 'unpin', onPressed: _unpin),
              ApiButton(label: 'delete', onPressed: _delete),
              ApiButton(label: 'saveDraft', onPressed: _saveDraft),
              ApiButton(label: 'clearDraft', onPressed: _clearDraft),
              ApiButton(
                  label: 'setNotificationLevel',
                  onPressed: _setNotificationLevel),
            ],
          ),
          ApiSection(
            title: 'Batch/Global Actions',
            children: [
              ApiButton(label: 'getChannels', onPressed: _getChannels),
              ApiButton(
                  label: 'getTotalUnreadCount',
                  onPressed: _getTotalUnreadCount),
              ApiButton(
                  label: 'getUnreadCountByType',
                  onPressed: _getUnreadCountByType),
              ApiButton(
                  label: 'getPinnedChannels', onPressed: _getPinnedChannels),
              ApiButton(label: 'deleteChannels', onPressed: _deleteChannels),
              ApiButton(
                  label: 'syncRemoteChannels', onPressed: _syncRemoteChannels),
              ApiButton(
                  label: 'setChannelTypeNoDisturbLevel',
                  onPressed: _setChannelTypeNoDisturbLevel),
              ApiButton(label: 'searchChannels', onPressed: _searchChannels),
              ApiButton(
                  label: 'getUnreadChannels', onPressed: _getUnreadChannels),
              ApiButton(
                  label: 'channelListQuery', onPressed: _createChannelsQuery),
            ],
          ),
        ],
      ),
    );
  }
}
