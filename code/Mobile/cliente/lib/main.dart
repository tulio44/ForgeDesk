import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/solicitacao_list_screen.dart';
import 'services/auth_service.dart';
import 'services/solicitacao_service.dart';

void main() {
  runApp(const ForgeDeskClienteApp());
}

class ForgeDeskClienteApp extends StatefulWidget {
  const ForgeDeskClienteApp({super.key});

  @override
  State<ForgeDeskClienteApp> createState() => _ForgeDeskClienteAppState();
}

class _ForgeDeskClienteAppState extends State<ForgeDeskClienteApp> {
  AuthResult? _auth;

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
      title: 'ForgeDesk Cliente',
      debugShowCheckedModeBanner: false,
      theme: _buildForgeDeskTheme(),
      home: auth == null
          ? LoginScreen(onAuthenticated: _onAuthenticated)
          : SolicitacaoListScreen(
              service: SolicitacaoService(token: auth.token),
              userName: auth.nome,
              onLogout: _logout,
            ),
    );
  }
}

ThemeData _buildForgeDeskTheme() {
  const forgeGold = Color(0xFFE0A84B);
  const ember = Color(0xFFB85C38);
  const iron = Color(0xFF211C1A);
  const charcoal = Color(0xFF15110F);

  return ThemeData(
    scaffoldBackgroundColor: charcoal,
    colorScheme: ColorScheme.fromSeed(
      seedColor: forgeGold,
      brightness: Brightness.dark,
      primary: forgeGold,
      secondary: ember,
      surface: iron,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: iron,
      foregroundColor: forgeGold,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: forgeGold,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: iron,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: forgeGold.withValues(alpha: 0.28)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: iron,
      foregroundColor: forgeGold,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: forgeGold.withValues(alpha: 0.42)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ember.withValues(alpha: 0.22),
      labelStyle: const TextStyle(
        color: forgeGold,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: forgeGold.withValues(alpha: 0.4)),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: forgeGold, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: Color(0xFFE8DFD1)),
      labelLarge: TextStyle(color: forgeGold, fontWeight: FontWeight.w700),
    ),
    useMaterial3: true,
  );
}
