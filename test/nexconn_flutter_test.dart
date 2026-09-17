import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';
import 'package:test/test.dart';

void main() {
  group('message edit models', () {
    test('creates an edited message draft without exposing wrapper types', () {
      final draft = EditedMessageDraft(
        messageId: 'message-1',
        content: '{"content":"edited"}',
      );

      expect(draft.messageId, 'message-1');
      expect(draft.content, '{"content":"edited"}');
      expect(draft.toJson(), {
        'messageId': 'message-1',
        'content': '{"content":"edited"}',
      });
    });

    test('allows an edited message draft with null content', () {
      final draft = EditedMessageDraft(messageId: 'message-1', content: null);

      expect(draft.content, isNull);
      expect(draft.raw.content, isNull);
      expect(draft.toJson(), {'messageId': 'message-1', 'content': null});
    });

    RCIMIWTextMessage messageWithModification({
      required bool hasChanged,
      required RCIMIWMessageModifyStatus status,
    }) {
      final message = RCIMIWTextMessage.fromJson({'text': 'original'});
      message.hasChanged = hasChanged;
      message.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: RCIMIWTextMessage.fromJson({'text': 'edited'}),
        status: status,
      );
      return message;
    }

    test('uses modified text only for a changed message in success state', () {
      expect(
        TextMessage.fromRaw(
          messageWithModification(
            hasChanged: true,
            status: RCIMIWMessageModifyStatus.success,
          ),
        ).text,
        'edited',
      );
      expect(
        TextMessage.fromRaw(
          messageWithModification(
            hasChanged: true,
            status: RCIMIWMessageModifyStatus.updating,
          ),
        ).text,
        'original',
      );
      expect(
        TextMessage.fromRaw(
          messageWithModification(
            hasChanged: false,
            status: RCIMIWMessageModifyStatus.success,
          ),
        ).text,
        'original',
      );
    });

    test('uses successful modified content for reference messages', () {
      final original = RCIMIWReferenceMessage.fromJson({
        'text': 'old reply',
        'referenceMessage': {
          'conversationType': RCIMIWConversationType.group.index,
          'messageType': RCIMIWMessageType.text.index,
          'targetId': 'team',
          'channelId': 'thread',
          'messageId': 42,
          'messageUId': 'quoted-message',
          'text': 'old quote',
        },
      });
      final modified = RCIMIWReferenceMessage.fromJson({
        'text': 'new reply',
        'referenceMessage': {
          'messageType': RCIMIWMessageType.text.index,
          'text': 'new quote',
        },
      });
      original.hasChanged = true;
      original.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: modified,
        status: RCIMIWMessageModifyStatus.success,
      );

      final wrapped = ReferenceMessage.fromRaw(original);
      final referenced = wrapped.referenceMsg as TextMessage;
      expect(wrapped.text, 'new reply');
      expect(referenced.text, 'new quote');
      expect(referenced.messageId, 'quoted-message');
      expect(referenced.clientId, 42);
      expect(referenced.channelType, ChannelType.group);
      expect(referenced.channelId, 'team');
      expect(referenced.subChannelId, 'thread');
    });

    test('keeps an explicit edited reference identity', () {
      final original = RCIMIWReferenceMessage.fromJson({
        'text': 'old reply',
        'referenceMessage': {
          'conversationType': RCIMIWConversationType.group.index,
          'messageType': RCIMIWMessageType.text.index,
          'targetId': 'old-team',
          'channelId': 'old-thread',
          'messageId': 42,
          'messageUId': 'old-quoted-message',
          'text': 'old quote',
        },
      });
      final modified = RCIMIWReferenceMessage.fromJson({
        'text': 'new reply',
        'referenceMessage': {
          'conversationType': RCIMIWConversationType.private.index,
          'messageType': RCIMIWMessageType.text.index,
          'targetId': 'new-target',
          'channelId': 'new-channel',
          'messageId': 84,
          'messageUId': 'new-quoted-message',
          'text': 'new quote',
        },
      });
      original.hasChanged = true;
      original.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: modified,
        status: RCIMIWMessageModifyStatus.success,
      );

      final referenced = ReferenceMessage.fromRaw(original).referenceMsg;

      expect(referenced?.messageId, 'new-quoted-message');
      expect(referenced?.clientId, 84);
      expect(referenced?.channelType, ChannelType.direct);
      expect(referenced?.channelId, 'new-target');
      expect(referenced?.subChannelId, 'new-channel');
    });

    test('restores complete nested reference envelopes recursively', () {
      final original = RCIMIWReferenceMessage.fromJson({
        'text': 'old reply',
        'referenceMessage': {
          'conversationType': RCIMIWConversationType.group.index,
          'messageType': RCIMIWMessageType.reference.index,
          'targetId': 'team',
          'channelId': 'thread',
          'messageId': 42,
          'messageUId': 'quoted-reference',
          'receivedTime': 1001,
          'sentTime': 1000,
          'senderUserId': 'reference-author',
          'direction': RCIMIWMessageDirection.receive.index,
          'receivedStatus': RCIMIWReceivedStatus.read.index,
          'userInfo': {
            'userId': 'reference-author',
            'name': 'Reference Author',
          },
          'needReceipt': true,
          'text': 'old nested reply',
          'referenceMessage': {
            'conversationType': RCIMIWConversationType.group.index,
            'messageType': RCIMIWMessageType.text.index,
            'targetId': 'team',
            'channelId': 'thread',
            'messageId': 21,
            'messageUId': 'deep-quote',
            'receivedTime': 901,
            'sentTime': 900,
            'senderUserId': 'deep-author',
            'direction': RCIMIWMessageDirection.send.index,
            'sentStatus': RCIMIWSentStatus.sent.index,
            'userInfo': {'userId': 'deep-author', 'name': 'Deep Author'},
            'text': 'old deep quote',
          },
        },
      });
      final modified = RCIMIWReferenceMessage.fromJson({
        'text': 'new reply',
        'referenceMessage': {
          'messageType': RCIMIWMessageType.reference.index,
          'text': 'new nested reply',
          'referenceMessage': {
            'messageType': RCIMIWMessageType.text.index,
            'text': 'new deep quote',
          },
        },
      });
      original
        ..hasChanged = true
        ..modifyInfo = RCIMIWMessageModifyInfo.create(
          content: modified,
          status: RCIMIWMessageModifyStatus.success,
        );

      final referenced =
          ReferenceMessage.fromRaw(original).referenceMsg as ReferenceMessage;
      final deeplyReferenced = referenced.referenceMsg as TextMessage;

      expect(referenced.messageId, 'quoted-reference');
      expect(referenced.clientId, 42);
      expect(referenced.senderUserId, 'reference-author');
      expect(referenced.userInfo?.name, 'Reference Author');
      expect(referenced.sentTime, 1000);
      expect(referenced.receivedTime, 1001);
      expect(referenced.direction, MessageDirection.receive);
      expect(referenced.receivedStatus, ReceivedStatus.read);
      expect(referenced.needReceipt, isTrue);
      expect(referenced.text, 'new nested reply');
      expect(deeplyReferenced.messageId, 'deep-quote');
      expect(deeplyReferenced.clientId, 21);
      expect(deeplyReferenced.senderUserId, 'deep-author');
      expect(deeplyReferenced.userInfo?.name, 'Deep Author');
      expect(deeplyReferenced.sentTime, 900);
      expect(deeplyReferenced.receivedTime, 901);
      expect(deeplyReferenced.direction, MessageDirection.send);
      expect(deeplyReferenced.sentStatus, SentStatus.sent);
      expect(deeplyReferenced.text, 'new deep quote');
    });

    test('uses the edited mention payload and supports clearing mentions', () {
      RCIMIWTextMessage editedMessage(RCIMIWMentionedInfo? mentionedInfo) {
        final original =
            RCIMIWTextMessage.fromJson({'text': 'old'})
              ..mentionedInfo = RCIMIWMentionedInfo.create(
                type: RCIMIWMentionedType.part,
                userIdList: const ['old-user'],
              )
              ..hasChanged = true;
        final modified = RCIMIWTextMessage.fromJson({'text': 'new'})
          ..mentionedInfo = mentionedInfo;
        original.modifyInfo = RCIMIWMessageModifyInfo.create(
          content: modified,
          status: RCIMIWMessageModifyStatus.success,
        );
        return original;
      }

      final changed = TextMessage.fromRaw(
        editedMessage(
          RCIMIWMentionedInfo.create(
            type: RCIMIWMentionedType.part,
            userIdList: const ['new-user'],
          ),
        ),
      );
      expect(changed.mentionedInfo?.userIdList, const ['new-user']);

      final cleared = TextMessage.fromRaw(editedMessage(null));
      expect(cleared.mentionedInfo, isNull);
    });

    test('keeps the strongest reference terminal state after an edit', () {
      final outer = RCIMIWReferenceMessage.fromJson({
        'text': 'old reply',
        'referMsgStatus': RCIMIWReferenceMessageStatus.deleted.index,
      });
      final modified = RCIMIWReferenceMessage.fromJson({
        'text': 'new reply',
        'referMsgStatus': RCIMIWReferenceMessageStatus.defaultValue.index,
      });
      outer.hasChanged = true;
      outer.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: modified,
        status: RCIMIWMessageModifyStatus.success,
      );

      final wrapped = ReferenceMessage.fromRaw(outer);
      expect(wrapped.referenceMessageStatus, ReferenceMessageStatus.deleted);

      wrapped.referenceMessageStatus = ReferenceMessageStatus.recalled;
      expect(outer.referMsgStatus, RCIMIWReferenceMessageStatus.recalled);
      expect(modified.referMsgStatus, RCIMIWReferenceMessageStatus.recalled);
    });

    test('writes text and extra to the successful edited content', () {
      final outer =
          RCIMIWTextMessage.fromJson({'text': 'old'})
            ..extra = 'old-extra'
            ..hasChanged = true;
      final modified = RCIMIWTextMessage.fromJson({'text': 'edited'})
        ..extra = 'edited-extra';
      outer.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: modified,
        status: RCIMIWMessageModifyStatus.success,
      );
      final message = TextMessage.fromRaw(outer);

      message.text = 'edited again';
      message.extra = null;

      expect(message.text, 'edited again');
      expect(message.extra, isNull);
      expect(modified.text, 'edited again');
      expect(modified.extra, isNull);
      expect(outer.text, 'old');
      expect(outer.extra, 'old-extra');

      final referenceOuter = RCIMIWReferenceMessage.fromJson({'text': 'old'})
        ..hasChanged = true;
      final referenceModified = RCIMIWReferenceMessage.fromJson({
        'text': 'edited',
      });
      referenceOuter.modifyInfo = RCIMIWMessageModifyInfo.create(
        content: referenceModified,
        status: RCIMIWMessageModifyStatus.success,
      );
      final reference = ReferenceMessage.fromRaw(referenceOuter)
        ..text = 'edited again';
      expect(reference.text, 'edited again');
      expect(referenceModified.text, 'edited again');
      expect(referenceOuter.text, 'old');
    });

    test('maps every SDK modification state explicitly', () {
      final cases = <RCIMIWMessageModifyStatus, MessageModifyStatus>{
        RCIMIWMessageModifyStatus.success: MessageModifyStatus.success,
        RCIMIWMessageModifyStatus.updating: MessageModifyStatus.updating,
        RCIMIWMessageModifyStatus.failed: MessageModifyStatus.failed,
      };

      for (final entry in cases.entries) {
        final raw = RCIMIWMessageModifyInfo.create(status: entry.key);
        expect(MessageModifyInfo.fromRaw(raw).status, entry.value);
      }

      expect(
        MessageModifyInfo.fromRaw(RCIMIWMessageModifyInfo.create()).status,
        isNull,
      );
    });

    test('content-only modification messages have no channel identifier', () {
      final outer = RCIMIWTextMessage.fromJson({
          'conversationType': RCIMIWConversationType.group.index,
          'targetId': 'team',
          'text': 'old',
        })
        ..modifyInfo = RCIMIWMessageModifyInfo.create(
          content: RCIMIWTextMessage.fromJson({'text': 'edited'}),
          status: RCIMIWMessageModifyStatus.success,
        );

      final content = TextMessage.fromRaw(outer).modifyInfo?.content;

      expect(content, isNotNull);
      expect(content?.channelIdentifier, isNull);
    });
  });

  group('5.44 channel conversion', () {
    test('preserves edited message drafts for every channel shape', () {
      final cases = <RCIMIWConversation>[
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.private,
          targetId: 'direct',
        ),
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.group,
          targetId: 'group',
        ),
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.chatroom,
          targetId: 'open',
        ),
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.ultraGroup,
          targetId: 'community',
        ),
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.ultraGroup,
          targetId: 'community',
          channelId: 'sub-channel',
        ),
        RCIMIWConversation.create(
          conversationType: RCIMIWConversationType.system,
          targetId: 'system',
        ),
      ];

      for (final raw in cases) {
        raw.editedMessageDraft = RCIMIWEditedMessageDraft.create(
          messageUId: 'message-${raw.targetId}-${raw.channelId}',
          content: '{"text":"draft"}',
        );
        final channel = Converter.toChannel(raw);

        expect(
          channel.editedMessageDraft?.messageId,
          raw.editedMessageDraft?.messageUId,
        );
        expect(
          channel.editedMessageDraft?.content,
          raw.editedMessageDraft?.content,
        );
        expect(channel.toJson()['editedMessageDraft'], {
          'messageId': raw.editedMessageDraft?.messageUId,
          'content': raw.editedMessageDraft?.content,
        });
      }
    });
  });

  group('message edit callback envelope', () {
    test(
      'falls back to the replacement on a successful null callback',
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        final previousPlatform = RCIMWrapperPlatform.instance;
        RCIMWrapperPlatform.instance = _ModifyMessagePlatform();
        addTearDown(() async {
          await NCEngine.destroy();
          RCIMWrapperPlatform.instance = previousPlatform;
        });
        await NCEngine.initialize(InitParams(appKey: 'test-app'));

        final original = TextMessage.fromRaw(
          RCIMIWTextMessage.fromJson({
            'conversationType': RCIMIWConversationType.group.index,
            'messageType': RCIMIWMessageType.text.index,
            'targetId': 'team',
            'messageId': 42,
            'messageUId': 'original-uid',
            'senderUserId': 'sender',
            'text': 'old',
          }),
        );
        final replacement = TextMessage.fromRaw(
          RCIMIWTextMessage.fromJson({
            'messageType': RCIMIWMessageType.text.index,
            'text': 'edited',
          }),
        );
        Message? result;
        NCError? error;

        final code = await BaseChannel(ChannelType.group, 'team').modifyMessage(
          ModifyMessageParams(
            messageId: 'original-uid',
            message: replacement,
            originalMessage: original,
          ),
          (value, valueError) {
            result = value;
            error = valueError;
          },
        );

        expect(code, 0);
        expect(error?.code, 0);
        expect(result, same(replacement));
        expect(result?.messageId, 'original-uid');
        expect(result?.clientId, 42);
        expect(result?.senderUserId, 'sender');
        expect((result as TextMessage).text, 'edited');
      },
    );

    test(
      'restores original identity without restoring cleared mentions',
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        final previousPlatform = RCIMWrapperPlatform.instance;
        final platform = _ModifyMessagePlatform();
        RCIMWrapperPlatform.instance = platform;
        addTearDown(() async {
          await NCEngine.destroy();
          RCIMWrapperPlatform.instance = previousPlatform;
        });
        await NCEngine.initialize(InitParams(appKey: 'test-app'));

        final originalRaw = RCIMIWTextMessage.fromJson({
          'conversationType': RCIMIWConversationType.group.index,
          'messageType': RCIMIWMessageType.text.index,
          'targetId': 'team',
          'channelId': 'thread',
          'messageId': 42,
          'messageUId': 'original-uid',
          'sentTime': 1000,
          'receivedTime': 1001,
          'senderUserId': 'sender',
          'direction': RCIMIWMessageDirection.send.index,
          'sentStatus': RCIMIWSentStatus.sent.index,
          'text': 'old',
          'mentionedInfo': {
            'type': RCIMIWMentionedType.part.index,
            'userIdList': ['old-user'],
          },
        });
        final replacementRaw = RCIMIWTextMessage.fromJson({
          'messageType': RCIMIWMessageType.text.index,
          'text': 'edited',
        });
        platform.callbackMessage = RCIMIWTextMessage.fromJson({
            'conversationType': RCIMIWConversationType.invalid.index,
            'messageType': RCIMIWMessageType.text.index,
            'targetId': 'wrong-target',
            'messageId': 99,
            'messageUId': 'wrong-uid',
            'text': 'edited',
            'hasChanged': true,
          })
          ..modifyInfo = RCIMIWMessageModifyInfo.create(
            content: RCIMIWTextMessage.fromJson({'text': 'edited'}),
            status: RCIMIWMessageModifyStatus.success,
          );

        Message? result;
        NCError? error;
        final code = await BaseChannel(ChannelType.group, 'team').modifyMessage(
          ModifyMessageParams(
            messageId: 'original-uid',
            message: TextMessage.fromRaw(replacementRaw),
            originalMessage: TextMessage.fromRaw(originalRaw),
          ),
          (value, valueError) {
            result = value;
            error = valueError;
          },
        );

        expect(code, 0);
        expect(error?.code, 0);
        expect(result, isA<TextMessage>());
        expect(result?.messageId, 'original-uid');
        expect(result?.clientId, 42);
        expect(result?.channelType, ChannelType.group);
        expect(result?.channelId, 'team');
        expect(result?.subChannelId, 'thread');
        expect(result?.sentTime, 1000);
        expect(result?.receivedTime, 1001);
        expect(result?.senderUserId, 'sender');
        expect(result?.direction, MessageDirection.send);
        expect(result?.sentStatus, SentStatus.sent);
        expect(result?.mentionedInfo, isNull);
        expect((result as TextMessage).text, 'edited');
      },
    );

    test('preserves reference terminal state in regular callbacks', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final previousPlatform = RCIMWrapperPlatform.instance;
      final callbackContent = RCIMIWReferenceMessage.fromJson({
        'messageType': RCIMIWMessageType.reference.index,
        'text': 'edited reply',
        'referMsgStatus': RCIMIWReferenceMessageStatus.defaultValue.index,
      });
      final callbackMessage = RCIMIWReferenceMessage.fromJson({
          'messageType': RCIMIWMessageType.reference.index,
          'text': 'edited reply',
          'referMsgStatus': RCIMIWReferenceMessageStatus.modified.index,
          'hasChanged': true,
        })
        ..modifyInfo = RCIMIWMessageModifyInfo.create(
          content: callbackContent,
          status: RCIMIWMessageModifyStatus.success,
        );
      final platform =
          _ModifyMessagePlatform()..callbackMessage = callbackMessage;
      RCIMWrapperPlatform.instance = platform;
      addTearDown(() async {
        await NCEngine.destroy();
        RCIMWrapperPlatform.instance = previousPlatform;
      });
      await NCEngine.initialize(InitParams(appKey: 'test-app'));

      final original = ReferenceMessage.fromRaw(
        RCIMIWReferenceMessage.fromJson({
          'conversationType': RCIMIWConversationType.group.index,
          'messageType': RCIMIWMessageType.reference.index,
          'targetId': 'team',
          'messageUId': 'reference-uid',
          'text': 'old reply',
          'referMsgStatus': RCIMIWReferenceMessageStatus.deleted.index,
        }),
      );
      final replacement = ReferenceMessage.fromRaw(
        RCIMIWReferenceMessage.fromJson({
          'messageType': RCIMIWMessageType.reference.index,
          'text': 'edited reply',
          'referMsgStatus': RCIMIWReferenceMessageStatus.defaultValue.index,
        }),
      );
      Message? result;

      final code = await BaseChannel(ChannelType.group, 'team').modifyMessage(
        ModifyMessageParams(
          messageId: 'reference-uid',
          message: replacement,
          originalMessage: original,
        ),
        (value, _) => result = value,
      );

      expect(code, 0);
      expect(result, isA<ReferenceMessage>());
      expect(
        (result as ReferenceMessage).referenceMessageStatus,
        ReferenceMessageStatus.deleted,
      );
      expect(
        callbackMessage.referMsgStatus,
        RCIMIWReferenceMessageStatus.deleted,
      );
      expect(
        callbackContent.referMsgStatus,
        RCIMIWReferenceMessageStatus.deleted,
      );
    });

    test('preserves reference terminal state in ultra groups', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final previousPlatform = RCIMWrapperPlatform.instance;
      final platform = _ModifyMessagePlatform();
      RCIMWrapperPlatform.instance = platform;
      addTearDown(() async {
        await NCEngine.destroy();
        RCIMWrapperPlatform.instance = previousPlatform;
      });
      await NCEngine.initialize(InitParams(appKey: 'test-app'));

      final original = ReferenceMessage.fromRaw(
        RCIMIWReferenceMessage.fromJson({
          'conversationType': RCIMIWConversationType.ultraGroup.index,
          'messageType': RCIMIWMessageType.reference.index,
          'targetId': 'community',
          'messageUId': 'reference-uid',
          'text': 'old reply',
          'referMsgStatus': RCIMIWReferenceMessageStatus.recalled.index,
        }),
      );
      final replacement = ReferenceMessage.fromRaw(
        RCIMIWReferenceMessage.fromJson({
          'messageType': RCIMIWMessageType.reference.index,
          'text': 'edited reply',
          'referMsgStatus': RCIMIWReferenceMessageStatus.defaultValue.index,
        }),
      );
      Message? result;

      final code = await BaseChannel(
        ChannelType.community,
        'community',
      ).modifyMessage(
        ModifyMessageParams(
          messageId: 'reference-uid',
          message: replacement,
          originalMessage: original,
        ),
        (value, _) => result = value,
      );

      expect(code, 0);
      expect(result, same(replacement));
      expect(
        (result as ReferenceMessage).referenceMessageStatus,
        ReferenceMessageStatus.recalled,
      );
    });
  });

  group('5.44 read receipt completion', () {
    test('delivers synchronous engine failures exactly once', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final previousPlatform = RCIMWrapperPlatform.instance;
      final platform = _ModifyMessagePlatform()..readReceiptCode = 500;
      RCIMWrapperPlatform.instance = platform;
      addTearDown(() async {
        await NCEngine.destroy();
        RCIMWrapperPlatform.instance = previousPlatform;
      });
      await NCEngine.initialize(InitParams(appKey: 'test-app'));
      final channel = BaseChannel(ChannelType.group, 'team');
      final callbackCodes = <int?>[];

      final sendCode = await channel.sendReadReceiptResponse(const [
        'message-1',
      ], (error) => callbackCodes.add(error?.code));
      final infoCode = await channel.getMessageReadReceiptInfo(const [
        'message-1',
      ], (_, error) => callbackCodes.add(error?.code));
      final identifierCode =
          await BaseChannel.getMessageReadReceiptInfoByIdentifiers([
            MessageIdentifier(
              channelType: ChannelType.group,
              channelId: 'team',
              messageId: 'message-1',
            ),
          ], (_, error) => callbackCodes.add(error?.code));
      final usersCode = await channel.getMessagesReadReceiptByUsers(
        GetMessagesReadReceiptByUsersParams(
          messageId: 'message-1',
          userIds: const ['user-1'],
        ),
        (_, error) => callbackCodes.add(error?.code),
      );

      expect(
        [sendCode, infoCode, identifierCode, usersCode],
        [500, 500, 500, 500],
      );
      expect(callbackCodes, [500, 500, 500, 500]);
    });

    test(
      'does not request the first page again after pagination ends',
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        final previousPlatform = RCIMWrapperPlatform.instance;
        final platform =
            _ModifyMessagePlatform()
              ..pagedResult = RCIMIWReadReceiptUsersResult.fromJson({
                'pageToken': null,
                'totalCount': 1,
                'users': [
                  {'userId': 'user-1', 'timestamp': 1, 'isMentioned': false},
                ],
              });
        RCIMWrapperPlatform.instance = platform;
        addTearDown(() async {
          await NCEngine.destroy();
          RCIMWrapperPlatform.instance = previousPlatform;
        });
        await NCEngine.initialize(InitParams(appKey: 'test-app'));
        final query = MessagesReadReceiptUsersQuery(
          MessagesReadReceiptUsersQueryParams(
            channelIdentifier: ChannelIdentifier(
              channelType: ChannelType.group,
              channelId: 'team',
            ),
            messageId: 'message-1',
          ),
        );
        final pages = <PageResult<MessageReadReceiptUser>>[];

        await query.loadNextPage((page, error) {
          expect(error, isNull);
          if (page != null) pages.add(page);
        });
        await query.loadNextPage((page, error) {
          expect(error, isNull);
          if (page != null) pages.add(page);
        });

        expect(query.hasMore, isFalse);
        expect(platform.pagedCallCount, 1);
        expect(pages, hasLength(2));
        expect(pages.first.data.single.userId, 'user-1');
        expect(pages.last.data, isEmpty);
      },
    );

    test('retains the first non-null total count across later pages', () async {
      WidgetsFlutterBinding.ensureInitialized();
      final previousPlatform = RCIMWrapperPlatform.instance;
      final platform =
          _ModifyMessagePlatform()
            ..pagedResults.addAll([
              RCIMIWReadReceiptUsersResult.fromJson({
                'pageToken': 'next-page',
                'totalCount': 3,
                'users': [
                  {'userId': 'user-1', 'timestamp': 1},
                ],
              }),
              RCIMIWReadReceiptUsersResult.fromJson({
                'pageToken': null,
                'users': [
                  {'userId': 'user-2', 'timestamp': 2},
                ],
              }),
            ]);
      RCIMWrapperPlatform.instance = platform;
      addTearDown(() async {
        await NCEngine.destroy();
        RCIMWrapperPlatform.instance = previousPlatform;
      });
      await NCEngine.initialize(InitParams(appKey: 'test-app'));
      final query = MessagesReadReceiptUsersQuery(
        MessagesReadReceiptUsersQueryParams(
          channelIdentifier: ChannelIdentifier(
            channelType: ChannelType.group,
            channelId: 'team',
          ),
          messageId: 'message-1',
        ),
      );
      final pages = <PageResult<MessageReadReceiptUser>>[];

      await query.loadNextPage((page, error) {
        expect(error, isNull);
        if (page != null) pages.add(page);
      });
      await query.loadNextPage((page, error) {
        expect(error, isNull);
        if (page != null) pages.add(page);
      });

      expect(pages.map((page) => page.totalCount), [3, 3]);
      expect(pages.map((page) => page.data.single.userId), [
        'user-1',
        'user-2',
      ]);
      expect(query.hasMore, isFalse);
      expect(platform.pagedCallCount, 2);
    });

    test(
      'keeps bridge exceptions on the future and releases the query state',
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        final previousPlatform = RCIMWrapperPlatform.instance;
        final platform =
            _ModifyMessagePlatform()
              ..pagedError = StateError('bridge unavailable');
        RCIMWrapperPlatform.instance = platform;
        addTearDown(() async {
          await NCEngine.destroy();
          RCIMWrapperPlatform.instance = previousPlatform;
        });
        await NCEngine.initialize(InitParams(appKey: 'test-app'));
        final query = MessagesReadReceiptUsersQuery(
          MessagesReadReceiptUsersQueryParams(
            channelIdentifier: ChannelIdentifier(
              channelType: ChannelType.group,
              channelId: 'team',
            ),
            messageId: 'message-1',
          ),
        );
        var handlerCalls = 0;

        await expectLater(
          query.loadNextPage((_, __) => handlerCalls++),
          throwsA(isA<StateError>()),
        );
        expect(handlerCalls, 0);

        platform
          ..pagedError = null
          ..pagedResult = RCIMIWReadReceiptUsersResult.fromJson({
            'pageToken': null,
            'totalCount': 1,
            'users': [
              {'userId': 'user-1', 'timestamp': 1},
            ],
          });
        PageResult<MessageReadReceiptUser>? page;
        await query.loadNextPage((value, error) {
          handlerCalls++;
          expect(error, isNull);
          page = value;
        });

        expect(platform.pagedCallCount, 2);
        expect(handlerCalls, 1);
        expect(page?.data.single.userId, 'user-1');
      },
    );
  });

  group('read receipt model compatibility', () {
    test(
      'allows the local sent-receipt state to be updated after reporting',
      () {
        final message = Message.wrap(
          RCIMIWMessage.fromJson({'sentReceipt': false}),
        );

        message.sentReceipt = true;

        expect(message.sentReceipt, isTrue);
        expect(message.raw.sentReceipt, isTrue);
      },
    );

    test('retains the const value-object constructor and raw conversion', () {
      const user = MessageReadReceiptUser(
        userId: 'user-1',
        timestamp: 123,
        isMentioned: true,
      );
      expect(user.userId, 'user-1');
      expect(user.timestamp, 123);
      expect(user.isMentioned, isTrue);

      final converted = MessageReadReceiptUser.fromRaw(user.raw);
      expect(converted.userId, user.userId);
      expect(converted.timestamp, user.timestamp);
      expect(converted.isMentioned, isTrue);
    });

    test('rejects invalid read receipt response channel identities', () {
      final invalid = MessageReadReceiptResponse.fromRaw(
        RCIMIWReadReceiptResponseV5.fromJson({
          'conversationType': RCIMIWConversationType.invalid.index,
          'targetId': 'target',
        }),
      );
      final missingTarget = MessageReadReceiptResponse.fromRaw(
        RCIMIWReadReceiptResponseV5.fromJson({
          'conversationType': RCIMIWConversationType.group.index,
          'targetId': '',
        }),
      );

      expect(invalid.channelIdentifier, isNull);
      expect(missingTarget.channelIdentifier, isNull);
    });

    test('maps every SDK read-receipt version explicitly', () {
      final cases = <RCIMIWGroupReadReceiptVersion, ReadReceiptVersion>{
        RCIMIWGroupReadReceiptVersion.unknown: ReadReceiptVersion.unknown,
        RCIMIWGroupReadReceiptVersion.version1: ReadReceiptVersion.version1,
        RCIMIWGroupReadReceiptVersion.version2: ReadReceiptVersion.version2,
        RCIMIWGroupReadReceiptVersion.version4: ReadReceiptVersion.version4,
        RCIMIWGroupReadReceiptVersion.version5: ReadReceiptVersion.version5,
      };

      for (final entry in cases.entries) {
        final settings = AppSettings.fromRaw(
          RCIMIWAppSettings.fromJson({'readReceiptVersion': entry.key.index}),
        );
        expect(settings.readReceiptVersion, entry.value);
      }

      expect(
        AppSettings.fromRaw(RCIMIWAppSettings.fromJson({})).readReceiptVersion,
        isNull,
      );
      expect(
        AppSettings.fromRaw(
          RCIMIWAppSettings.fromJson({'readReceiptVersion': 999}),
        ).readReceiptVersion,
        ReadReceiptVersion.unknown,
      );
    });

    test('maps read and unread query options without enum ordinals', () {
      expect(
        MessageReadReceiptUsersOption(
          readStatus: MessageReadReceiptStatus.read,
        ).toRaw().readStatus,
        RCIMIWReadReceiptStatus.read,
      );
      expect(
        MessageReadReceiptUsersOption(
          readStatus: MessageReadReceiptStatus.unread,
        ).toRaw().readStatus,
        RCIMIWReadReceiptStatus.unread,
      );
      expect(MessageReadReceiptUsersOption().toRaw().readStatus, isNull);
    });
  });

  test('appends new information message type without shifting combine', () {
    expect(MessageType.combine.index, 15);
    expect(MessageType.informationNotification.index, 16);
  });

  group('5.44 read receipt request limits', () {
    final channel = BaseChannel(ChannelType.direct, 'target');
    List<String> ids(int count) => List<String>.generate(count, (i) => 'm-$i');

    test(
      'rejects an invalid paged user count before touching the engine',
      () async {
        final query = BaseChannel.createMessagesReadReceiptUsersQuery(
          MessagesReadReceiptUsersQueryParams(
            channelIdentifier: channel.channelIdentifier,
            messageId: 'message-1',
            pageSize: 101,
          ),
        );
        NCError? error;
        final code = await query.loadNextPage((_, value) => error = value);

        expect(code, 34232);
        expect(error?.code, 34232);
      },
    );

    test('rejects oversized read receipt batches', () async {
      final oversized = ids(101);
      NCError? sendError;
      NCError? infoError;
      NCError? identifierError;
      NCError? userError;
      NCError? refreshError;

      final sendCode = await channel.sendReadReceiptResponse(
        oversized,
        (value) => sendError = value,
      );
      final infoCode = await channel.getMessageReadReceiptInfo(
        oversized,
        (_, value) => infoError = value,
      );
      final identifierCode =
          await BaseChannel.getMessageReadReceiptInfoByIdentifiers(
            oversized
                .map(
                  (messageId) => MessageIdentifier(
                    channelType: ChannelType.direct,
                    channelId: 'target',
                    messageId: messageId,
                  ),
                )
                .toList(),
            (_, value) => identifierError = value,
          );
      final userCode = await channel.getMessagesReadReceiptByUsers(
        GetMessagesReadReceiptByUsersParams(
          messageId: 'message-1',
          userIds: ids(101),
        ),
        (_, value) => userError = value,
      );
      final refreshCode = await channel.refreshReferenceMessages(
        ids(21),
        RefreshReferenceMessagesCallback(
          onError: (value) => refreshError = value,
        ),
      );

      expect(sendCode, 34232);
      expect(infoCode, 34232);
      expect(identifierCode, 34232);
      expect(userCode, 34232);
      expect(refreshCode, 34232);
      expect(sendError?.code, 34232);
      expect(infoError?.code, 34232);
      expect(identifierError?.code, 34232);
      expect(userError?.code, 34232);
      expect(refreshError?.code, 34232);
    });
  });

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

  test(
    'reinitializing destroys the previous engine before creating another',
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final previousPlatform = RCIMWrapperPlatform.instance;
      final platform = _ModifyMessagePlatform();
      RCIMWrapperPlatform.instance = platform;
      addTearDown(() async {
        await NCEngine.destroy();
        RCIMWrapperPlatform.instance = previousPlatform;
      });

      await NCEngine.initialize(InitParams(appKey: 'first-app'));
      await NCEngine.initialize(InitParams(appKey: 'second-app'));

      expect(platform.createCount, 2);
      expect(platform.destroyCount, 1);
    },
  );
}

