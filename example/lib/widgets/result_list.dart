import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultItem {
  final String title;
  final String result;
  final String timestamp;
  ResultItem(
      {required this.title, required this.result, required this.timestamp});
}

class ResultNotifier extends ChangeNotifier {
  static final ResultNotifier _instance = ResultNotifier._();
  static ResultNotifier get instance => _instance;
  ResultNotifier._();

  final List<ResultItem> _items = [];
  List<ResultItem> get items => _items;

  static String formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is Map || result is List) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(result);
    }
    return result.toString();
  }

  void add(String title, dynamic result) {
    final now = DateTime.now();
    final ts = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
    _items.insert(
        0,
        ResultItem(
          title: title,
          result: formatResult(result),
          timestamp: ts,
        ));
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class ResultListPage extends StatefulWidget {
  const ResultListPage({super.key});

  @override
  State<ResultListPage> createState() => _ResultListPageState();
}

class _ResultListPageState extends State<ResultListPage> {
  void _copyToClipboard(ResultItem item) {
    final text = '[${item.timestamp}] ${item.title}\n${item.result}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Call Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ResultNotifier.instance.clear(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: ResultNotifier.instance,
        builder: (context, _) {
          final items = ResultNotifier.instance.items;
          if (items.isEmpty) {
            return const Center(child: Text('No results yet'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ExpansionTile(
                title: Text(
                  '${items.length - index}: ${item.title}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  item.timestamp,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyToClipboard(item),
                            tooltip: 'Copy',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () => _copyToClipboard(item),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: SelectableText(
                              item.result,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
