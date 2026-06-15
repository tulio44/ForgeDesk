import 'dart:async';

import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import 'solicitacao_create_screen.dart';
import 'solicitacao_detail_screen.dart';
import '../widgets/solicitacao_card.dart';

class SolicitacaoListScreen extends StatefulWidget {
  SolicitacaoListScreen({
    super.key,
    SolicitacaoService? service,
    this.enablePolling = true,
  }) : service = service ?? SolicitacaoService();

  final SolicitacaoService service;
  final bool enablePolling;

  @override
  State<SolicitacaoListScreen> createState() => _SolicitacaoListScreenState();
}

class _SolicitacaoListScreenState extends State<SolicitacaoListScreen> {
  Timer? _timer;
  List<Solicitacao> _solicitacoes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();

    if (widget.enablePolling) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        _carregarSolicitacoes(silent: true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarSolicitacoes({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final solicitacoes = await widget.service.listarSolicitacoes();

      if (!mounted) {
        return;
      }

      setState(() {
        _solicitacoes = solicitacoes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Nao foi possivel carregar as solicitacoes.';
      });
    }
  }

  Future<void> _abrirCriacao() async {
    final criouSolicitacao = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SolicitacaoCreateScreen(service: widget.service),
      ),
    );

    if (criouSolicitacao == true) {
      await _carregarSolicitacoes();
    }
  }

  void _abrirSolicitacao(Solicitacao solicitacao) {
    final id = solicitacao.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitacao sem ID para abrir.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SolicitacaoDetailScreen(solicitacaoId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForgeDesk Cliente'),
        actions: [
          IconButton(
            onPressed: _carregarSolicitacoes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCriacao,
        tooltip: 'Forjar solicitacao',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_solicitacoes.isEmpty) {
      return const Center(child: Text('Nenhum contrato na forja ainda.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _solicitacoes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _ListHeader();
        }

        final solicitacao = _solicitacoes[index - 1];

        return SolicitacaoCard(
          solicitacao: solicitacao,
          onTap: () => _abrirSolicitacao(solicitacao),
        );
      },
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quadro de contratos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Pedidos criativos prontos para sair da forja.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
