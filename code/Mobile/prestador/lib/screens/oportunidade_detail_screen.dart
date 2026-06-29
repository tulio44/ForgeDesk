import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prestador/models/solicitacao.dart';
import 'package:prestador/services/solicitacao_service.dart';

class OportunidadeDetailScreen extends StatefulWidget {
  OportunidadeDetailScreen({
    super.key,
    required this.solicitacaoId,
    SolicitacaoService? service,
    this.enablePolling = true,
  }) : service = service ?? SolicitacaoService();

  final int solicitacaoId;
  final SolicitacaoService service;
  final bool enablePolling;

  @override
  State<OportunidadeDetailScreen> createState() =>
      _OportunidadeDetailScreenState();
}

class _OportunidadeDetailScreenState extends State<OportunidadeDetailScreen> {
  late Future<Solicitacao> _solicitacaoFuture;
  Timer? _pollingTimer;
  bool _aceitando = false;

  @override
  void initState() {
    super.initState();
    _solicitacaoFuture = _carregarSolicitacao();
    _iniciarPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<Solicitacao> _carregarSolicitacao() {
    return widget.service.buscarSolicitacaoPorId(widget.solicitacaoId);
  }

  void _iniciarPolling() {
    if (!widget.enablePolling) {
      return;
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _atualizarDetalhes();
    });
  }

  void _atualizarDetalhes() {
    if (!mounted) {
      return;
    }

    setState(() {
      _solicitacaoFuture = _carregarSolicitacao();
    });
  }

  Future<void> _aceitarSolicitacao() async {
    setState(() {
      _aceitando = true;
    });

    try {
      await widget.service.atualizarStatus(
        id: widget.solicitacaoId,
        status: 'ACEITA',
        prestadorId: 1,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitacao aceita com sucesso.')),
      );

      setState(() {
        _solicitacaoFuture = _carregarSolicitacao();
      });
    } on Exception {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel aceitar a solicitacao.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aceitando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da oportunidade'),
        actions: [
          IconButton(
            onPressed: _aceitando ? null : _atualizarDetalhes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<Solicitacao>(
        future: _solicitacaoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nao foi possivel carregar a oportunidade.'),
              ),
            );
          }

          final solicitacao = snapshot.requireData;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusHeader(status: solicitacao.status),
              const SizedBox(height: 16),
              _DetailLine(label: 'Id', value: solicitacao.id?.toString()),
              _DetailLine(label: 'Titulo', value: solicitacao.titulo),
              _DetailLine(label: 'Descricao', value: solicitacao.descricao),
              _DetailLine(
                label: 'Tipo de servico',
                value: solicitacao.tipoServico,
              ),
              _DetailLine(
                label: 'Orcamento',
                value: _formatOrcamento(solicitacao),
              ),
              _DetailLine(label: 'Prazo', value: solicitacao.prazo),
              _DetailLine(label: 'Referencia', value: solicitacao.referencia),
              _DetailLine(label: 'Status', value: solicitacao.status),
              _DetailLine(
                label: 'ClienteId',
                value: solicitacao.clienteId.toString(),
              ),
              _DetailLine(
                label: 'PrestadorId',
                value: solicitacao.prestadorId?.toString(),
              ),
              _DetailLine(label: 'CriadoEm', value: solicitacao.criadoEm),
              _DetailLine(
                label: 'AtualizadoEm',
                value: solicitacao.atualizadoEm,
              ),
              const SizedBox(height: 24),
              if (solicitacao.status.toUpperCase() == 'PENDENTE')
                FilledButton(
                  onPressed: _aceitando ? null : _aceitarSolicitacao,
                  child: _aceitando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Aceitar solicitacao'),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatOrcamento(Solicitacao solicitacao) {
    final orcamento = solicitacao.orcamento;

    if (orcamento == null) {
      return 'Nao informado';
    }

    return 'R\$ ${orcamento.toStringAsFixed(2)}';
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(status),
        backgroundColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value?.isNotEmpty == true ? value! : 'Nao informado'),
        ],
      ),
    );
  }
}
