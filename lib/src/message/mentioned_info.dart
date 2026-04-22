import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/mentioned_type.dart';

/// Parameters for attaching @mention information to an outgoing message.
class MentionedInfoParams {
  /// The type of mention.
  final MentionedType type;

  /// The list of mentioned user IDs. Required when mentioning specific users.
  final List<String>? userIdList;

  /// Optional content used for local notifications and push display.
  final String? mentionedContent;

  const MentionedInfoParams({
    required this.type,
    this.userIdList,
    this.mentionedContent,
  });

  /// Converts this object to the SDK data object.
  RCIMIWMentionedInfo toRaw() => RCIMIWMentionedInfo.create(
    type: RCIMIWMentionedType.values[type.index],
    userIdList: userIdList,
    mentionedContent: mentionedContent,
  );

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'userIdList': userIdList,
    'mentionedContent': mentionedContent,
  };
}

/// Contains resolved @mention information on a received or loaded message.
///
/// When a message includes @mentions, this class holds the mention type, the list of mentioned user IDs, and optional custom mention content.
class MentionedInfo {
  final RCIMIWMentionedInfo _raw;

  MentionedInfo._(this._raw);

  /// Creates a [MentionedInfo] from an existing SDK object.
  static MentionedInfo fromRaw(RCIMIWMentionedInfo raw) => MentionedInfo._(raw);

  /// The type of mention (e.g., mention all members, or mention specific users).
  MentionedType? get type =>
      _raw.type != null ? MentionedType.values[_raw.type!.index] : null;

  /// The list of user IDs that are mentioned in the message.
  /// Only applicable when [type] is not "mention all".
  List<String>? get userIdList => _raw.userIdList;

  /// The custom display content for the @mention push notification.
  String? get mentionedContent => _raw.mentionedContent;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'type': type?.name,
    'userIdList': userIdList,
    'mentionedContent': mentionedContent,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWMentionedInfo get raw => _raw;
}
