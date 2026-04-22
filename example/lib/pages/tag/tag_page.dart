import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  Tag? _currentTag;

  bool _ensureTagReady(Tag? tag, String action) {
    if (!mounted) return false;
    if (tag != null) return true;
    showResult('$action [onError]', {'error': 'tag not selected'});
    return false;
  }

  bool _ensureChannelPicked(
      PickedChannel? picked, String action) {
    if (!mounted) return false;
    if (picked != null) return true;
    showResult('$action [onError]', {'error': 'channel not selected'});
    return false;
  }

  Future<Tag?> _fetchTag() async {
    final args = await showParamsDialog(
      context,
      title: '输入 TagId',
      params: [
        (label: 'TagId', hint: _currentTag?.tagId ?? 'tagId', isNumber: false)
      ],
    );
    if (args == null || !mounted) {
      showResult('fetchTag [onError]', {'error': 'tagId is empty'});
      return null;
    }

    final inputTagId = args['TagId']?.trim() ?? '';
    final tagId =
        inputTagId.isNotEmpty ? inputTagId : (_currentTag?.tagId ?? '');
    if (tagId.isEmpty) return null;
    showInput('getTag', {'tagId': tagId});
    final completer = Completer<Tag?>();
    Tag.getTag(tagId, (tag, error) {
      if (hasError(error)) {
        showResult('getTag [onError]', error?.toJson());
        completer.complete(null);
      } else {
        setState(() => _currentTag = tag);
        completer.complete(tag);
      }
    });
    return completer.future;
  }

  void _createTag() async {
    final args = await showParamsDialog(
      context,
      title: '创建标签',
      params: [
        (label: 'TagId', hint: 'tagId', isNumber: false),
        (label: 'TagName', hint: 'tagName', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final tag = Tag();
    showInput('createTag', {
      'tagId': args['TagId'] ?? '',
      'tagName': args['TagName'] ?? '',
    });
    await tag.createTag(
      CreateTagParams(
          tagId: args['TagId'] ?? '', tagName: args['TagName'] ?? ''),
      (createdTag, error) {
        if (mounted) {
          if (createdTag != null) setState(() => _currentTag = createdTag);
          showResult('createTag [${hasError(error) ? 'onError' : 'onSuccess'}]',
              hasError(error) ? error?.toJson() : {'tagId': createdTag?.tagId});
        }
      },
    );
  }

  void _getTags() async {
    showInput('getTags', const {});
    await Tag.getTags((tags, error) {
      showResult(
          'getTags [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': tags?.length,
                  'tags': tags?.map((t) => t.toJson()).toList(),
                });
    });
  }

  void _deleteTag() async {
    final args = await showParamsDialog(
      context,
      title: '删除标签',
      params: [
        (label: 'TagId', hint: _currentTag?.tagId ?? 'tagId', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final tagId = (args['TagId'] ?? '').trim();
    if (tagId.isEmpty) {
      showResult('deleteTag [onError]', {'error': 'tagId is empty'});
      return;
    }
    showInput('deleteTag', {'tagId': tagId});
    final tag = Tag();
    tag.raw.tagId = tagId;
    await tag.delete(
      (error) {
        if (isSuccessResult(error) && mounted && _currentTag?.tagId == tagId) {
          setState(() => _currentTag = null);
        }
        showResult(
          'deleteTag [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
          error?.toJson(),
        );
      },
    );
  }

  void _updateTag() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'updateTag')) return;
    final selectedTag = tag!;
    final args = await showParamsDialog(
      context,
      title: '更新标签名',
      params: [(label: 'NewName', hint: 'new name', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('updateTag', {
      'tagId': selectedTag.tagId,
      'newName': args['NewName'] ?? '',
    });
    await selectedTag.update(
      args['NewName'] ?? '',
      (error) => showResult(
          'updateTag [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
          error?.toJson()),
    );
  }

  void _addChannel() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'addChannel')) return;
    final selectedTag = tag!;
    final picked = await pickChannel(context);
    if (!_ensureChannelPicked(picked, 'addChannel')) return;
    final selectedChannel = picked!;
    showInput('addChannel', {
      'tagId': selectedTag.tagId,
      'channelType': selectedChannel.type.name,
      'channelId': selectedChannel.id,
      'subChannelId': selectedChannel.subChannelId,
    });
    await selectedTag.addChannel(
      ChannelIdentifier(
        channelType: selectedChannel.type,
        channelId: selectedChannel.id,
        subChannelId: selectedChannel.subChannelId,
      ),
      (error) => showResult(
          'addChannel [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
          error?.toJson()),
    );
  }

  void _deleteChannelFromTag() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'deleteChannelFromTag')) return;
    final selectedTag = tag!;
    final picked = await pickChannel(context);
    if (!_ensureChannelPicked(picked, 'deleteChannelFromTag')) return;
    final selectedChannel = picked!;
    showInput('deleteChannelFromTag', {
      'tagId': selectedTag.tagId,
      'channelType': selectedChannel.type.name,
      'channelId': selectedChannel.id,
      'subChannelId': selectedChannel.subChannelId,
    });
    await selectedTag.deleteChannelFromTag(
      ChannelIdentifier(
        channelType: selectedChannel.type,
        channelId: selectedChannel.id,
        subChannelId: selectedChannel.subChannelId,
      ),
      (error) => showResult(
          'deleteChannelFromTag [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
          error?.toJson()),
    );
  }

  void _getUnreadCount() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'getUnreadCountByTag')) return;
    final selectedTag = tag!;
    final args = await showParamsDialog(
      context,
      title: '获取标签未读数',
      params: [(label: 'ContainNoDisturb(0/1)', hint: '0', isNumber: true)],
    );
    if (args == null || !mounted) return;
    showInput('getUnreadCountByTag', {
      'tagId': selectedTag.tagId,
      'containNoDisturb': args['ContainNoDisturb(0/1)'] == '1',
    });
    await selectedTag.getUnreadCount(
      args['ContainNoDisturb(0/1)'] == '1',
      (count, error) {
        showResult(
            'getUnreadCountByTag [${hasError(error) ? 'onError' : 'onSuccess'}]',
            hasError(error) ? error?.toJson() : {'count': count});
      },
    );
  }

  void _clearUnreadCount() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'clearUnreadCountByTag')) return;
    final selectedTag = tag!;
    showInput('clearUnreadCountByTag', {'tagId': selectedTag.tagId});
    await selectedTag.clearUnreadCount(
      (error) => showResult(
          'clearUnreadCountByTag [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
          error?.toJson()),
    );
  }

  void _tagChannelsQuery() async {
    final tag = await _fetchTag();
    if (!_ensureTagReady(tag, 'tagChannelsQuery')) return;
    final selectedTag = tag!;
    final args = await showParamsDialog(
      context,
      title: '获取标签下的会话',
      params: [
        (label: 'PageSize', hint: '20', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    showInput('tagChannelsQuery', {
      'tagId': selectedTag.tagId,
      'pageSize': int.tryParse(args['PageSize'] ?? '20') ?? 20,
    });
    final query = selectedTag.createTagChannelsQuery(TagChannelsQueryParams(
      tagId: selectedTag.tagId ?? '',
      pageSize: int.tryParse(args['PageSize'] ?? '20') ?? 20,
    ));
    await query.loadNextPage((page, error) {
      final items = page?.data.map((e) => e.toJson()).toList() ?? [];
      showResult(
          'tagChannelsQuery [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': items.length,
                  'channels': items,
                });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('标签相关'),
        actions: [
          if (_currentTag != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                  child: Text('tag: ${_currentTag?.tagName}',
                      style: const TextStyle(fontSize: 11))),
            ),
        ],
      ),
      body: ListView(
        children: [
          ApiSection(
            title: '标签管理',
            children: [
              ApiButton(label: '创建标签', onPressed: _createTag),
              ApiButton(label: '获取所有标签', onPressed: _getTags),
              ApiButton(label: '删除标签', onPressed: _deleteTag),
              ApiButton(label: '更新标签名', onPressed: _updateTag),
            ],
          ),
          ApiSection(
            title: '标签与会话',
            children: [
              ApiButton(label: '添加会话到标签', onPressed: _addChannel),
              ApiButton(label: '从标签移除会话', onPressed: _deleteChannelFromTag),
              ApiButton(label: '获取标签下会话', onPressed: _tagChannelsQuery),
            ],
          ),
          ApiSection(
            title: '未读数',
            children: [
              ApiButton(label: '获取标签未读数', onPressed: _getUnreadCount),
              ApiButton(label: '清除标签未读数', onPressed: _clearUnreadCount),
            ],
          ),
        ],
      ),
    );
  }
}
