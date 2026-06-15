import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../utils/formatters.dart';

class SolicitacaoCard extends StatelessWidget {
  const SolicitacaoCard({
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.work_outline, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      solicitacao.titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tipo de serviço: ${formatarTipoServico(solicitacao.tipoServico)}',
              ),
              const SizedBox(height: 4),
              Text('Orçamento: ${formatarMoeda(solicitacao.orcamento)}'),
              const SizedBox(height: 4),
              Text('Prazo: ${formatarData(solicitacao.prazo)}'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(solicitacao.status),
                  avatar: const Icon(Icons.info_outline, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
