import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating an [ImageMessage].
class ImageMessageParams extends MessageParams {
  /// The local file path of the image to send.
  final String path;

  /// Creates [ImageMessageParams] with the required image [path].
  ImageMessageParams({
    required this.path,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// An image message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] with image-specific properties such as thumbnail data, original flag, and thumbnail dimensions.
class ImageMessage extends MediaMessage {
  /// Creates an [ImageMessage] by wrapping a raw message object.
  ImageMessage.wrap(super.raw) : super.wrap();

  /// Creates a [ImageMessage] from an existing SDK object.
  static ImageMessage fromRaw(RCIMIWImageMessage raw) => ImageMessage.wrap(raw);

  RCIMIWImageMessage get _imageRaw => raw as RCIMIWImageMessage;

  /// The Base64-encoded thumbnail image string.
  String? get thumbnailBase64String => _imageRaw.thumbnailBase64String;

  /// Whether this image should be sent as the original (full quality) version.
  bool? get original => _imageRaw.original;

  /// Sets whether this image should be sent as the original (full quality) version.
  set original(bool? v) => _imageRaw.original = v;

  /// The width of the thumbnail image in pixels.
  int? get thumWidth => _imageRaw.thumWidth;

  /// The height of the thumbnail image in pixels.
  int? get thumHeight => _imageRaw.thumHeight;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'thumbnailBase64String': thumbnailBase64String,
    'original': original,
    'thumWidth': thumWidth,
    'thumHeight': thumHeight,
  };
}
