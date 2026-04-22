import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// Configuration options for image compression.
///
/// Controls the quality and size limits for both original images and their thumbnails during message sending.
class CompressOptions {
  /// The quality factor for original images (0-100).
  final int? originalImageQuality;

  /// The target file size for original images (in KB).
  final int? originalImageSize;

  /// The maximum allowed file size for original images (in KB).
  final int? originalImageMaxSize;

  /// The quality factor for thumbnail images (0-100).
  final int? thumbnailQuality;

  /// The maximum allowed file size for thumbnails (in KB).
  final int? thumbnailMaxSize;

  /// Creates [CompressOptions] with optional compression settings.
  CompressOptions({
    this.originalImageQuality,
    this.originalImageSize,
    this.originalImageMaxSize,
    this.thumbnailQuality,
    this.thumbnailMaxSize,
  });

  /// Converts this object to the SDK data object.
  RCIMIWCompressOptions toRaw() {
    return RCIMIWCompressOptions.create(
      originalImageQuality: originalImageQuality,
      originalImageSize: originalImageSize,
      originalImageMaxSize: originalImageMaxSize,
      thumbnailQuality: thumbnailQuality,
      thumbnailMaxSize: thumbnailMaxSize,
    );
  }
}

/// Configuration options for enabling vendor-specific push services.
class PushOptions {
  /// Whether to enable Huawei push service.
  final bool? enableHWPush;

  /// Whether to enable Firebase Cloud Messaging (FCM).
  final bool? enableFCM;

  /// Creates [PushOptions] with optional push service flags.
  PushOptions({this.enableHWPush, this.enableFCM});

  /// Converts this object to the SDK data object.
  RCIMIWPushOptions toRaw() {
    return RCIMIWPushOptions.create(
      enableHWPush: enableHWPush,
      enableFCM: enableFCM,
    );
  }
}
