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
    this.userName,
    this.onLogout,
    this.enablePolling = true,
  }) : service = service ?? SolicitacaoService();

  final SolicitacaoService service;
  final String? userName;
  final VoidCallback? onLogout;
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
        _errorMessage = 'Não foi possível carregar as solicitações.';
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
        const SnackBar(
          content: Text('Não foi possível abrir esta solicitação.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SolicitacaoDetailScreen(solicitacaoId: id, service: widget.service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForgeDesk'),
        actions: [
          if (widget.userName != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  widget.userName!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          IconButton(
            onPressed: _carregarSolicitacoes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          if (widget.onLogout != null)
            IconButton(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCriacao,
        tooltip: 'Nova solicitação',
        child: const Icon(Icons.post_add),
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
      return const Center(child: Text('Nenhuma solicitação cadastrada.'));
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
            'Solicitações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Acompanhe os serviços solicitados e seus status.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
