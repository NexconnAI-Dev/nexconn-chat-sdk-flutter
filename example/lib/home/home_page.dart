import 'package:flutter/material.dart';
import '../pages/connect/connect_page.dart';
import '../pages/channel/channel_page.dart';
import '../pages/message/message_page.dart';
import '../pages/group/group_page.dart';
import '../pages/open_channel/open_channel_page.dart';
import '../pages/tag/tag_page.dart';
import '../pages/translate/translate_page.dart';
import '../pages/user/user_page.dart';
import '../widgets/result_list.dart';

class _Section {
  final String title;
  final Widget page;
  const _Section({required this.title, required this.page});
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final _sections = [
    _Section(title: 'Connection', page: const ConnectPage()),
    _Section(title: 'Channel', page: const ChannelPage()),
    _Section(title: 'Message', page: const MessagePage()),
    _Section(title: 'Group', page: const GroupPage()),
    _Section(title: 'Open Channel', page: const OpenChannelPage()),
    _Section(title: 'Tag', page: const TagPage()),
    _Section(title: 'Translate', page: const TranslatePage()),
    _Section(title: 'User/Friend', page: const UserPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexconn Flutter Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View Result Logs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResultListPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return ListTile(
            title: Text(section.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => section.page),
              );
            },
          );
        },
      ),
    );
  }
}
