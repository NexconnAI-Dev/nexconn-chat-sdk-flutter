import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/message_type.dart';
import 'message.dart';

/// An unknown message type in the Nexconn IM SDK.
///
/// Represents messages whose type is not recognized by the current SDK version.
/// This typically occurs when the sender uses a newer SDK version with message types not yet supported by the receiver.
/// The raw data and object name are preserved for forward compatibility.
class UnknownMessage extends Message {
  /// Creates an [UnknownMessage] by wrapping a raw message object.
  UnknownMessage.wrap(super.raw) : super.wrap();

  /// Creates a [UnknownMessage] from an existing SDK object.
  static UnknownMessage fromRaw(RCIMIWUnknownMessage raw) =>
      UnknownMessage.wrap(raw);

  RCIMIWUnknownMessage? get _unknownRaw =>
      raw is RCIMIWUnknownMessage ? raw as RCIMIWUnknownMessage : null;

  /// Always returns [MessageType.unknown].
  @override
  MessageType? get messageType => MessageType.unknown;

  /// The raw serialized data of the unrecognized message.
  String? get rawData => _unknownRaw?.rawData;

  /// The object name (type identifier) of the unrecognized message.
  String? get objectName => _unknownRaw?.objectName;

  @override
  Map<String, dynamic> extraJson() => {
    'rawData': rawData,
    'objectName': objectName,
  };
}
