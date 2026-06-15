import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import '../utils/reference_image.dart';

class SolicitacaoCreateScreen extends StatefulWidget {
  SolicitacaoCreateScreen({super.key, SolicitacaoService? service})
    : service = service ?? SolicitacaoService();

  final SolicitacaoService service;

  @override
  State<SolicitacaoCreateScreen> createState() =>
      _SolicitacaoCreateScreenState();
}

class _SolicitacaoCreateScreenState extends State<SolicitacaoCreateScreen> {
  static const _tiposServico = [
    'Design',
    'Ilustração',
    'Edição de vídeo',
    'Identidade visual',
    'Modelagem 3D',
    'Social media',
    'Motion graphics',
    'UI/UX',
  ];

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _orcamentoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _prazoController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _tipoServicoSelecionado;
  Uint8List? _referenciaImagemBytes;
  String? _referenciaImagemDataUri;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
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

  Future<void> _selecionarImagemReferencia() async {
    final imagem = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );

    if (imagem == null) {
      return;
    }

    final bytes = await imagem.readAsBytes();
    final mimeType = imagem.mimeType ?? _mimeTypeFromPath(imagem.name);

    setState(() {
      _referenciaImagemBytes = bytes;
      _referenciaImagemDataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
    });
  }

  void _removerImagemReferencia() {
    setState(() {
      _referenciaImagemBytes = null;
      _referenciaImagemDataUri = null;
    });
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
      tipoServico: _tipoServicoSelecionado!,
      orcamento: _parseOrcamento(_orcamentoController.text),
      referencia: buildReferencePayload(
        text: _referenciaController.text,
        imageDataUri: _referenciaImagemDataUri,
      ),
      prazo: _parsePrazo(_prazoController.text),
      status: 'PENDENTE',
    );

    try {
      await widget.service.criarSolicitacao(solicitacao);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação criada com sucesso.')),
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
        const SnackBar(content: Text('Erro ao criar solicitação.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova solicitação')),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Nova solicitação',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os dados do serviço que você precisa contratar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                textInputAction: TextInputAction.next,
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.next,
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoServicoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo de serviço'),
                items: _tiposServico
                    .map(
                      (tipo) =>
                          DropdownMenuItem(value: tipo, child: Text(tipo)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoServicoSelecionado = value;
                  });
                },
                validator: _validarObrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orcamentoController,
                decoration: const InputDecoration(labelText: 'Orçamento'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: _validarOrcamento,
              ),
              const SizedBox(height: 12),
              _ReferenceSection(
                textController: _referenciaController,
                imageBytes: _referenciaImagemBytes,
                onPick: _selecionarImagemReferencia,
                onRemove: _removerImagemReferencia,
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
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Enviando...' : 'Criar solicitação',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório.';
    }

    return null;
  }

  String? _validarOrcamento(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    if (_parseOrcamento(text) == null) {
      return 'Informe um número válido.';
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

  String _formatarData(DateTime value) {
    return value.toIso8601String().split('T').first;
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }
}

class _ReferenceSection extends StatelessWidget {
  const _ReferenceSection({
    required this.textController,
    required this.imageBytes,
    required this.onPick,
    required this.onRemove,
  });

  final TextEditingController textController;
  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Referências',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (imageBytes != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                    tooltip: 'Remover imagem',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Use o texto para explicar a direção visual e a imagem como apoio.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Orientação textual',
                hintText: 'Ex.: cores, estilo, composição, referências...',
              ),
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.next,
            ),
            if (imageBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.memory(imageBytes!, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_file),
              label: Text(
                imageBytes == null ? 'Anexar imagem' : 'Trocar imagem',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
