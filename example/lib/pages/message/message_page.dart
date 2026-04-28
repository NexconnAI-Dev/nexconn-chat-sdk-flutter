import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

Map<String, dynamic>? _msgJson(Message? msg) => msg?.toJson();

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Message? _lastSentMessage;
  static const _handlerId = 'message_page_stream';
  static const _demoCustomIdentifier = 'nexconn:custom:demo';
  static const _demoCustomMediaIdentifier = 'nexconn:custom_media:demo';
  static const _needReceiptParam = (
    label: 'NeedReceipt(0/1)',
    hint: '0',
    isNumber: true,
  );
  static const _mentionTypeLabel = 'MentionType(0:none,1:all,2:user)';
  static const _mentionUserIdLabel = 'MentionUserId';
  static final _sendableChannelTypes = ChannelType.values
      .where((type) => type != ChannelType.system)
      .toList(growable: false);

  Future<PickedChannel?> _pickMessageChannel() {
    return pickChannel(context, availableTypes: _sendableChannelTypes);
  }

  bool _needReceiptFromArgs(Map<String, String> args) =>
      args[_needReceiptParam.label] == '1';

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
          showResult('$action [onError]', {'error': 'MentionUserId cannot be empty'});
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
        showResult('$action [onError]', {'error': 'MentionType only supports 0/1/2'});
        return (value: null, isValid: false);
    }
  }

  Map<String, dynamic>? _parseFieldsJson(
    String? value, {
    required String action,
  }) {
    final source = (value ?? '').trim();
    if (source.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      throw const FormatException('FieldsJson must be a JSON object');
    } catch (e) {
      if (mounted) {
        showResult('$action [onError]', {
          'error': 'FieldsJson must be a JSON object',
          'details': '$e',
        });
      }
      return null;
    }
  }

  List<String>? _parseSearchableWords(
    String? value, {
    required String action,
  }) {
    final source = (value ?? '').trim();
    if (source.isEmpty) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is List) {
        return decoded
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Fall back to comma-separated parsing below.
    }

    final items =
        source
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
    if (items.isEmpty) {
      showResult('$action [onError]', {
        'error': 'SearchableWords cannot be empty; pass a comma-separated string or JSON array',
      });
      return null;
    }
    return items;
  }

  CustomMessagePersistentFlag _persistentFlagFromArgs(
      Map<String, String> args) {
    final index = int.tryParse(args['PersistentFlag(0-3)'] ?? '2') ?? 2;
    return CustomMessagePersistentFlag.values[index.clamp(0, 3)];
  }

  void _registerCustomMessage() async {
    final args = await showParamsDialog(
      context,
      title: 'Register Custom Message',
      params: [
        (
          label: 'MessageIdentifier',
          hint: _demoCustomIdentifier,
          isNumber: false,
        ),
        (label: 'PersistentFlag(0-3)', hint: '2', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final identifier = (args['MessageIdentifier'] ?? '').trim().isEmpty
        ? _demoCustomIdentifier
        : args['MessageIdentifier']!.trim();
    showInput('registerCustomMessage', {
      'messageIdentifier': identifier,
      'persistentFlag': _persistentFlagFromArgs(args).name,
    });
    final code = await NCEngine.registerCustomMessage(
      identifier,
      _persistentFlagFromArgs(args),
    );
    if (mounted) {
      showResult('registerCustomMessage', {
        'code': code,
        'messageIdentifier': identifier,
      });
    }
  }

  void _registerCustomMediaMessage() async {
    final args = await showParamsDialog(
      context,
      title: 'Register Custom Media Message',
      params: [
        (
          label: 'MessageIdentifier',
          hint: _demoCustomMediaIdentifier,
          isNumber: false,
        ),
        (label: 'PersistentFlag(0-3)', hint: '2', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final identifier = (args['MessageIdentifier'] ?? '').trim().isEmpty
        ? _demoCustomMediaIdentifier
        : args['MessageIdentifier']!.trim();
    showInput('registerCustomMediaMessage', {
      'messageIdentifier': identifier,
      'persistentFlag': _persistentFlagFromArgs(args).name,
    });
    final code = await NCEngine.registerCustomMediaMessage(
      identifier,
      _persistentFlagFromArgs(args),
    );
    if (mounted) {
      showResult('registerCustomMediaMessage', {
        'code': code,
        'messageIdentifier': identifier,
      });
    }
  }

  void _sendCustomMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Custom Message',
      params: [
        (
          label: 'MessageIdentifier',
          hint: _demoCustomIdentifier,
          isNumber: false,
        ),
        (
          label: 'FieldsJson',
          hint: '{"title":"demo","value":1}',
          isNumber: false,
        ),
        (
          label: 'SearchableWords',
          hint: 'hello,world or ["hello","world"]',
          isNumber: false,
        ),
        _needReceiptParam,
      ],
    );
    if (args == null || !mounted) return;
    final fields = _parseFieldsJson(
      args['FieldsJson'],
      action: 'sendCustomMessage',
    );
    if (fields == null) return;
    final searchableWords = _parseSearchableWords(
      args['SearchableWords'],
      action: 'sendCustomMessage',
    );
    if ((args['SearchableWords'] ?? '').trim().isNotEmpty &&
        searchableWords == null) {
      return;
    }
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('sendCustomMessage', {
      ...channelInput(picked),
      'messageIdentifier': (args['MessageIdentifier'] ?? '').trim().isEmpty
          ? _demoCustomIdentifier
          : args['MessageIdentifier']!.trim(),
      'fields': fields,
      'searchableWords': searchableWords,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMessage(
      SendMessageParams(
        messageParams: CustomMessageParams(
          messageIdentifier: (args['MessageIdentifier'] ?? '').trim().isEmpty
              ? _demoCustomIdentifier
              : args['MessageIdentifier']!.trim(),
          fields: fields,
          searchableWords: searchableWords,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      callback: SendMessageCallback(
        onMessageSaved: (m) => setState(() => _lastSentMessage = m),
        onMessageSent: (code, m) {
          setState(() => _lastSentMessage = m);
          if (mounted) {
            showResult('sendCustomMessage', {
              'code': code,
              'message': _msgJson(m),
            });
          }
        },
      ),
    );
  }

  void _sendCustomMediaMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final path = await pickLocalFile(FilePickType.file);
    if (path == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Custom Media Message',
      params: [
        (
          label: 'MessageIdentifier',
          hint: _demoCustomMediaIdentifier,
          isNumber: false,
        ),
        (
          label: 'FieldsJson',
          hint: '{"title":"media demo","kind":"file"}',
          isNumber: false,
        ),
        (
          label: 'SearchableWords',
          hint: 'hello,world or ["hello","world"]',
          isNumber: false,
        ),
        _needReceiptParam,
      ],
    );
    if (args == null || !mounted) return;
    final fields = _parseFieldsJson(
      args['FieldsJson'],
      action: 'sendCustomMediaMessage',
    );
    if (fields == null) return;
    final searchableWords = _parseSearchableWords(
      args['SearchableWords'],
      action: 'sendCustomMediaMessage',
    );
    if ((args['SearchableWords'] ?? '').trim().isNotEmpty &&
        searchableWords == null) {
      return;
    }
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('sendCustomMediaMessage', {
      ...channelInput(picked),
      'messageIdentifier': (args['MessageIdentifier'] ?? '').trim().isEmpty
          ? _demoCustomMediaIdentifier
          : args['MessageIdentifier']!.trim(),
      'path': path,
      'fields': fields,
      'searchableWords': searchableWords,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: CustomMediaMessageParams(
          messageIdentifier: (args['MessageIdentifier'] ?? '').trim().isEmpty
              ? _demoCustomMediaIdentifier
              : args['MessageIdentifier']!.trim(),
          path: path,
          fields: fields,
          searchableWords: searchableWords,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSaved: (m) => setState(() => _lastSentMessage = m),
        onMediaMessageSent: (code, m) {
          setState(() => _lastSentMessage = m);
          if (mounted) {
            showResult('sendCustomMediaMessage', {
              'code': code,
              'message': _msgJson(m),
            });
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    NCEngine.addMessageHandler(
      _handlerId,
      MessageHandler(
        onStreamMessageRequestInit: (event) {
          if (mounted)
            showResult('onStreamMessageRequestInit', {
              'messageId': event.messageId,
            });
        },
        onStreamMessageRequestDelta: (event) {
          if (mounted) {
            showResult('onStreamMessageRequestDelta', {
              'messageId': event.message?.messageId,
              'chunkContent': event.chunkInfo?.content,
              'currentContent': event.message?.content,
            });
          }
        },
        onStreamMessageRequestComplete: (event) {
          if (mounted)
            showResult('onStreamMessageRequestComplete', {
              'messageId': event.messageId,
              'error': event.error?.toJson(),
            });
        },
      ),
    );
  }

  @override
  void dispose() {
    NCEngine.removeMessageHandler(_handlerId);
    super.dispose();
  }

  void _sendTextMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Text Message',
      params: [
        (label: 'Text', hint: 'hello', isNumber: false),
        (label: _mentionTypeLabel, hint: '0', isNumber: true),
        (
          label: _mentionUserIdLabel,
          hint: 'userId when type=2',
          isNumber: false,
        ),
        _needReceiptParam,
      ],
    );
    if (args == null || !mounted) return;
    final mention = _mentionedInfoFromArgs(args, action: 'sendTextMessage');
    if (!mention.isValid) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.text.name,
      'text': args['Text'] ?? 'hello',
      'mentionedInfo': mention.value?.toJson(),
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMessage(
      SendMessageParams(
        messageParams: TextMessageParams(
          text: args['Text'] ?? 'hello',
          mentionedInfo: mention.value,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      callback: SendMessageCallback(
        onMessageSaved: (m) => setState(() => _lastSentMessage = m),
        onMessageSent: (code, m) {
          setState(() => _lastSentMessage = m);
          if (mounted)
            showResult('onMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendImageMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final path = await pickLocalFile(FilePickType.image);
    if (path == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Image Message',
      params: [_needReceiptParam],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMediaMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.image.name,
      'path': path,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: ImageMessageParams(
          path: path,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSending: (m, progress) {},
        onMediaMessageSent: (code, m) {
          setState(() => _lastSentMessage = m);
          if (mounted)
            showResult(
                'onMediaMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendHDVoiceMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final recorded = await recordVoice(context);
    if (recorded == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send HD Voice Message',
      params: [_needReceiptParam],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMediaMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.voice.name,
      'path': recorded.path,
      'duration': recorded.duration,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: HDVoiceMessageParams(
          path: recorded.path,
          duration: recorded.duration,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSent: (code, m) {
          if (mounted)
            showResult(
                'onMediaMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendFileMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final path = await pickLocalFile(FilePickType.file);
    if (path == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send File Message',
      params: [_needReceiptParam],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMediaMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.file.name,
      'path': path,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: FileMessageParams(
          path: path,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSending: (m, progress) {},
        onMediaMessageSent: (code, m) {
          if (mounted)
            showResult(
                'onMediaMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendShortVideoMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final path = await pickLocalFile(FilePickType.video);
    if (path == null || !mounted) return;
    final player = AudioPlayer();
    int duration = 10;
    try {
      final d = await player.setFilePath(path);
      duration = d?.inSeconds ?? 10;
    } finally {
      await player.dispose();
    }
    if (!mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Short Video Message',
      params: [_needReceiptParam],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMediaMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.sight.name,
      'path': path,
      'duration': duration,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: ShortVideoMessageParams(
          path: path,
          duration: duration,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSent: (code, m) {
          if (mounted)
            showResult(
                'onMediaMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendGifMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final path = await pickLocalFile(FilePickType.gif);
    if (path == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send GIF Message',
      params: [_needReceiptParam],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMediaMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.gif.name,
      'path': path,
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMediaMessage(
      SendMediaMessageParams(
        messageParams: GIFMessageParams(
          path: path,
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      handler: SendMediaMessageHandler(
        onMediaMessageSent: (code, m) {
          if (mounted)
            showResult(
                'onMediaMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendLocationMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Location Message',
      params: [
        (label: 'Latitude', hint: '39.9', isNumber: false),
        (label: 'Longitude', hint: '116.3', isNumber: false),
        (label: 'POI', hint: 'Beijing', isNumber: false),
        _needReceiptParam,
      ],
    );
    if (args == null || !mounted) return;
    final thumbPath = await pickLocalFile(FilePickType.image);
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('onMessageSent', {
      ...channelInput(picked),
      'messageType': MessageType.location.name,
      'latitude': double.tryParse(args['Latitude'] ?? '0') ?? 0,
      'longitude': double.tryParse(args['Longitude'] ?? '0') ?? 0,
      'poiName': args['POI'] ?? '',
      'thumbnailPath': thumbPath ?? '',
      'needReceipt': _needReceiptFromArgs(args),
    });
    await channel.sendMessage(
      SendMessageParams(
        messageParams: LocationMessageParams(
          latitude: double.tryParse(args['Latitude'] ?? '0') ?? 0,
          longitude: double.tryParse(args['Longitude'] ?? '0') ?? 0,
          poiName: args['POI'] ?? '',
          thumbnailPath: thumbPath ?? '',
          needReceipt: _needReceiptFromArgs(args),
        ),
      ),
      callback: SendMessageCallback(
        onMessageSent: (code, m) {
          if (mounted)
            showResult('onMessageSent', {'code': code, 'message': _msgJson(m)});
        },
      ),
    );
  }

  void _sendReferenceMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Reference Message',
      params: [
        (label: 'ReferenceMessageId', hint: 'messageId', isNumber: false),
        (label: 'Text', hint: 'reply text', isNumber: false),
        _needReceiptParam,
      ],
    );
    if (args == null || !mounted) return;
    await BaseChannel.getMessageById(
      GetMessageByIdParams(messageId: args['ReferenceMessageId']),
      (refMsg, error) async {
        if (hasError(error) || refMsg == null) {
          if (mounted)
            showResult('sendReferenceMessage',
                {...?error?.toJson(), 'error': 'cannot find reference msg'});
          return;
        }
        final channel = makeChannelFromType(
          picked.type,
          picked.id,
          subChannelId: picked.subChannelId,
        );
        showInput('sendReferenceMessage', {
          ...channelInput(picked),
          'messageType': MessageType.reference.name,
          'referenceMessageId': args['ReferenceMessageId'],
          'text': args['Text'] ?? '',
          'needReceipt': _needReceiptFromArgs(args),
        });
        await channel.sendMessage(
          SendMessageParams(
            messageParams: ReferenceMessageParams(
              text: args['Text'] ?? '',
              referenceMessage: refMsg,
              needReceipt: _needReceiptFromArgs(args),
            ),
          ),
          callback: SendMessageCallback(
            onMessageSent: (code, m) {
              if (mounted)
                showResult(
                    'onMessageSent', {'code': code, 'message': _msgJson(m)});
            },
          ),
        );
      },
    );
  }

  void _deleteMessage() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Delete Message (Local + Remote)',
      params: [
        (label: 'MessageId', hint: 'messageId', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final uid = args['MessageId'] ?? '';
    if (uid.isEmpty) return;
    showInput('deleteMessagesForMe', {
      ...channelInput(picked),
      'messageId': uid,
    });
    await BaseChannel.getMessageById(
      GetMessageByIdParams(messageId: uid),
      (msg, error) async {
        if (msg == null) {
          if (mounted)
            showResult('deleteMessagesForMe', {'error': 'message not found'});
          return;
        }
        final channel = makeChannelFromType(
          picked.type,
          picked.id,
          subChannelId: picked.subChannelId,
        );
        await channel.deleteMessagesForMe(
          [msg],
          (error) => showResult('deleteMessagesForMe', error?.toJson()),
        );
      },
    );
  }

  void _deleteMessageForAll() async {
    final args = await showParamsDialog(
      context,
      title: 'Delete Message for All',
      params: [(label: 'MessageId', hint: 'messageId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('deleteMessageForAll', {'messageId': args['MessageId']});
    await BaseChannel.getMessageById(
      GetMessageByIdParams(messageId: args['MessageId']),
      (msg, error) async {
        if (msg == null) {
          if (mounted)
            showResult('deleteMessageForAll', {'error': 'message not found'});
          return;
        }
        await BaseChannel.deleteMessageForAll(msg, (result, error) {
          if (mounted)
            showResult('deleteMessageForAll',
                {...?error?.toJson(), 'message': _msgJson(result)});
        });
      },
    );
  }

  void _deleteMessagesForMeByTimestamp() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Delete Messages by Timestamp (Me)',
      params: [
        (label: 'Timestamp', hint: '0 (0=all)', isNumber: true),
        (label: 'Policy(0=local,1=remote)', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('deleteMessagesForMeByTimestamp', {
      ...channelInput(picked),
      'timestamp': int.tryParse(args['Timestamp'] ?? '0') ?? 0,
      'policy': MessageOperationPolicy
          .values[int.tryParse(args['Policy(0=local,1=remote)'] ?? '0') ?? 0]
          .name,
    });
    await channel.deleteMessagesForMeByTimestamp(
      DeleteMessagesForMeByTimestampParams(
        timestamp: int.tryParse(args['Timestamp'] ?? '0') ?? 0,
        policy: MessageOperationPolicy
            .values[int.tryParse(args['Policy(0=local,1=remote)'] ?? '0') ?? 0],
      ),
      (error) => showResult('deleteMessagesForMeByTimestamp', error?.toJson()),
    );
  }

  void _getMessageById() async {
    final args = await showParamsDialog(
      context,
      title: 'Get Message by ID',
      params: [
        (
          label: 'MessageId',
          hint: 'messageId (or use ClientId)',
          isNumber: false
        ),
        (label: 'ClientId', hint: '(optional, int)', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    showInput('getMessageById', {
      'messageId':
          (args['MessageId'] ?? '').isNotEmpty ? args['MessageId'] : null,
      'clientId': (args['ClientId'] ?? '').isNotEmpty
          ? int.tryParse(args['ClientId']!)
          : null,
    });
    await BaseChannel.getMessageById(
      GetMessageByIdParams(
        messageId:
            (args['MessageId'] ?? '').isNotEmpty ? args['MessageId'] : null,
        messageClientId: (args['ClientId'] ?? '').isNotEmpty
            ? int.tryParse(args['ClientId']!)
            : null,
      ),
      (msg, error) {
        if (mounted) {
          showResult('getMessageById', {
            ...?error?.toJson(),
            'message': _msgJson(msg),
          });
        }
      },
    );
  }

  void _messagesQuery() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Local Messages Query',
      params: [
        (label: 'Count', hint: '20', isNumber: true),
        (label: 'IsAscending(0=false,1=true)', hint: '0', isNumber: true),
        (label: 'StartTime', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final isAscending =
        (int.tryParse(args['IsAscending(0=false,1=true)'] ?? '0') ?? 0) == 1;
    final startTime = int.tryParse(args['StartTime'] ?? '0') ?? 0;
    showInput('messagesQuery', {
      ...channelInput(picked),
      'count': int.tryParse(args['Count'] ?? '20') ?? 20,
      'isAscending': isAscending,
      'startTime': startTime,
    });
    final query = BaseChannel.createMessagesQuery(MessagesQueryParams(
      channelIdentifier:
          ChannelIdentifier(
            channelType: picked.type,
            channelId: picked.id,
            subChannelId: picked.subChannelId,
          ),
      pageSize: int.tryParse(args['Count'] ?? '20') ?? 20,
      isAscending: isAscending,
      startTime: startTime,
    ));
    await query.loadNextPage((page, error) {
      if (mounted) {
        showResult('messagesQuery', {
          ...?error?.toJson(),
          'count': page?.data.length ?? 0,
          'totalCount': page?.totalCount,
          'messages': page?.data.map((m) => m.toJson()).toList(),
        });
      }
    });
  }

  void _remoteMessagesQuery() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Remote Messages Query',
      params: [
        (label: 'Count', hint: '20', isNumber: true),
        (label: 'IsAscending(0=false,1=true)', hint: '0', isNumber: true),
        (label: 'StartTime', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final isAscending =
        (int.tryParse(args['IsAscending(0=false,1=true)'] ?? '0') ?? 0) == 1;
    final startTime = int.tryParse(args['StartTime'] ?? '0') ?? 0;
    showInput('remoteMessagesQuery', {
      ...channelInput(picked),
      'count': int.tryParse(args['Count'] ?? '20') ?? 20,
      'isAscending': isAscending,
      'startTime': startTime,
    });
    final query = BaseChannel.createMessagesQuery(MessagesQueryParams(
      channelIdentifier:
          ChannelIdentifier(
            channelType: picked.type,
            channelId: picked.id,
            subChannelId: picked.subChannelId,
          ),
      pageSize: int.tryParse(args['Count'] ?? '20') ?? 20,
      isAscending: isAscending,
      startTime: startTime,
      policy: MessageOperationPolicy.remote,
    ));
    await query.loadNextPage((page, error) {
      if (mounted) {
        showResult('remoteMessagesQuery', {
          ...?error?.toJson(),
          'count': page?.data.length ?? 0,
          'totalCount': page?.totalCount,
          'messages': page?.data.map((m) => m.toJson()).toList(),
        });
      }
    });
  }

  void _searchMessages() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Search Messages',
      params: [
        (label: 'Keyword', hint: 'keyword', isNumber: false),
        (label: 'Count', hint: '20', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    showInput('searchMessages', {
      ...channelInput(picked),
      'keyword': args['Keyword'] ?? '',
      'count': int.tryParse(args['Count'] ?? '20') ?? 20,
    });
    final query =
        BaseChannel.createSearchMessagesQuery(SearchMessagesQueryParams(
      channelIdentifier:
          ChannelIdentifier(
            channelType: picked.type,
            channelId: picked.id,
            subChannelId: picked.subChannelId,
          ),
      keyword: args['Keyword'] ?? '',
      pageSize: int.tryParse(args['Count'] ?? '20') ?? 20,
    ));
    final code = await query.loadNextPage((page, error) {
      if (mounted) {
        showResult('searchMessages', {
          ...?error?.toJson(),
          'count': page?.data.length ?? 0,
          'messages': page?.data.map((m) => m.toJson()).toList(),
        });
      }
    });
    if (code != 0 && mounted) {
      showResult('searchMessages', {'code': code});
    }
  }

  void _insertMessages() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Insert Messages (Local)',
      params: [
        (label: 'Text', hint: 'insert text', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('insertMessages', {
      ...channelInput(picked),
      'messages': [
        {'messageType': MessageType.text.name, 'text': args['Text'] ?? ''}
      ],
    });
    await channel.insertMessages(
      InsertMessagesParams(
        messageParamsList: [TextMessageParams(text: args['Text'] ?? '')],
      ),
      (msgs, error) {
        if (mounted) {
          showResult('insertMessages', {
            ...?error?.toJson(),
            'count': msgs?.length ?? 0,
            'messages': msgs?.map((m) => m.toJson()).toList(),
          });
        }
      },
    );
  }

  void _sendReadReceiptResponse() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Send Read Receipt',
      params: [
        (
          label: 'MessageIds(comma separated)',
          hint: 'id1,id2',
          isNumber: false
        ),
      ],
    );
    if (args == null || !mounted) return;
    final uids = (args['MessageIds(comma separated)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('sendReadReceiptResponse', {
      ...channelInput(picked),
      'messageIds': uids,
    });
    await channel.sendReadReceiptResponse(uids, (error) {
      if (mounted) showResult('sendReadReceiptResponse', error?.toJson());
    });
  }

  void _getMessageReadReceiptInfo() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Get Read Receipt Info',
      params: [
        (
          label: 'MessageIds(comma separated)',
          hint: 'id1,id2',
          isNumber: false
        ),
      ],
    );
    if (args == null || !mounted) return;
    final uids = (args['MessageIds(comma separated)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('getMessageReadReceiptInfo', {
      ...channelInput(picked),
      'messageIds': uids,
    });
    await channel.getMessageReadReceiptInfo(uids, (infos, error) {
      if (mounted) {
        showResult('getMessageReadReceiptInfo', {
          ...?error?.toJson(),
          'count': infos?.length ?? 0,
          'infos': infos?.map((e) => e.toJson()).toList() ?? [],
        });
      }
    });
  }

  void _getMessagesAroundTime() async {
    final picked = await _pickMessageChannel();
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Get Messages Around Time',
      params: [
        (label: 'SentTime(ms)', hint: '1700000000000', isNumber: true),
        (label: 'BeforeCount', hint: '10', isNumber: true),
        (label: 'AfterCount', hint: '10', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final channel = makeChannelFromType(
      picked.type,
      picked.id,
      subChannelId: picked.subChannelId,
    );
    showInput('getMessagesAroundTime', {
      ...channelInput(picked),
      'sentTime': int.tryParse(args['SentTime(ms)'] ?? '0') ?? 0,
      'beforeCount': int.tryParse(args['BeforeCount'] ?? '10') ?? 10,
      'afterCount': int.tryParse(args['AfterCount'] ?? '10') ?? 10,
    });
    final code = await channel.getMessagesAroundTime(
      GetMessagesAroundTimeParams(
        sentTime: int.tryParse(args['SentTime(ms)'] ?? '0') ?? 0,
        beforeCount: int.tryParse(args['BeforeCount'] ?? '10') ?? 10,
        afterCount: int.tryParse(args['AfterCount'] ?? '10') ?? 10,
      ),
      (msgs, error) {
        if (mounted) {
          showResult('getMessagesAroundTime', {
            ...?error?.toJson(),
            'count': msgs?.length ?? 0,
            'messages': msgs?.map((m) => m.toJson()).toList(),
          });
        }
      },
    );
    if (code != 0 && mounted) {
      showResult('getMessagesAroundTime', {'code': code});
    }
  }

  void _requestStreamMessageContent() async {
    final args = await showParamsDialog(
      context,
      title: 'Request Stream Message Content',
      params: [
        (label: 'MessageId', hint: 'messageId', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final uid = args['MessageId'] ?? '';
    if (uid.isEmpty) return;
    showInput('requestStreamMessageContent', {'messageId': uid});
    await BaseChannel.getMessageById(
      GetMessageByIdParams(messageId: uid),
      (msg, error) async {
        if (msg == null || msg is! StreamMessage) {
          if (mounted)
            showResult('requestStreamMessageContent [onError]',
                {'error': 'stream message not found'});
          return;
        }
        await msg.requestStreamMessage((error) {
          if (mounted) {
            showResult(
              'requestStreamMessageContent [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
              error?.toJson(),
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        actions: [
          if (_lastSentMessage != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'last: ${_lastSentMessage?.messageType?.name ?? '?'}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        children: [
          ApiSection(
            title: 'Send Messages',
            children: [
              ApiButton(label: 'Send Text Message', onPressed: _sendTextMessage),
              ApiButton(label: 'Send Image Message', onPressed: _sendImageMessage),
              ApiButton(label: 'Send HD Voice Message', onPressed: _sendHDVoiceMessage),
              ApiButton(label: 'Send File Message', onPressed: _sendFileMessage),
              ApiButton(label: 'Send Short Video Message', onPressed: _sendShortVideoMessage),
              ApiButton(label: 'Send GIF Message', onPressed: _sendGifMessage),
              ApiButton(label: 'Send Location Message', onPressed: _sendLocationMessage),
              ApiButton(label: 'Send Reference Message', onPressed: _sendReferenceMessage),
            ],
          ),
          ApiSection(
            title: 'Custom Messages',
            children: [
              ApiButton(label: 'Register Custom Message', onPressed: _registerCustomMessage),
              ApiButton(
                  label: 'Register Custom Media Message', onPressed: _registerCustomMediaMessage),
              ApiButton(label: 'Send Custom Message', onPressed: _sendCustomMessage),
              ApiButton(label: 'Send Custom Media Message', onPressed: _sendCustomMediaMessage),
            ],
          ),
          ApiSection(
            title: 'Message Actions',
            children: [
              ApiButton(label: 'Delete Message', onPressed: _deleteMessage),
              ApiButton(label: 'Delete Message for All', onPressed: _deleteMessageForAll),
              ApiButton(
                label: 'Delete Messages by Timestamp (Me)',
                onPressed: _deleteMessagesForMeByTimestamp,
              ),
              ApiButton(label: 'Insert Messages (Local)', onPressed: _insertMessages),
              ApiButton(label: 'Get Message by ID', onPressed: _getMessageById),
            ],
          ),
          ApiSection(
            title: 'Message Query',
            children: [
              ApiButton(label: 'Local Messages Query', onPressed: _messagesQuery),
              ApiButton(label: 'Remote Messages Query', onPressed: _remoteMessagesQuery),
              ApiButton(label: 'Search Messages', onPressed: _searchMessages),
              ApiButton(label: 'Get Messages Around Time', onPressed: _getMessagesAroundTime),
            ],
          ),
          ApiSection(
            title: 'Read Receipt',
            children: [
              ApiButton(label: 'Send Read Receipt', onPressed: _sendReadReceiptResponse),
              ApiButton(
                  label: 'Get Read Receipt Info', onPressed: _getMessageReadReceiptInfo),
            ],
          ),
          ApiSection(
            title: 'Stream Message',
            children: [
              ApiButton(
                  label: 'Request Stream Message Content', onPressed: _requestStreamMessageContent),
            ],
          ),
        ],
      ),
    );
  }
}
