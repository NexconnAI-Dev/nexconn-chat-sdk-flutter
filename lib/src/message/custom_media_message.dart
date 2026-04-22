import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'media_message.dart';
import 'message.dart';

/// Parameters for creating a [CustomMediaMessage].
class CustomMediaMessageParams extends MessageParams {
  /// The unique identifier for the registered custom message type.
  final String messageIdentifier;

  /// The local file path of the media content to attach.
  final String path;

  /// Custom key-value fields for the message payload.
  final Map fields;

  /// Search keywords used for local message search.
  final List<String>? searchableWords;

  /// Creates [CustomMediaMessageParams] with the required message identifier, media [path], and custom [fields].
  CustomMediaMessageParams({
    required this.messageIdentifier,
    required this.path,
    required this.fields,
    this.searchableWords,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A registered custom media message in the Nexconn IM SDK.
///
/// Extends [MediaMessage] to support registered custom message types that include media content.
class CustomMediaMessage extends MediaMessage {
  /// Creates a [CustomMediaMessage] by wrapping a raw message object.
  CustomMediaMessage.wrap(super.raw) : super.wrap();

  /// Creates a [CustomMediaMessage] from an existing SDK object.
  static CustomMediaMessage fromRaw(RCIMIWNativeCustomMediaMessage raw) =>
      CustomMediaMessage.wrap(raw);

  RCIMIWNativeCustomMediaMessage get _rawCustomMedia =>
      raw as RCIMIWNativeCustomMediaMessage;

  /// Custom key-value fields of the message payload.
  Map? get fields => _rawCustomMedia.fields;

  /// Sets the custom key-value fields.
  set fields(Map? v) => _rawCustomMedia.fields = v;

  /// A list of keywords that make this message searchable in local search.
  List<String>? get searchableWords => _rawCustomMedia.searchableWords;

  /// Sets the searchable keywords for local search.
  set searchableWords(List<String>? v) => _rawCustomMedia.searchableWords = v;

  /// The unique identifier for the registered custom message type.
  String? get messageIdentifier => _rawCustomMedia.messageIdentifier;

  /// Sets the custom message type identifier.
  set messageIdentifier(String? v) => _rawCustomMedia.messageIdentifier = v;

  @override
  Map<String, dynamic> extraJson() => {
    ...super.extraJson(),
    'messageIdentifier': messageIdentifier,
    'fields': fields,
    'searchableWords': searchableWords,
  };
}
