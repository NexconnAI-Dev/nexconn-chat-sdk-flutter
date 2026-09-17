import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import 'message.dart';

/// An informational tip message displayed in the conversation timeline.
class InformationNotificationMessage extends Message {
  InformationNotificationMessage.wrap(super.raw) : super.wrap();

  static InformationNotificationMessage fromRaw(
    RCIMIWInformationNotificationMessage raw,
  ) => InformationNotificationMessage.wrap(raw);

  RCIMIWInformationNotificationMessage get _notificationRaw =>
      raw as RCIMIWInformationNotificationMessage;

  /// The text shown to the user.
  String? get message => _notificationRaw.message;

  @override
  Map<String, dynamic> extraJson() => {'message': message};
}
