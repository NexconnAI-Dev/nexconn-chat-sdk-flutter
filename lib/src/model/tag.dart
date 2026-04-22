import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Parameters for creating a new tag.
class CreateTagParams {
  /// The unique identifier for the tag.
  final String tagId;

  /// The display name of the tag.
  final String tagName;

  /// Creates [CreateTagParams] with the required [tagId] and [tagName].
  CreateTagParams({required this.tagId, required this.tagName});
}

/// Parameters for changing the pin/top status of a channel within a tag.
class ChangeChannelTopStatusInTagParams {
  /// The tag identifier.
  final String tagId;

  /// The channel type (e.g., private, group).
  final ChannelType type;

  /// The channel identifier.
  final String channelId;

  /// Whether to pin the channel to the top within the tag.
  final bool top;

  /// Creates [ChangeChannelTopStatusInTagParams].
  ChangeChannelTopStatusInTagParams({
    required this.tagId,
    required this.type,
    required this.channelId,
    required this.top,
  });
}

/// Represents a tag used to label and categorize channels.
///
/// Tags allow users to organize their channels into custom groups, manage unread counts per tag, and pin channels within tags.
class Tag {
  /// Creates a new tag on the server.
  ///
  /// After creation, retrieves the full tag info and returns it via [handler].
  Future<int> createTag(CreateTagParams params, OperationHandler<Tag> handler) {
    return NCEngine.engine.createTag(
      params.tagId,
      params.tagName,
      callback: IRCIMIWCreateTagCallback(
        onTagCreated: (code) {
          if (code != 0) {
            handler(null, Converter.toNCError(code));
            return;
          }
          Tag.getTag(params.tagId, handler);
        },
      ),
    );
  }

  /// Deletes this tag from the server.
  ///
  /// Invokes [handler] with an error if the operation fails.
  Future<int> delete(ErrorHandler handler) {
    return NCEngine.engine.removeTag(
      tagId ?? '',
      callback: IRCIMIWRemoveTagCallback(
        onTagRemoved: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Updates this tag's name on the server.
  ///
  /// Invokes [handler] with an error if the operation fails.
  Future<int> update(String tagName, ErrorHandler handler) {
    return NCEngine.engine.updateTagNameById(
      tagId ?? '',
      tagName,
      callback: IRCIMIWUpdateTagNameByIdCallback(
        onTagNameByIdUpdated: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves all tags from the server.
  ///
  /// Returns the list of [Tag] objects via [handler], or an error on failure.
  static Future<int> getTags(OperationHandler<List<Tag>> handler) {
    return NCEngine.engine.getTags(
      callback: IRCIMIWGetTagsCallback(
        onSuccess: (t) => handler(t?.map((e) => Tag.fromRaw(e)).toList(), null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves a single tag by [tagId] from the server.
  static Future<int> getTag(String tagId, OperationHandler<Tag> handler) {
    return NCEngine.engine.getTags(
      callback: IRCIMIWGetTagsCallback(
        onSuccess: (tags) {
          final match = tags?.cast<RCIMIWTagInfo?>().firstWhere(
            (t) => t?.tagId == tagId,
            orElse: () => null,
          );
          if (match != null) {
            handler(Tag.fromRaw(match), null);
          } else {
            handler(null, NCError(code: -1));
          }
        },
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Adds a single channel to this tag.
  ///
  /// Flutter currently exposes tag membership changes as single-item operations instead of batch APIs.
  Future<int> addChannel(ChannelIdentifier identifier, ErrorHandler handler) {
    return NCEngine.engine.addConversationToTag(
      tagId ?? '',
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      callback: IRCIMIWAddConversationToTagCallback(
        onConversationToTagAdded: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Removes a single channel from this tag.
  ///
  /// Flutter currently exposes tag membership changes as single-item operations instead of batch APIs.
  Future<int> deleteChannelFromTag(
    ChannelIdentifier identifier,
    ErrorHandler handler,
  ) {
    return NCEngine.engine.removeConversationFromTag(
      tagId ?? '',
      Converter.toRCConversationType(identifier.channelType),
      identifier.channelId,
      callback: IRCIMIWRemoveConversationFromTagCallback(
        onConversationFromTagRemoved:
            (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Clears all channels under this tag.
  ///
  /// When [isDeleteMessage] is `true`, local messages in those channels are
  /// deleted as well.
  Future<int> clearChannels(bool isDeleteMessage, ErrorHandler handler) {
    return NCEngine.engine.clearConversationsByTag(
      tagId ?? '',
      isDeleteMessage,
      callback: IRCIMIWClearConversationsByTagCallback(
        onSuccess: (t) => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Gets the total unread message count for all channels under this tag.
  ///
  /// [containNoDisturb] controls whether channels with Do Not Disturb
  /// enabled are included in the count.
  Future<int> getUnreadCount(
    bool containNoDisturb,
    OperationHandler<int> handler,
  ) {
    return NCEngine.engine.getUnreadCountByTag(
      tagId ?? '',
      containNoDisturb,
      callback: IRCIMIWGetUnreadCountCallback(
        onSuccess: (t) => handler(t, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Creates a query object for paginated retrieval of channels under this tag.
  TagChannelsQuery createTagChannelsQuery(TagChannelsQueryParams params) {
    return TagChannelsQuery(params);
  }

  /// Clears the unread count for all messages under this tag.
  /// Clears unread counts for all channels associated with this tag.
  Future<int> clearUnreadCount(ErrorHandler handler) {
    return NCEngine.engine.clearMessagesUnreadStatusByTag(
      tagId ?? '',
      callback: IRCIMIWClearMessagesUnreadStatusByTagCallback(
        onSuccess: (t) => handler(Converter.toNCError(0)),
        onError: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// The associated SDK object for advanced usage.
  final RCIMIWTagInfo _raw;

  Tag._(this._raw);

  /// Creates an empty [Tag] with default values.
  Tag() : _raw = RCIMIWTagInfo.create();

  /// Creates a [Tag] from an existing SDK object.
  static Tag fromRaw(RCIMIWTagInfo raw) => Tag._(raw);

  /// The unique identifier of this tag.
  String? get tagId => _raw.tagId;

  /// The display name of this tag.
  String? get tagName => _raw.tagName;

  /// The number of channels associated with this tag.
  int? get channelCount => _raw.count;

  /// The creation timestamp of this tag (in milliseconds).
  int? get createTime => _raw.timestamp;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'tagId': tagId,
    'tagName': tagName,
    'channelCount': channelCount,
    'createTime': createTime,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWTagInfo get raw => _raw;
}
