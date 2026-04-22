import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../internal/converter.dart';
import '../channel/base_channel.dart';

/// Represents a single result from a channel search.
///
/// Contains the matched channel and the number of matching messages.
class SearchChannelResult {
  final RCIMIWSearchConversationResult _raw;
  SearchChannelResult._(this._raw);

  /// Creates a [SearchChannelResult] from an existing SDK object.
  static SearchChannelResult fromRaw(RCIMIWSearchConversationResult raw) =>
      SearchChannelResult._(raw);

  /// The channel that matched the search query.
  BaseChannel? get channel =>
      _raw.conversation != null
          ? Converter.toChannel(_raw.conversation!)
          : null;

  /// The number of messages matching the search criteria in this channel.
  int? get count => _raw.count;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'count': count,
    'channel': channel?.toJson(),
  };

  /// The associated SDK object for advanced usage.
  RCIMIWSearchConversationResult get raw => _raw;
}
