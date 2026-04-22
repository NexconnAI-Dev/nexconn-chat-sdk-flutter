import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/translate_mode.dart';

/// Parameters for translating a single message.
class TranslateMessageParam {
  /// The unique identifier of the message to translate.
  final String? messageId;

  /// The source language code (e.g., "en", "zh").
  final String? sourceLanguage;

  /// The target language code to translate into.
  final String? targetLanguage;

  /// Creates [TranslateMessageParam] with optional translation parameters.
  TranslateMessageParam({
    this.messageId,
    this.sourceLanguage,
    this.targetLanguage,
  });

  /// Converts this object to the SDK data object.
  RCIMIWTranslateMessageParam toRaw() {
    return RCIMIWTranslateMessageParam.create(
      messageUId: messageId,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
}

/// Parameters for batch translating multiple messages.
class TranslateMessagesParams {
  /// Whether to force re-translation even if a cached result exists.
  final bool? force;

  /// The translation mode (e.g., translate only, translate and original).
  final TranslateMode? mode;

  /// The list of individual message translation parameters.
  final List<TranslateMessageParam>? list;

  /// Creates [TranslateMessagesParams] for batch translation.
  TranslateMessagesParams({this.force, this.mode, this.list});

  /// Converts this object to the SDK data object.
  RCIMIWTranslateMessagesParams toRaw() {
    return RCIMIWTranslateMessagesParams.create(
      force: force,
      mode: mode != null ? RCIMIWTranslateMode.values[mode!.index] : null,
      list: list?.map((e) => e.toRaw()).toList(),
    );
  }
}
