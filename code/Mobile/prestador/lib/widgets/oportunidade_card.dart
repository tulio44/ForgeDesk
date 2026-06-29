import 'package:flutter/material.dart';
import 'package:prestador/models/solicitacao.dart';

class OportunidadeCard extends StatelessWidget {
  const OportunidadeCard({
    super.key,
    required this.solicitacao,
    required this.onTap,
  });

  final Solicitacao solicitacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      solicitacao.titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(solicitacao.status),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoLine(label: 'Tipo', value: solicitacao.tipoServico),
              _InfoLine(label: 'Orcamento', value: _formatOrcamento()),
              _InfoLine(
                label: 'Prazo',
                value: solicitacao.prazo ?? 'Nao informado',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOrcamento() {
    final orcamento = solicitacao.orcamento;

    if (orcamento == null) {
      return 'Nao informado';
    }

    return 'R\$ ${orcamento.toStringAsFixed(2)}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label: $value'),
    );
  }
}
