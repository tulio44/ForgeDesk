import 'package:flutter/material.dart';
import 'package:prestador/screens/minhas_solicitacoes_screen.dart';
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
      home: PrestadorHomeScreen(service: service, enablePolling: enablePolling),
    );
  }
}

class PrestadorHomeScreen extends StatefulWidget {
  const PrestadorHomeScreen({
    super.key,
    this.service,
    this.enablePolling = true,
  });

  final SolicitacaoService? service;
  final bool enablePolling;

  @override
  State<PrestadorHomeScreen> createState() => _PrestadorHomeScreenState();
}

class _PrestadorHomeScreenState extends State<PrestadorHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final screens = [
      OportunidadeListScreen(
        service: service,
        enablePolling: widget.enablePolling,
      ),
      MinhasSolicitacoesScreen(
        service: service,
        enablePolling: widget.enablePolling,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Oportunidades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Minhas Solicitações',
          ),
        ],
      ),
    );
  }
}