class _ModifyMessagePlatform extends RCIMWrapperPlatform {
  RCIMIWMessage? callbackMessage;
  int readReceiptCode = 0;
  RCIMIWReadReceiptUsersResult? pagedResult;
  final List<RCIMIWReadReceiptUsersResult?> pagedResults = [];
  Object? pagedError;
  int pagedCallCount = 0;
  int createCount = 0;
  int destroyCount = 0;

  @override
  Future<void> create(String appKey, RCIMIWEngineOptions options) async {
    createCount++;
  }

  @override
  Future<void> destroy() async {
    destroyCount++;
  }

  @override
  Future<int> modifyMessageWithParams(
    RCIMIWModifyMessageParams params, {
    IRCIMIWModifyMessageCallback? callback,
  }) async {
    callback?.onMessageModified(0, callbackMessage);
    return 0;
  }

  @override
  Future<int> modifyUltraGroupMessage(
    String messageUId,
    RCIMIWMessage message, {
    IRCIMIWModifyUltraGroupMessageCallback? callback,
  }) async {
    callback?.onUltraGroupMessageModified(0);
    return 0;
  }

  @override
  Future<int> sendReadReceiptResponseV5(
    RCIMIWConversationType type,
    String targetId,
    String? channelId,
    List<String> messageUIds, {
    IRCIMIWSendReadReceiptResponseV5Callback? callback,
  }) async => readReceiptCode;

