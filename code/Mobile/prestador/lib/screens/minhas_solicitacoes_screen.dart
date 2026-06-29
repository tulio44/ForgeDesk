import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prestador/models/solicitacao.dart';
import 'package:prestador/screens/oportunidade_detail_screen.dart';
import 'package:prestador/services/solicitacao_service.dart';
import 'package:prestador/widgets/oportunidade_card.dart';

class MinhasSolicitacoesScreen extends StatefulWidget {
  MinhasSolicitacoesScreen({
    super.key,
    SolicitacaoService? service,
    this.enablePolling = true,
  }) : service = service ?? SolicitacaoService();

  final SolicitacaoService service;
  final bool enablePolling;

  @override
  State<MinhasSolicitacoesScreen> createState() =>
      _MinhasSolicitacoesScreenState();
}

class _MinhasSolicitacoesScreenState extends State<MinhasSolicitacoesScreen> {
  late Future<List<Solicitacao>> _solicitacoesFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _solicitacoesFuture = _carregarSolicitacoes();
    _iniciarPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<List<Solicitacao>> _carregarSolicitacoes() async {
    final solicitacoes = await widget.service.listarSolicitacoes();

    return solicitacoes.where((solicitacao) {
      final status = solicitacao.status.toUpperCase();
      return solicitacao.prestadorId == 1 &&
          (status == 'ACEITA' || status == 'EM_ANDAMENTO');
    }).toList();
  }

  void _iniciarPolling() {
    if (!widget.enablePolling) {
      return;
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _atualizarSolicitacoes();
    });
  }

  void _atualizarSolicitacoes() {
    if (!mounted) {
      return;
    }

    setState(() {
      _solicitacoesFuture = _carregarSolicitacoes();
    });
  }

  Future<void> _abrirDetalhes(Solicitacao solicitacao) async {
    final id = solicitacao.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitacao sem id para abrir detalhes.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => OportunidadeDetailScreen(
          solicitacaoId: id,
          service: widget.service,
          enablePolling: widget.enablePolling,
        ),
      ),
    );

    _atualizarSolicitacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        actions: [
          IconButton(
            onPressed: _atualizarSolicitacoes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<Solicitacao>>(
        future: _solicitacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nao foi possivel carregar suas solicitacoes.'),
              ),
            );
          }

          final solicitacoes = snapshot.data ?? [];

          if (solicitacoes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhuma solicitacao assumida encontrada.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _atualizarSolicitacoes(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: solicitacoes.length,
              itemBuilder: (context, index) {
                return OportunidadeCard(
                  solicitacao: solicitacoes[index],
                  onTap: () => _abrirDetalhes(solicitacoes[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
