import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import '../utils/formatters.dart';
import '../utils/reference_image.dart';

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
        _errorMessage = 'Não foi possível carregar a solicitação.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da solicitação'),
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
      return const Center(child: Text('Solicitação não encontrada.'));
    }

    final referenceContent = parseReferenceContent(solicitacao.referencia);
    final referenceImage = decodeReferenceImage(referenceContent.imageDataUri);

    return ListView(
      children: [
        _DetailCover(solicitacao: solicitacao, referenceImage: referenceImage),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailRow(label: 'Descrição', value: solicitacao.descricao),
              _DetailRow(
                label: 'Tipo de serviço',
                value: formatarTipoServico(solicitacao.tipoServico),
              ),
              if (referenceContent.hasText || referenceImage != null)
                _ReferenceDetailCard(
                  referenceContent: referenceContent,
                  hasCoverImage: referenceImage != null,
                ),
              _DetailRow(
                label: 'Criado em',
                value: formatarDataHora(solicitacao.criadoEm),
              ),
              _DetailRow(
                label: 'Atualizado em',
                value: formatarDataHora(solicitacao.atualizadoEm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailCover extends StatelessWidget {
  const _DetailCover({required this.solicitacao, required this.referenceImage});

  final Solicitacao solicitacao;
  final Uint8List? referenceImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = referenceImage != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 320),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? Image.memory(
                    referenceImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _CoverFallback(),
                  )
                : const _CoverFallback(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: hasImage ? 0.50 : 0.10),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CoverChip(
                        icon: Icons.info_outline,
                        label: solicitacao.status,
                      ),
                      _CoverChip(
                        icon: Icons.work_outline,
                        label: formatarTipoServico(solicitacao.tipoServico),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    solicitacao.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final metricWidth = (constraints.maxWidth - 10) / 2;

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _MetricPill(
                            width: metricWidth,
                            icon: Icons.payments_outlined,
                            label: 'Orçamento',
                            value: formatarMoeda(solicitacao.orcamento),
                          ),
                          _MetricPill(
                            width: metricWidth,
                            icon: Icons.event_outlined,
                            label: 'Prazo',
                            value: formatarData(solicitacao.prazo),
                          ),
                        ],
                      );
                    },
                  ),
                  if (!hasImage) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Sem imagem de referência',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Icon(
            Icons.assignment_outlined,
            size: 96,
            color: colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
      ),
    );
  }
}

class _CoverChip extends StatelessWidget {
  const _CoverChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width.clamp(140, 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.92),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.42),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.72),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForLabel(label),
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    return switch (label) {
      'Descrição' => Icons.notes_outlined,
      'Tipo de serviço' => Icons.work_outline,
      'Criado em' => Icons.add_circle_outline,
      'Atualizado em' => Icons.update,
      _ => Icons.label_outline,
    };
  }
}

class _ReferenceDetailCard extends StatelessWidget {
  const _ReferenceDetailCard({
    required this.referenceContent,
    required this.hasCoverImage,
  });

  final ReferenceContent referenceContent;
  final bool hasCoverImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.collections_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referências',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  if (hasCoverImage)
                    _ReferenceBadge(
                      icon: Icons.image_outlined,
                      text: 'Imagem anexada exibida na capa',
                    ),
                  if (hasCoverImage && referenceContent.hasText)
                    const SizedBox(height: 10),
                  if (referenceContent.hasText)
                    Text(
                      formatarTexto(referenceContent.text),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceBadge extends StatelessWidget {
  const _ReferenceBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
