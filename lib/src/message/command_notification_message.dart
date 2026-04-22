import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// A command notification message in the Nexconn IM SDK.
///
/// Unlike [CommandMessage], command notification messages are stored in the message history and can be displayed in the channel UI.
/// Used for delivering structured notifications that carry a command name and associated data.
class CommandNotificationMessage extends Message {
  /// Creates a [CommandNotificationMessage] by wrapping a raw message object.
  CommandNotificationMessage.wrap(super.raw) : super.wrap();

  /// Creates a [CommandNotificationMessage] from an existing SDK object.
  static CommandNotificationMessage fromRaw(
    RCIMIWCommandNotificationMessage raw,
  ) => CommandNotificationMessage.wrap(raw);

  RCIMIWCommandNotificationMessage get _cmdNotifRaw =>
      raw as RCIMIWCommandNotificationMessage;

  /// The command name identifying the type of notification.
  String? get name => _cmdNotifRaw.name;

  /// The notification data payload (typically JSON-encoded).
  String? get data => _cmdNotifRaw.data;

  @override
  Map<String, dynamic> extraJson() => {'name': name, 'data': data};
}
