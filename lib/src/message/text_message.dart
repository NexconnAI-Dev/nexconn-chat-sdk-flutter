import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// Parameters for creating a [TextMessage].
class TextMessageParams extends MessageParams {
  /// The text content of the message.
  final String text;

  /// Creates [TextMessageParams] with the required [text].
  TextMessageParams({
    required this.text,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A plain text message in the Nexconn IM SDK.
///
/// Extends [Message] to carry text content.
/// Use [TextMessage.create] to construct a new text message for sending.
class TextMessage extends Message {
  /// Creates a [TextMessage] by wrapping a raw message object.
  TextMessage.wrap(super.raw) : super.wrap();

  /// Creates a [TextMessage] from an existing SDK object.
  static TextMessage fromRaw(RCIMIWTextMessage raw) => TextMessage.wrap(raw);

  RCIMIWTextMessage get _textRaw => raw as RCIMIWTextMessage;

  RCIMIWTextMessage get _effectiveTextRaw {
    final info = raw.modifyInfo;
    final content = info?.content;
    if (raw.hasChanged == true &&
        info?.status == RCIMIWMessageModifyStatus.success &&
        content is RCIMIWTextMessage) {
      return content;
    }
    return _textRaw;
  }

  /// The text content of this message.
  String? get text => _effectiveTextRaw.text;

  /// Sets the text content of this message.
  set text(String? v) => _effectiveTextRaw.text = v;

  @override
  Map<String, dynamic> extraJson() => {'text': text};
}
