import 'package:flutter/material.dart';
import 'package:prestador/screens/oportunidade_list_screen.dart';
import 'package:prestador/services/solicitacao_service.dart';

void main() {
  runApp(PrestadorApp());
}

class PrestadorApp extends StatelessWidget {
  const PrestadorApp({super.key, this.service, this.enablePolling = true});

  final SolicitacaoService? service;
  final bool enablePolling;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForgeDesk Prestador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: OportunidadeListScreen(
        service: service,
        enablePolling: enablePolling,
      ),
    );
  }
}
