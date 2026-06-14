import 'package:flutter/material.dart';

void main() {
  runApp(const ForgeDeskClienteApp());
}

class ForgeDeskClienteApp extends StatelessWidget {
  const ForgeDeskClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForgeDesk Cliente',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ClienteHomePage(),
    );
  }
}

class ClienteHomePage extends StatelessWidget {
  const ClienteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForgeDesk Cliente')),
      body: const Center(child: Text('App Cliente do ForgeDesk')),
    );
  }
}
