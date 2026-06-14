class Solicitacao {
  const Solicitacao({
    this.id,
    required this.clienteId,
    this.prestadorId,
    required this.titulo,
    required this.descricao,
    required this.tipoServico,
    this.orcamento,
    this.prazo,
    this.referencia,
    required this.status,
    this.criadoEm,
    this.atualizadoEm,
  });

  final int? id;
  final int clienteId;
  final int? prestadorId;
  final String titulo;
  final String descricao;
  final String tipoServico;
  final double? orcamento;
  final DateTime? prazo;
  final String? referencia;
  final String status;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      id: json['id'] as int?,
      clienteId: json['cliente_id'] as int,
      prestadorId: json['prestador_id'] as int?,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      tipoServico: json['tipo_servico'] as String,
      orcamento: (json['orcamento'] as num?)?.toDouble(),
      prazo: _parseDateTime(json['prazo']),
      referencia: json['referencia'] as String?,
      status: json['status'] as String,
      criadoEm: _parseDateTime(json['criado_em']),
      atualizadoEm: _parseDateTime(json['atualizado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'prestador_id': prestadorId,
      'titulo': titulo,
      'descricao': descricao,
      'tipo_servico': tipoServico,
      'orcamento': orcamento,
      'prazo': _formatDate(prazo),
      'referencia': referencia,
      'status': status,
      'criado_em': criadoEm?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value as String);
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }

    return value.toIso8601String().split('T').first;
  }
}
