import 'package:flutter/material.dart';
import 'live_stream_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RTSP Stream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LiveStreamScreen(),
    );
  }
}
