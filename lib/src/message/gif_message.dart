import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [GIFMessage].
class GIFMessageParams extends MessageParams {
  /// The local file path of the GIF image.
  final String path;

  /// Creates [GIFMessageParams] with the required GIF [path].
  GIFMessageParams({
    required this.path,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A GIF image message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] with GIF-specific properties such as data size and image dimensions.
class GIFMessage extends MediaMessage {
  /// Creates a [GIFMessage] by wrapping a raw message object.
  GIFMessage.wrap(super.raw) : super.wrap();

  /// Creates a [GIFMessage] from an existing SDK object.
  static GIFMessage fromRaw(RCIMIWGIFMessage raw) => GIFMessage.wrap(raw);

  RCIMIWGIFMessage get _gifRaw => raw as RCIMIWGIFMessage;

  /// The data size of the GIF file in bytes.
  int? get dataSize => _gifRaw.dataSize;

  /// The width of the GIF image in pixels.
  int? get width => _gifRaw.width;

  /// The height of the GIF image in pixels.
  int? get height => _gifRaw.height;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'dataSize': dataSize,
    'width': width,
    'height': height,
  };
}
