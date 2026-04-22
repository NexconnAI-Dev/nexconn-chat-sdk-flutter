import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import '../enum/channel_type.dart';
import '../internal/converter.dart';
import '../model/combine_msg_info.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [CombineMessage].
class CombineMessageParams extends MessageParams {
  /// The channel type of the source channel where messages are forwarded from.
  final ChannelType sourceChannelType;

  /// A list of summary text lines displayed in the combined message preview.
  final List<String> summaryList;

  /// A list of sender display names for the combined messages.
  final List<String> nameList;

  /// The list of individual message info objects to be combined.
  final List<CombineMessageInfo> msgList;

  /// Creates [CombineMessageParams] with the required source type, summaries, names, and message list.
  CombineMessageParams({
    required this.sourceChannelType,
    required this.summaryList,
    required this.nameList,
    required this.msgList,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A combined (forwarded) message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] to represent multiple messages bundled together, typically used for forwarding chat history as a single message.
class CombineMessage extends MediaMessage {
  /// Creates a [CombineMessage] by wrapping a raw message object.
  CombineMessage.wrap(super.raw) : super.wrap();

  /// Creates a [CombineMessage] from an existing SDK object.
  static CombineMessage fromRaw(RCIMIWCombineV2Message raw) =>
      CombineMessage.wrap(raw);

  RCIMIWCombineV2Message get _combineRaw => raw as RCIMIWCombineV2Message;

  /// The channel type of the source channel where the messages originated.
  int? get combineConversationType => _combineRaw.combineConversationType;

  /// The source channel type where the combined messages originated.
  ChannelType? get sourceChannelType =>
      combineConversationType != null
          ? Converter.fromRCConversationType(
            RCIMIWConversationType.values[combineConversationType!],
          )
          : null;

  /// The list of summary text lines for the combined message preview.
  List<String>? get summaryList => _combineRaw.summaryList;

  /// The list of sender display names included in the combined message.
  List<String>? get nameList => _combineRaw.nameList;

  /// The total number of messages contained in this combined message.
  int? get msgNum => _combineRaw.msgNum;

  /// The list of individual message info objects contained in this combined message.
  List<CombineMessageInfo>? get msgList =>
      _combineRaw.msgList?.map(CombineMessageInfo.fromRaw).toList();

  /// The key used to retrieve the full JSON content of the combined messages.
  String? get jsonMsgKey => _combineRaw.jsonMsgKey;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'sourceChannelType': sourceChannelType?.name,
    'summaryList': summaryList,
    'nameList': nameList,
    'msgNum': msgNum,
    'msgList':
        msgList
            ?.map(
              (e) => {
                'fromUserId': e.fromUserId,
                'channelId': e.channelId,
                'timestamp': e.timestamp,
                'objectName': e.objectName,
                'content': e.content,
              },
            )
            .toList(),
    'jsonMsgKey': jsonMsgKey,
  };
}
