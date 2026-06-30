import 'package:flutter/material.dart';
import 'package:prestador/screens/login_screen.dart';
import 'package:prestador/screens/minhas_solicitacoes_screen.dart';
import 'package:prestador/screens/oportunidade_list_screen.dart';
import 'package:prestador/services/auth_service.dart';
import 'package:prestador/services/solicitacao_service.dart';

void main() {
  runApp(const PrestadorApp());
}

class PrestadorApp extends StatefulWidget {
  const PrestadorApp({
    super.key,
    this.service,
    this.enablePolling = true,
    this.initialAuth,
  });

  final SolicitacaoService? service;
  final bool enablePolling;
  final AuthResult? initialAuth;

  @override
  State<PrestadorApp> createState() => _PrestadorAppState();
}

class _PrestadorAppState extends State<PrestadorApp> {
  late AuthResult? _auth = widget.initialAuth;

  void _onAuthenticated(AuthResult auth) {
    setState(() {
      _auth = auth;
    });
  }

  void _logout() {
    setState(() {
      _auth = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = _auth;

    return MaterialApp(
      title: 'ForgeDesk Prestador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: auth == null
          ? LoginScreen(onAuthenticated: _onAuthenticated)
          : PrestadorHomeScreen(
              service:
                  widget.service ?? SolicitacaoService(authToken: auth.token),
              userName: auth.nome,
              onLogout: _logout,
              enablePolling: widget.enablePolling,
            ),
    );
  }
}

class PrestadorHomeScreen extends StatefulWidget {
  const PrestadorHomeScreen({
    super.key,
    this.service,
    required this.userName,
    required this.onLogout,
    this.enablePolling = true,
  });

  final SolicitacaoService? service;
  final String userName;
  final VoidCallback onLogout;
  final bool enablePolling;

  @override
  State<PrestadorHomeScreen> createState() => _PrestadorHomeScreenState();
}

class _PrestadorHomeScreenState extends State<PrestadorHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      body: _selectedIndex == 0
          ? OportunidadeListScreen(
              service: service,
              enablePolling: widget.enablePolling,
            )
          : MinhasSolicitacoesScreen(
              service: service,
              enablePolling: widget.enablePolling,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            widget.onLogout();
            return;
          }

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
            label: 'Minhas Solicitacoes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Sair'),
        ],
      ),
    );
  }
}
