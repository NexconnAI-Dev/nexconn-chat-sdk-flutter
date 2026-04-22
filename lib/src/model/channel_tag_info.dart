import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'tag.dart';

/// Represents the association between a channel and a tag.
///
/// Contains the tag information and whether the channel is pinned
/// to the top within that tag.
class ChannelTagInfo {
  final RCIMIWConversationTagInfo _raw;
  ChannelTagInfo._(this._raw);

  /// Creates a [ChannelTagInfo] from an existing SDK object.
  static ChannelTagInfo fromRaw(RCIMIWConversationTagInfo raw) =>
      ChannelTagInfo._(raw);

  /// The tag associated with the channel.
  Tag? get tagInfo => _raw.tagInfo != null ? Tag.fromRaw(_raw.tagInfo!) : null;

  /// Whether the channel is pinned to the top within this tag.
  bool? get top => _raw.top;

  /// The associated SDK object for advanced usage.
  RCIMIWConversationTagInfo get raw => _raw;
}
