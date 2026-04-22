import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Detailed received status information for a message in the Nexconn IM SDK.
///
/// Provides granular flags indicating whether a message has been read, listened to (for voice messages), downloaded (for media messages), or retrieved from the server.
class ReceivedStatusInfo {
  final RCIMIWReceivedStatusInfo _raw;

  ReceivedStatusInfo._(this._raw);

  /// Creates a [ReceivedStatusInfo] from an existing SDK object.
  static ReceivedStatusInfo fromRaw(RCIMIWReceivedStatusInfo raw) =>
      ReceivedStatusInfo._(raw);

  /// Whether the message has been read by the receiver.
  bool? get read => _raw.read;

  /// Whether the voice message has been listened to.
  bool? get listened => _raw.listened;

  /// Whether the media content has been downloaded.
  bool? get downloaded => _raw.downloaded;

  /// Whether the message has been retrieved from the server.
  bool? get retrieved => _raw.retrieved;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'read': read,
    'listened': listened,
    'downloaded': downloaded,
    'retrieved': retrieved,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWReceivedStatusInfo get raw => _raw;
}
