import 'package:flutter/material.dart';

import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';

class SolicitacaoCreateScreen extends StatefulWidget {
  SolicitacaoCreateScreen({super.key, SolicitacaoService? service})
    : service = service ?? SolicitacaoService();

  final SolicitacaoService service;

  @override
  State<SolicitacaoCreateScreen> createState() =>
      _SolicitacaoCreateScreenState();
}

class _SolicitacaoCreateScreenState extends State<SolicitacaoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _tipoServicoController = TextEditingController();
  final _orcamentoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _prazoController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _tipoServicoController.dispose();
    _orcamentoController.dispose();
    _referenciaController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarPrazo() async {
    final now = DateTime.now();
    final prazo = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (prazo == null) {
      return;
    }

    _prazoController.text = _formatarData(prazo);
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final solicitacao = Solicitacao(
      clienteId: 1,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      tipoServico: _tipoServicoController.text.trim(),
      orcamento: _parseOrcamento(_orcamentoController.text),
      referencia: _nullIfEmpty(_referenciaController.text),
      prazo: _parsePrazo(_prazoController.text),
      status: 'PENDENTE',
    );

    try {
      await widget.service.criarSolicitacao(solicitacao);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitacao forjada com sucesso.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar solicitacao.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forjar solicitacao')),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Novo contrato',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Descreva o pedido para que a guilda possa avaliar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Titulo'),
                textInputAction: TextInputAction.next,
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descricao'),
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.next,
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoServicoController,
                decoration: const InputDecoration(labelText: 'Tipo de servico'),
                textInputAction: TextInputAction.next,
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orcamentoController,
                decoration: const InputDecoration(labelText: 'Orcamento'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: _validarOrcamento,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(labelText: 'Referencia'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prazoController,
                decoration: InputDecoration(
                  labelText: 'Prazo opcional',
                  suffixIcon: IconButton(
                    onPressed: _selecionarPrazo,
                    icon: const Icon(Icons.calendar_month),
                    tooltip: 'Selecionar prazo',
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _enviarFormulario,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.local_fire_department),
                label: Text(_isSubmitting ? 'Forjando...' : 'Forjar contrato'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio.';
    }

    return null;
  }

  String? _validarOrcamento(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    if (_parseOrcamento(text) == null) {
      return 'Informe um numero valido.';
    }

    return null;
  }

  double? _parseOrcamento(String value) {
    final text = value.trim().replaceAll(',', '.');
    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  DateTime? _parsePrazo(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  String? _nullIfEmpty(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  String _formatarData(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
