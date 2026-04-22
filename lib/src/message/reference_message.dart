import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// Parameters for creating a [ReferenceMessage].
class ReferenceMessageParams extends MessageParams {
  /// The original message being referenced (replied to).
  final Message referenceMessage;

  /// The reply text content.
  final String text;

  /// Creates [ReferenceMessageParams] with the required reference message and reply text.
  ReferenceMessageParams({
    required this.referenceMessage,
    required this.text,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A reference (reply) message in the Nexconn IM SDK.
///
/// Extends [Message] to represent a reply that references another message.
/// Contains both the reply text and the original referenced message.
class ReferenceMessage extends Message {
  /// Creates a [ReferenceMessage] by wrapping a raw message object.
  ReferenceMessage.wrap(super.raw) : super.wrap();

  /// Creates a [ReferenceMessage] from an existing SDK object.
  static ReferenceMessage fromRaw(RCIMIWReferenceMessage raw) =>
      ReferenceMessage.wrap(raw);

  RCIMIWReferenceMessage get _refRaw => raw as RCIMIWReferenceMessage;

  /// The reply text content.
  String? get text => _refRaw.text;

  /// Sets the reply text content.
  set text(String? v) => _refRaw.text = v;

  /// The original message that this message references (replies to).
  Message? get referenceMsg =>
      _refRaw.referenceMessage != null
          ? Message.fromRaw(_refRaw.referenceMessage!)
          : null;

  @override
  Map<String, dynamic> extraJson() => {
    'text': text,
    'referenceMessage': referenceMsg?.toJson(),
  };
}
