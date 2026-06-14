import 'dart:async';

import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';

class SolicitacaoDetailScreen extends StatefulWidget {
  SolicitacaoDetailScreen({
    super.key,
    required this.solicitacaoId,
    SolicitacaoService? service,
    this.enablePolling = true,
  }) : service = service ?? SolicitacaoService();

  final int solicitacaoId;
  final SolicitacaoService service;
  final bool enablePolling;

  @override
  State<SolicitacaoDetailScreen> createState() =>
      _SolicitacaoDetailScreenState();
}

class _SolicitacaoDetailScreenState extends State<SolicitacaoDetailScreen> {
  Timer? _timer;
  Solicitacao? _solicitacao;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacao();

    if (widget.enablePolling) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        _carregarSolicitacao(silent: true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarSolicitacao({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final solicitacao = await widget.service.buscarSolicitacaoPorId(
        widget.solicitacaoId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _solicitacao = solicitacao;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Nao foi possivel carregar a solicitacao.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrato da forja'),
        actions: [
          IconButton(
            onPressed: _carregarSolicitacao,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
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

    final solicitacao = _solicitacao;
    if (solicitacao == null) {
      return const Center(child: Text('Solicitacao nao encontrada.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    solicitacao.titulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _DetailRow(label: 'ID', value: _formatarValor(solicitacao.id)),
        _DetailRow(label: 'Pedido', value: solicitacao.descricao),
        _DetailRow(label: 'Oficio', value: solicitacao.tipoServico),
        _DetailRow(
          label: 'Recompensa',
          value: _formatarOrcamento(solicitacao.orcamento),
        ),
        _DetailRow(label: 'Prazo', value: _formatarData(solicitacao.prazo)),
        _DetailRow(
          label: 'Referencia arcana',
          value: _formatarValor(solicitacao.referencia),
        ),
        _DetailRow(label: 'Status', value: solicitacao.status),
        _DetailRow(label: 'Cliente ID', value: '${solicitacao.clienteId}'),
        _DetailRow(
          label: 'Prestador ID',
          value: _formatarValor(solicitacao.prestadorId),
        ),
        _DetailRow(
          label: 'Criado em',
          value: _formatarDataHora(solicitacao.criadoEm),
        ),
        _DetailRow(
          label: 'Atualizado em',
          value: _formatarDataHora(solicitacao.atualizadoEm),
        ),
      ],
    );
  }

  String _formatarValor(Object? value) {
    if (value == null || value == '') {
      return 'Nao informado';
    }

    return value.toString();
  }

  String _formatarOrcamento(double? valor) {
    if (valor == null) {
      return 'Nao informado';
    }

    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  String _formatarData(DateTime? data) {
    if (data == null) {
      return 'Nao informado';
    }

    return data.toIso8601String().split('T').first;
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) {
      return 'Nao informado';
    }

    return data.toLocal().toString();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
