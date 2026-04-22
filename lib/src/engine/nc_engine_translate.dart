part of 'nc_engine.dart';

/// Parameters for translating a batch of text strings.
class TranslateTextsParams {
  /// The list of text strings to translate.
  final List<String> list;

  /// The translation mode.
  final TranslateMode? mode;

  /// Creates [TranslateTextsParams].
  TranslateTextsParams({required this.list, this.mode});
}

/// Module for translation-related features.
///
/// Access this module through [NCEngine.translate] to translate messages,
/// translate plain text, manage language settings, and configure automatic
/// translation.
class TranslateModule {
  TranslateModule._();

  RCIMIWEngine get _engine => NCEngine.engine;

  /// Translates messages according to [params].
  Future<int> translateMessages(
    TranslateMessagesParams params,
    ErrorHandler handler,
  ) {
    return _engine.translateMessagesWithParams(
      params.toRaw(),
      callback: IRCIMIWTranslateResponseCallback(
        onTranslateResponse: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Translates a batch of text strings.
  Future<int> translateTexts(
    TranslateTextsParams params,
    ErrorHandler handler,
  ) {
    return _engine.translateTextsWithParams(
      RCIMIWTranslateTextParams.create(
        mode:
            params.mode != null
                ? RCIMIWTranslateMode.values[params.mode!.index]
                : null,
        list:
            params.list
                .map((text) => RCIMIWTranslateTextParam.create(text: text))
                .toList(),
      ),
      callback: IRCIMIWTranslateResponseCallback(
        onTranslateResponse: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the target translation language.
  Future<int> setTranslationLanguage(String language, ErrorHandler handler) {
    return _engine.setTranslationLanguage(
      language,
      callback: IRCIMIWTranslateResponseCallback(
        onTranslateResponse: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Retrieves the currently configured translation language.
  Future<int> getTranslationLanguage(OperationHandler<String> handler) {
    return _engine.getTranslationLanguage(
      callback: IRCIMIWTranslateGetLanguageCallback(
        onSuccess: (language) => handler(language, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Checks whether automatic translation is enabled.
  Future<int> getAutoTranslateEnabled(OperationHandler<bool> handler) {
    return _engine.getAutoTranslateEnabled(
      callback: IRCIMIWGetAutoTranslateEnabledCallback(
        onSuccess: (isEnable) => handler(isEnable, null),
        onError: (code) => handler(null, Converter.toNCError(code)),
      ),
    );
  }

  /// Enables or disables automatic translation for incoming messages.
  Future<int> setAutoTranslateEnabled(bool isEnable, ErrorHandler handler) {
    return _engine.setAutoTranslateEnable(
      isEnable,
      callback: IRCIMIWTranslateResponseCallback(
        onTranslateResponse: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }

  /// Sets the translation strategy for multiple channels.
  Future<int> setTranslateStrategy(
    List<ChannelIdentifier> identifiers,
    TranslateStrategy strategy,
    ErrorHandler handler,
  ) {
    return _engine.batchSetConversationTranslateStrategy(
      identifiers
          .map((c) => Converter.toRCConversationType(c.channelType))
          .toList(),
      identifiers.map((c) => c.channelId).toList(),
      identifiers.map((c) => c.subChannelId ?? '').toList(),
      RCIMIWTranslateStrategy.values[strategy.index],
      callback: IRCIMIWTranslateResponseCallback(
        onTranslateResponse: (code) => handler(Converter.toNCError(code)),
      ),
    );
  }
}

void _notifyTranslationCompleted(List<RCIMIWTranslateItem>? items) {
  final wrapped = items?.map(TranslateResult.fromRaw).toList();
  NCEngine._translateHandlers.notify(
    (h) => h.onTranslationCompleted?.call(
      TranslationCompletedEvent(results: wrapped),
    ),
  );
}

void _notifyTranslationLanguageChanged(String? language) {
  NCEngine._translateHandlers.notify(
    (h) => h.onTranslationLanguageChanged?.call(
      TranslationLanguageChangedEvent(language: language),
    ),
  );
}

void _notifyAutoTranslateStateChanged(bool? isEnable) {
  NCEngine._translateHandlers.notify(
    (h) => h.onAutoTranslateStateChanged?.call(
      AutoTranslateStateChangedEvent(isEnabled: isEnable ?? false),
    ),
  );
}
