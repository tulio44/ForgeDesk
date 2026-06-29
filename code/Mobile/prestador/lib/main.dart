import 'package:flutter/material.dart';

void main() {
  runApp(const PrestadorApp());
}

class PrestadorApp extends StatelessWidget {
  const PrestadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForgeDesk Prestador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const PrestadorHomePage(),
    );
  }
}

class PrestadorHomePage extends StatelessWidget {
  const PrestadorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForgeDesk Prestador')),
      body: const Center(
        child: Text('App Prestador do ForgeDesk'),
      ),
    );
  }
}
