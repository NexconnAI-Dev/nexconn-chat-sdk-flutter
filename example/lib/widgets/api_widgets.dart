import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'result_list.dart';

enum FilePickType { image, video, audio, file, gif }

Future<String?> pickLocalFile(FilePickType type) async {
  switch (type) {
    case FilePickType.image:
      final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      return xFile?.path;
    case FilePickType.video:
      final xFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
      return xFile?.path;
    case FilePickType.audio:
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      return result?.files.single.path;
    case FilePickType.file:
      final result = await FilePicker.platform.pickFiles();
      return result?.files.single.path;
    case FilePickType.gif:
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
      );
      return result?.files.single.path;
  }
}

final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final globalNavigatorKey = GlobalKey<NavigatorState>();

typedef ParamDef = ({String label, String hint, bool isNumber});
typedef PickedChannel = ({ChannelType type, String id, String? subChannelId});

bool hasError(NCError? error) => error != null && !error.isSuccess;

bool isSuccessResult(NCError? error) => error?.isSuccess == true;

void showInput(String title, dynamic input) {
  ResultNotifier.instance.add('$title [input]', input);
}

Map<String, dynamic> channelInput(PickedChannel picked) => {
      'channelType': picked.type.name,
      'channelId': picked.id,
      if (picked.subChannelId != null && picked.subChannelId!.isNotEmpty)
        'subChannelId': picked.subChannelId,
    };

Map<String, dynamic> mergeInputMaps(List<Map<String, dynamic>?> items) => {
      for (final item in items)
        if (item != null) ...item,
    };

Future<ChannelType?> pickChannelType(BuildContext context) async {
  return showDialog<ChannelType>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Select ChannelType'),
      children: ChannelType.values
          .map((t) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, t),
                child: Text(t.name),
              ))
          .toList(),
    ),
  );
}

Future<List<ChannelType>?> pickChannelTypes(
  BuildContext context, {
  Set<ChannelType> defaults = const {ChannelType.direct, ChannelType.group},
}) async {
  final selected = Set<ChannelType>.from(defaults);
  return showDialog<List<ChannelType>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Select ChannelType (Multi-select)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ChannelType.values
              .map((t) => CheckboxListTile(
                    title: Text(t.name),
                    value: selected.contains(t),
                    onChanged: (v) => setLocal(() {
                      if (v == true)
                        selected.add(t);
                      else
                        selected.remove(t);
                    }),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: selected.isEmpty
                ? null
                : () => Navigator.pop(ctx, selected.toList()),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

Future<PickedChannel?> pickChannel(
  BuildContext context, {
  List<ChannelType>? availableTypes,
}) async {
  final types = availableTypes == null || availableTypes.isEmpty
      ? ChannelType.values.toList()
      : availableTypes;
  ChannelType selectedType =
      types.contains(ChannelType.direct) ? ChannelType.direct : types.first;
  final idController = TextEditingController();
  final subChannelIdController = TextEditingController();
  final result = await showDialog<PickedChannel>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Select Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ChannelType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'ChannelType',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setLocal(() => selectedType = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ChannelId',
                hintText: 'channelId',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            if (selectedType == ChannelType.community) ...[
              const SizedBox(height: 12),
              TextField(
                controller: subChannelIdController,
                decoration: const InputDecoration(
                  labelText: 'SubChannelId',
                  hintText: 'subChannelId (optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              (
                type: selectedType,
                id: idController.text.trim(),
                subChannelId:
                    selectedType == ChannelType.community &&
                            subChannelIdController.text.trim().isNotEmpty
                        ? subChannelIdController.text.trim()
                        : null,
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    idController.dispose();
    subChannelIdController.dispose();
  });
  return result;
}

BaseChannel makeChannelFromType(
  ChannelType type,
  String id, {
  String? subChannelId,
}) {
  switch (type) {
    case ChannelType.direct:
      return DirectChannel(id);
    case ChannelType.group:
      return GroupChannel(id);
    case ChannelType.open:
      return OpenChannel(id);
    case ChannelType.community:
      return subChannelId != null && subChannelId.isNotEmpty
          ? CommunitySubChannel(id, subChannelId)
          : CommunityChannel(id);
    case ChannelType.system:
      return SystemChannel(id);
  }
}

Future<Map<String, String>?> showParamsDialog(
  BuildContext context, {
  required String title,
  required List<ParamDef> params,
  bool trimValues = true,
}) async {
  final controllers = {
    for (final p in params) p.label: TextEditingController(),
  };

  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: params
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                    controller: controllers[p.label],
                    decoration: InputDecoration(
                      labelText: p.label,
                      hintText: p.hint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType:
                        p.isNumber ? TextInputType.number : TextInputType.text,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, {
            for (final p in params)
              p.label: trimValues
                  ? controllers[p.label]!.text.trim()
                  : controllers[p.label]!.text,
          }),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    for (final c in controllers.values) {
      c.dispose();
    }
  });
  return result;
}

class ApiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ApiButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: const TextStyle(fontSize: 12),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class ApiSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ApiSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

typedef VoiceRecordResult = ({String path, int duration});

Future<VoiceRecordResult?> recordVoice(BuildContext context) {
  return showDialog<VoiceRecordResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _VoiceRecordDialog(),
  );
}

class _VoiceRecordDialog extends StatefulWidget {
  const _VoiceRecordDialog();

  @override
  State<_VoiceRecordDialog> createState() => _VoiceRecordDialogState();
}

class _VoiceRecordDialogState extends State<_VoiceRecordDialog> {
  final _recorder = AudioRecorder();
  bool _recording = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_recording) {
      _timer?.cancel();
      final audioPath = await _recorder.stop();
      if (audioPath != null && mounted) {
        final player = AudioPlayer();
        try {
          final realDuration = await player.setFilePath(audioPath);
          final seconds = realDuration?.inSeconds ?? _seconds;
          if (seconds > 0 && mounted) {
            var path = audioPath;
            if (defaultTargetPlatform == TargetPlatform.android) {
              path = 'file://$path';
            }
            Navigator.pop(context, (path: path, duration: seconds));
          }
        } finally {
          await player.dispose();
        }
      }
    } else {
      final ok = await _recorder.hasPermission();
      if (!ok) return;
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 32000,
          numChannels: 1,
        ),
        path: path,
      );
      setState(() {
        _recording = true;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    }
  }

  String get _timeLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Voice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_timeLabel,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _recording ? Colors.red : Colors.blue,
              ),
              child: Icon(
                _recording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(_recording ? 'Tap to Stop' : 'Tap to Record',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_recording) {
              _timer?.cancel();
              await _recorder.cancel();
            }
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

void showResult(String title, dynamic result) {
  ResultNotifier.instance.add(title, result);
  final messenger = globalScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  final brief = result is Map
      ? const JsonEncoder().convert(result)
      : result?.toString() ?? 'null';
  final display = brief.length > 80 ? '${brief.substring(0, 80)}...' : brief;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text('$title: $display',
          maxLines: 2, overflow: TextOverflow.ellipsis),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Details',
        onPressed: () {
          globalNavigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const ResultListPage()),
          );
        },
      ),
    ),
  );
}
