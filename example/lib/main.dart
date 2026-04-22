import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'widgets/api_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexconnApp());
}

class NexconnApp extends StatelessWidget {
  const NexconnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexconn Flutter Demo',
      navigatorKey: globalNavigatorKey,
      scaffoldMessengerKey: globalScaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
