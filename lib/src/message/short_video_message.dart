import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [ShortVideoMessage].
class ShortVideoMessageParams extends MessageParams {
  /// The local file path of the short video.
  final String path;

  /// The duration of the short video in seconds.
  final int duration;

  /// Creates [ShortVideoMessageParams] with the required video [path] and [duration].
  ShortVideoMessageParams({
    required this.path,
    required this.duration,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A short video (sight) message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] with video-specific properties such as duration, file size, name, and thumbnail data.
class ShortVideoMessage extends MediaMessage {
  /// Creates a [ShortVideoMessage] by wrapping a raw message object.
  ShortVideoMessage.wrap(super.raw) : super.wrap();

  /// Creates a [ShortVideoMessage] from an existing SDK object.
  static ShortVideoMessage fromRaw(RCIMIWSightMessage raw) =>
      ShortVideoMessage.wrap(raw);

  RCIMIWSightMessage get _sightRaw => raw as RCIMIWSightMessage;

  /// The duration of the short video in seconds.
  int? get duration => _sightRaw.duration;

  /// The file size of the short video in bytes.
  int? get size => _sightRaw.size;

  /// The file name of the short video.
  String? get name => _sightRaw.name;

  /// The Base64-encoded thumbnail image string for the video preview.
  String? get thumbnailBase64String => _sightRaw.thumbnailBase64String;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'duration': duration,
    'size': size,
    'name': name,
    'thumbnailBase64String': thumbnailBase64String,
  };
}
