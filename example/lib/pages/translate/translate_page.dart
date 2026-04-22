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
      title: '翻译文本',
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
      title: '翻译消息',
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
      title: '设置翻译目标语言',
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
      title: '设置自动翻译',
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
      title: '设置会话翻译策略',
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
      appBar: AppBar(title: const Text('翻译相关')),
      body: ListView(
        children: [
          ApiSection(
            title: '翻译操作',
            children: [
              ApiButton(label: '翻译文本', onPressed: _translateTexts),
              ApiButton(label: '翻译消息', onPressed: _translateMessages),
            ],
          ),
          ApiSection(
            title: '翻译配置',
            children: [
              ApiButton(label: '设置翻译语言', onPressed: _setTranslationLanguage),
              ApiButton(label: '获取翻译语言', onPressed: _getTranslationLanguage),
              ApiButton(
                  label: '开启/关闭自动翻译', onPressed: _setAutoTranslateEnabled),
              ApiButton(label: '获取自动翻译状态', onPressed: _getAutoTranslateEnabled),
              ApiButton(label: '设置会话翻译策略', onPressed: _setTranslateStrategy),
            ],
          ),
        ],
      ),
    );
  }
}
