import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// A command message in the Nexconn IM SDK.
///
/// Command messages are used for signaling and control purposes between clients.
/// They are not stored in the message history and are not displayed in the channel UI.
class CommandMessage extends Message {
  /// Creates a [CommandMessage] by wrapping a raw message object.
  CommandMessage.wrap(super.raw) : super.wrap();

  /// Creates a [CommandMessage] from an existing SDK object.
  static CommandMessage fromRaw(RCIMIWCommandMessage raw) =>
      CommandMessage.wrap(raw);

  RCIMIWCommandMessage get _cmdRaw => raw as RCIMIWCommandMessage;

  /// The command name identifying the type of command.
  String? get name => _cmdRaw.name;

  /// Sets the command name.
  set name(String? v) => _cmdRaw.name = v;

  /// The command data payload (typically JSON-encoded).
  String? get data => _cmdRaw.data;

  /// Sets the command data payload.
  set data(String? v) => _cmdRaw.data = v;

  @override
  Map<String, dynamic> extraJson() => {'name': name, 'data': data};
}
