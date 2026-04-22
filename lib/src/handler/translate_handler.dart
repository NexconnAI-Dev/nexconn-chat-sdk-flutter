import '../model/translate_item.dart';

/// Event fired when a translation task completes.
class TranslationCompletedEvent {
  /// The list of translation results.
  final List<TranslateResult>? results;

  /// Creates a [TranslationCompletedEvent].
  const TranslationCompletedEvent({this.results});
}

/// Event fired when the user's translation language preference changes.
class TranslationLanguageChangedEvent {
  /// The new target language code.
  final String? language;

  /// Creates a [TranslationLanguageChangedEvent].
  const TranslationLanguageChangedEvent({this.language});
}

/// Event fired when the auto-translate state changes for the current user.
class AutoTranslateStateChangedEvent {
  /// Whether auto-translate is now enabled.
  final bool isEnabled;

  /// Creates an [AutoTranslateStateChangedEvent].
  const AutoTranslateStateChangedEvent({required this.isEnabled});
}

/// Callback invoked when a translation task completes.
typedef OnTranslationCompleted = void Function(TranslationCompletedEvent event);

/// Callback invoked when the translation language preference changes.
typedef OnTranslationLanguageChanged =
    void Function(TranslationLanguageChangedEvent event);

/// Callback invoked when the auto-translate state changes.
typedef OnAutoTranslateStateChanged =
    void Function(AutoTranslateStateChangedEvent event);

/// Handler for translation-related global events.
///
/// Register this handler via [NCEngine.addTranslateHandler] to receive
/// notifications about translation completions, language changes,
/// and auto-translate state changes.
class TranslateHandler {
  /// Called when a translation task completes.
  final OnTranslationCompleted? onTranslationCompleted;

  /// Called when the translation language preference changes.
  final OnTranslationLanguageChanged? onTranslationLanguageChanged;

  /// Called when the auto-translate state changes.
  final OnAutoTranslateStateChanged? onAutoTranslateStateChanged;

  /// Creates a [TranslateHandler].
  TranslateHandler({
    this.onTranslationCompleted,
    this.onTranslationLanguageChanged,
    this.onAutoTranslateStateChanged,
  });
}
