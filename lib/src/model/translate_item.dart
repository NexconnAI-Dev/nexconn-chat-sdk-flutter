import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/translate_result_type.dart';
import '../enum/translate_status.dart';
import '../error/nc_error.dart';
import '../internal/converter.dart';

/// Detailed translation information for a translated message.
class TranslateInfo {
  /// The translated text content.
  final String? translatedText;

  /// The target language code of the translation.
  final String? targetLanguage;

  /// The current status of the translation.
  final TranslateStatus? status;

  /// Creates a [TranslateInfo].
  const TranslateInfo({this.translatedText, this.targetLanguage, this.status});
}

/// Represents the result of a single message translation.
class TranslateResult {
  final RCIMIWTranslateItem _raw;
  TranslateResult._(this._raw);

  /// Creates a [TranslateResult] from an existing SDK object.
  static TranslateResult fromRaw(RCIMIWTranslateItem raw) =>
      TranslateResult._(raw);

  /// The identifier of the translated message.
  String? get identifier => _raw.identifier;

  /// The error, if the translation failed.
  NCError? get error => Converter.toNCError(_raw.errorCode ?? 0);

  /// The type of translation result (e.g., new translation, cached).
  TranslateResultType? get sourceType =>
      _raw.resultType != null
          ? TranslateResultType.values[_raw.resultType!.index]
          : null;

  /// The detailed translation information.
  TranslateInfo? get translateInfo {
    final rawInfo = _raw.translateInfo;
    if (rawInfo == null) return null;
    return TranslateInfo(
      translatedText: rawInfo.translatedText,
      targetLanguage: rawInfo.targetLanguage,
      status:
          rawInfo.status != null
              ? TranslateStatus.values[rawInfo.status!.index]
              : null,
    );
  }

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'error': error?.code,
    'sourceType': sourceType?.name,
    'translateInfo':
        translateInfo != null
            ? {
              'translatedText': translateInfo!.translatedText,
              'targetLanguage': translateInfo!.targetLanguage,
              'status': translateInfo!.status?.name,
            }
            : null,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWTranslateItem get raw => _raw;
}
