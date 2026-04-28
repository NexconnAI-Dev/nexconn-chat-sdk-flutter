import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  void _translateTexts() async {
    final args = await showParamsDialog(
      context,
      title: 'Translate Texts',
      params: [
        (label: 'Texts(comma)', hint: 'hello,world', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final texts = (args['Texts(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('translateTexts', {'list': texts});
    await NCEngine.translate.translateTexts(
      TranslateTextsParams(list: texts),
      (error) => showResult('translateTexts', error?.toJson()),
    );
  }

  void _translateMessages() async {
    final args = await showParamsDialog(
      context,
      title: 'Translate Messages',
      params: [
        (label: 'MessageId', hint: 'messageId', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final messageId = args['MessageId'] ?? '';
    if (messageId.isEmpty) return;
    showInput('translateMessages', {
      'messageIds': [messageId]
    });
    await NCEngine.translate.translateMessages(
      TranslateMessagesParams(
        list: [TranslateMessageParam(messageId: messageId)],
      ),
      (e) => showResult('translateMessages', e?.toJson()),
    );
  }

  void _setTranslationLanguage() async {
    final args = await showParamsDialog(
      context,
      title: 'Set Translation Target Language',
      params: [(label: 'Language', hint: 'zh-Hans', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('setTranslationLanguage', {
      'language': args['Language'] ?? 'zh-Hans',
    });
    final code = await NCEngine.translate.setTranslationLanguage(
      args['Language'] ?? 'zh-Hans',
      (error) => showResult('setTranslationLanguage', error?.toJson()),
    );
    if (code != 0 && mounted) {
      showResult('setTranslationLanguage', {'code': code});
    }
  }

  void _getTranslationLanguage() async {
    showInput('getTranslationLanguage', const {});
    final code =
        await NCEngine.translate.getTranslationLanguage((language, error) {
      showResult('getTranslationLanguage',
          hasError(error) ? error?.toJson() : {'language': language});
    });
    if (code != 0 && mounted) {
      showResult('getTranslationLanguage', {'code': code});
    }
  }

  void _setAutoTranslateEnabled() async {
    final args = await showParamsDialog(
      context,
      title: 'Set Auto Translate',
      params: [(label: 'Enable(0/1)', hint: '1', isNumber: true)],
    );
    if (args == null || !mounted) return;
    showInput('setAutoTranslateEnabled', {
      'enable': args['Enable(0/1)'] == '1',
    });
    final code = await NCEngine.translate.setAutoTranslateEnabled(
      args['Enable(0/1)'] == '1',
      (error) => showResult('setAutoTranslateEnabled', error?.toJson()),
    );
    if (code != 0 && mounted) {
      showResult('setAutoTranslateEnabled', {'code': code});
    }
  }

  void _getAutoTranslateEnabled() async {
    showInput('getAutoTranslateEnabled', const {});
    final code =
        await NCEngine.translate.getAutoTranslateEnabled((isEnable, error) {
      showResult('getAutoTranslateEnabled',
          hasError(error) ? error?.toJson() : {'isEnable': isEnable});
    });
    if (code != 0 && mounted) {
      showResult('getAutoTranslateEnabled', {'code': code});
    }
  }

  void _setTranslateStrategy() async {
    final picked = await pickChannel(context);
    if (picked == null || !mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Set Channel Translate Strategy',
      params: [
        (label: 'Strategy(0=default,1=on,2=off)', hint: '1', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final strategyIdx =
        int.tryParse(args['Strategy(0=default,1=on,2=off)'] ?? '1') ?? 1;
    showInput('setTranslateStrategy', {
      'channelType': picked.type.name,
      'channelId': picked.id,
      'subChannelId': picked.subChannelId,
      'strategy': TranslateStrategy
          .values[strategyIdx.clamp(0, TranslateStrategy.values.length - 1)]
          .name,
    });
    final code = await NCEngine.translate.setTranslateStrategy(
      [
        ChannelIdentifier(
          channelType: picked.type,
          channelId: picked.id,
          subChannelId: picked.subChannelId,
        ),
      ],
      TranslateStrategy
          .values[strategyIdx.clamp(0, TranslateStrategy.values.length - 1)],
      (error) => showResult('setTranslateStrategy', error?.toJson()),
    );
    if (code != 0 && mounted) {
      showResult('setTranslateStrategy', {'code': code});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translate')),
      body: ListView(
        children: [
          ApiSection(
            title: 'Translation Actions',
            children: [
              ApiButton(label: 'Translate Texts', onPressed: _translateTexts),
              ApiButton(label: 'Translate Messages', onPressed: _translateMessages),
            ],
          ),
          ApiSection(
            title: 'Translation Settings',
            children: [
              ApiButton(label: 'Set Translation Language', onPressed: _setTranslationLanguage),
              ApiButton(label: 'Get Translation Language', onPressed: _getTranslationLanguage),
              ApiButton(
                  label: 'Set Auto Translate Enabled', onPressed: _setAutoTranslateEnabled),
              ApiButton(label: 'Get Auto Translate Enabled', onPressed: _getAutoTranslateEnabled),
              ApiButton(label: 'Set Channel Translate Strategy', onPressed: _setTranslateStrategy),
            ],
          ),
        ],
      ),
    );
  }
}
