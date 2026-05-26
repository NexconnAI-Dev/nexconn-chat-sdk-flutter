import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import 'package:test/test.dart';

void main() {
  group('CombineMessageParams', () {
    test('allows jsonMsgKey without msgList', () {
      final params = CombineMessageParams(
        sourceChannelType: ChannelType.direct,
        summaryList: const ['summary'],
        nameList: const ['Alice'],
        jsonMsgKey: 'json-key',
      );

      expect(params.msgList, isNull);
      expect(params.jsonMsgKey, 'json-key');
    });

    test('keeps existing msgList-only construction', () {
      final msgInfo = CombineMessageInfo(
        fromUserId: 'user-1',
        channelId: 'channel-1',
        timestamp: 1,
        objectName: 'NC:TxtMsg',
        content: const {'content': 'hello'},
      );
      final params = CombineMessageParams(
        sourceChannelType: ChannelType.group,
        summaryList: const ['hello'],
        nameList: const ['Alice'],
        msgList: [msgInfo],
      );

      expect(params.msgList, [msgInfo]);
      expect(params.jsonMsgKey, isNull);
    });

    test('keeps both msgList and jsonMsgKey when provided', () {
      final msgInfo = CombineMessageInfo(
        fromUserId: 'user-1',
        channelId: 'channel-1',
        timestamp: 1,
        objectName: 'NC:TxtMsg',
        content: const {'content': 'hello'},
      );
      final params = CombineMessageParams(
        sourceChannelType: ChannelType.group,
        summaryList: const ['hello'],
        nameList: const ['Alice'],
        msgList: [msgInfo],
        jsonMsgKey: 'json-key',
      );

      expect(params.msgList, [msgInfo]);
      expect(params.jsonMsgKey, 'json-key');
    });
  });
}