  @override
  Future<int> getMessageReadReceiptInfoV5(
    RCIMIWConversationType type,
    String targetId,
    String? channelId,
    List<String> messageUIds, {
    IRCIMIWGetMessageReadReceiptInfoV5Callback? callback,
  }) async => readReceiptCode;

  @override
  Future<int> getMessageReadReceiptInfoV5ByIdentifiers(
    List<RCIMIWMessageIdentifier> identifiers, {
    IRCIMIWGetMessageReadReceiptInfoV5Callback? callback,
  }) async => readReceiptCode;

  @override
  Future<int> getMessagesReadReceiptByUsersV5(
    RCIMIWConversationType type,
    String targetId,
    String? channelId,
    String messageUId,
    List<String> userIds, {
    IRCIMIWGetMessagesReadReceiptByUsersV5Callback? callback,
  }) async => readReceiptCode;

  @override
  Future<int> getMessagesReadReceiptUsersByPageV5(
    RCIMIWConversationType type,
    String targetId,
    String? channelId,
    String messageUId,
    RCIMIWReadReceiptUsersOption option, {
    IRCIMIWGetMessagesReadReceiptUsersByPageV5Callback? callback,
  }) async {
    pagedCallCount++;
    final error = pagedError;
    if (error != null) throw error;
    callback?.onSuccess(
      pagedResults.isEmpty ? pagedResult : pagedResults.removeAt(0),
    );
    return 0;
  }
}
