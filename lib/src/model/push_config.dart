import '../enum/vivo_push_type.dart';
import '../enum/huawei_push_importance.dart';
import '../enum/honor_push_importance.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// iOS-specific push notification options.
class IOSPushOptions {
  /// The thread identifier for grouping notifications.
  final String? threadId;

  /// The notification category for actionable notifications.
  final String? category;

  /// The collapse identifier to coalesce multiple notifications.
  final String? apnsCollapseId;

  /// The URI for rich media content attached to the notification.
  final String? richMediaUri;

  /// The interruption level for the notification (e.g., active, passive).
  final String? interruptionLevel;

  /// Creates [IOSPushOptions] with optional iOS-specific settings.
  IOSPushOptions({
    this.threadId,
    this.category,
    this.apnsCollapseId,
    this.richMediaUri,
    this.interruptionLevel,
  });

  /// Converts this object to the SDK data object.
  RCIMIWIOSPushOptions toRaw() {
    return RCIMIWIOSPushOptions.create(
      threadId: threadId,
      category: category,
      apnsCollapseId: apnsCollapseId,
      richMediaUri: richMediaUri,
      interruptionLevel: interruptionLevel,
    );
  }
}

/// Android-specific push notification options for various vendor channels.
class AndroidPushOptions {
  /// Custom notification ID for the push message.
  final String? notificationId;

  /// Xiaomi push channel ID.
  final String? channelIdMi;

  /// Huawei push channel ID.
  final String? channelIdHW;

  /// Huawei push notification category.
  final String? categoryHW;

  /// OPPO push channel ID.
  final String? channelIdOPPO;

  /// Vivo push type (system or operational message).
  final VivoPushType? pushTypeVIVO;

  /// FCM collapse key for grouping notifications.
  final String? collapseKeyFCM;

  /// FCM notification image URL.
  final String? imageUrlFCM;

  /// Huawei push notification importance level.
  final HuaweiPushImportance? importanceHW;

  /// Huawei notification image URL.
  final String? imageUrlHW;

  /// FCM push channel ID.
  final String? channelIdFCM;

  /// Vivo push notification category.
  final String? categoryVivo;

  /// Honor push notification importance level.
  final HonorPushImportance? importanceHonor;

  /// Honor notification image URL.
  final String? imageUrlHonor;

  /// Creates [AndroidPushOptions] with optional vendor-specific settings.
  AndroidPushOptions({
    this.notificationId,
    this.channelIdMi,
    this.channelIdHW,
    this.categoryHW,
    this.channelIdOPPO,
    this.pushTypeVIVO,
    this.collapseKeyFCM,
    this.imageUrlFCM,
    this.importanceHW,
    this.imageUrlHW,
    this.channelIdFCM,
    this.categoryVivo,
    this.importanceHonor,
    this.imageUrlHonor,
  });

  /// Converts this object to the SDK data object.
  RCIMIWAndroidPushOptions toRaw() {
    return RCIMIWAndroidPushOptions.create(
      notificationId: notificationId,
      channelIdMi: channelIdMi,
      channelIdHW: channelIdHW,
      categoryHW: categoryHW,
      channelIdOPPO: channelIdOPPO,
      pushTypeVIVO:
          pushTypeVIVO != null
              ? RCIMIWVIVOPushType.values[pushTypeVIVO!.index]
              : null,
      collapseKeyFCM: collapseKeyFCM,
      imageUrlFCM: imageUrlFCM,
      importanceHW:
          importanceHW != null
              ? RCIMIWImportanceHW.values[importanceHW!.index]
              : null,
      imageUrlHW: imageUrlHW,
      channelIdFCM: channelIdFCM,
      categoryVivo: categoryVivo,
      importanceHonor:
          importanceHonor != null
              ? RCIMIWImportanceHonor.values[importanceHonor!.index]
              : null,
      imageUrlHonor: imageUrlHonor,
    );
  }
}

/// HarmonyOS-specific push notification options.
class HarmonyPushOptions {
  /// The notification image URL.
  final String? imageUrl;

  /// The notification category.
  final String? category;

  /// Creates [HarmonyPushOptions] with optional HarmonyOS-specific settings.
  HarmonyPushOptions({this.imageUrl, this.category});

  /// Converts this object to the SDK data object.
  RCIMIWHarmonyPushOptions toRaw() {
    return RCIMIWHarmonyPushOptions.create(
      imageUrl: imageUrl,
      category: category,
    );
  }
}

/// Configuration for push notifications attached to a message.
///
/// Controls how the push notification is displayed on different platforms,
/// including title, content, and platform-specific options.
class PushConfig {
  /// Whether to disable the push notification entirely.
  final bool? disableNotification;

  /// Whether to hide the push title.
  final bool? disablePushTitle;

  /// The custom title for the push notification.
  final String? pushTitle;

  /// The custom content body for the push notification.
  final String? pushContent;

  /// Custom data payload attached to the push notification.
  final String? pushData;

  /// Whether to force showing message detail in the notification.
  final bool? forceShowDetailContent;

  /// The push template ID for server-side template rendering.
  final String? templateId;

  /// Whether this is a VoIP push notification (iOS only).
  final bool? voIPPush;

  /// iOS-specific push notification options.
  final IOSPushOptions? iOSPushOptions;

  /// Android-specific push notification options.
  final AndroidPushOptions? androidPushOptions;

  /// HarmonyOS-specific push notification options.
  final HarmonyPushOptions? harmonyPushOptions;

  /// Creates a [PushConfig] with optional notification settings.
  PushConfig({
    this.disableNotification,
    this.disablePushTitle,
    this.pushTitle,
    this.pushContent,
    this.pushData,
    this.forceShowDetailContent,
    this.templateId,
    this.voIPPush,
    this.iOSPushOptions,
    this.androidPushOptions,
    this.harmonyPushOptions,
  });

  /// Converts this object to the SDK data object.
  RCIMIWMessagePushOptions toRaw() {
    return RCIMIWMessagePushOptions.create(
      disableNotification: disableNotification,
      disablePushTitle: disablePushTitle,
      pushTitle: pushTitle,
      pushContent: pushContent,
      pushData: pushData,
      forceShowDetailContent: forceShowDetailContent,
      templateId: templateId,
      voIPPush: voIPPush,
      iOSPushOptions: iOSPushOptions?.toRaw(),
      androidPushOptions: androidPushOptions?.toRaw(),
      harmonyPushOptions: harmonyPushOptions?.toRaw(),
    );
  }
}
