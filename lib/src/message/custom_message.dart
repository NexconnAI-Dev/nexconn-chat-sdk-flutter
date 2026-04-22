import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// Parameters for creating a [CustomMessage].
class CustomMessageParams extends MessageParams {
  /// The unique identifier for the registered custom message type.
  final String messageIdentifier;

  /// Custom key-value fields for the message payload.
  final Map fields;

  /// Search keywords used for local message search.
  final List<String>? searchableWords;

  /// Creates [CustomMessageParams] with the required message identifier and custom fields.
  CustomMessageParams({
    required this.messageIdentifier,
    required this.fields,
    this.searchableWords,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A registered custom message in the Nexconn IM SDK.
///
/// Extends [Message] to support custom message types registered on the underlying platform without media content.
class CustomMessage extends Message {
  /// Creates a [CustomMessage] by wrapping a raw message object.
  CustomMessage.wrap(super.raw) : super.wrap();

  /// Creates a [CustomMessage] from an existing SDK object.
  static CustomMessage fromRaw(RCIMIWNativeCustomMessage raw) =>
      CustomMessage.wrap(raw);

  RCIMIWNativeCustomMessage get _rawCustom => raw as RCIMIWNativeCustomMessage;

  /// Custom key-value fields of the message payload.
  Map? get fields => _rawCustom.fields;

  /// Sets the custom key-value fields.
  set fields(Map? v) => _rawCustom.fields = v;

  /// A list of keywords that make this message searchable in local search.
  List<String>? get searchableWords => _rawCustom.searchableWords;

  /// Sets the searchable keywords for local search.
  set searchableWords(List<String>? v) => _rawCustom.searchableWords = v;

  /// The unique identifier for the registered custom message type.
  String? get messageIdentifier => _rawCustom.messageIdentifier;

  /// Sets the custom message type identifier.
  set messageIdentifier(String? v) => _rawCustom.messageIdentifier = v;

  @override
  Map<String, dynamic> extraJson() => {
    'messageIdentifier': messageIdentifier,
    'fields': fields,
    'searchableWords': searchableWords,
  };
}
