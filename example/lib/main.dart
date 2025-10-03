import 'package:flutter/material.dart';

import 'consts.dart';
import 'start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      assert(Consts.apiKeyId.isNotEmpty, 'apiKeyId is empty');
      assert(Consts.apiKey.isNotEmpty, 'apiKey is empty');
      assert(Consts.organizationId.isNotEmpty, 'organizationId is empty');
    } catch (e) {
      debugPrint('Error: $e');
      // To use this example app populate the consts.dart file with your own api Keys.
      rethrow;
    }

    return MaterialApp(
      title: 'Bluetooth Provisioning',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
