import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// A group notification message.
///
/// This message type represents group-related notifications such as members
/// joining, leaving, or group information changing. In the chat UI, it is
/// typically displayed as a tip message.
class GroupNotificationMessage extends Message {
  /// Creates a [GroupNotificationMessage] from an existing message object.
  GroupNotificationMessage.wrap(super.raw) : super.wrap();

  /// Creates a [GroupNotificationMessage] from an existing SDK object.
  static GroupNotificationMessage fromRaw(RCIMIWGroupNotificationMessage raw) =>
      GroupNotificationMessage.wrap(raw);

  RCIMIWGroupNotificationMessage get _groupNotifRaw =>
      raw as RCIMIWGroupNotificationMessage;

  /// The operation type of the group event, such as join, quit, or rename.
  String? get operation => _groupNotifRaw.operation;

  /// The user ID of the operator who triggered the group event.
  String? get operatorUserId => _groupNotifRaw.operatorUserId;

  /// The payload attached to the group event, usually in JSON format.
  String? get data => _groupNotifRaw.data;

  /// The display text of this notification.
  String? get message => _groupNotifRaw.message;

  @override
  Map<String, dynamic> extraJson() => {
    'operation': operation,
    'operatorUserId': operatorUserId,
    'data': data,
    'message': message,
  };
}
