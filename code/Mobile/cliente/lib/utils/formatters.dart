String formatarMoeda(double? valor) {
  if (valor == null) {
    return 'Não informado';
  }

  final negativo = valor < 0;
  final centavos = (valor.abs() * 100).round();
  final reais = centavos ~/ 100;
  final centavosTexto = (centavos % 100).toString().padLeft(2, '0');
  final reaisTexto = _formatarMilhares(reais);

  return '${negativo ? '-' : ''}R\$ $reaisTexto,$centavosTexto';
}

String formatarData(DateTime? data) {
  if (data == null) {
    return 'Não informado';
  }

  return [
    data.day.toString().padLeft(2, '0'),
    data.month.toString().padLeft(2, '0'),
    data.year.toString(),
  ].join('/');
}

String formatarDataHora(DateTime? data) {
  if (data == null) {
    return 'Não informado';
  }

  final local = data.toLocal();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');

  return '${formatarData(local)} $hora:$minuto';
}

String formatarTexto(String? valor) {
  final texto = valor?.trim() ?? '';

  if (texto.isEmpty) {
    return 'Não informado';
  }

  return texto;
}

String formatarTipoServico(String tipoServico) {
  return switch (tipoServico) {
    'Ilustracao' => 'Ilustração',
    'Edicao de video' => 'Edição de vídeo',
    'Identidade visual' => 'Identidade visual',
    'Modelagem 3D' => 'Modelagem 3D',
    'Social media' => 'Social media',
    'Motion graphics' => 'Motion graphics',
    'UI/UX' => 'UI/UX',
    _ => tipoServico,
  };
}

String _formatarMilhares(int valor) {
  final texto = valor.toString();
  final partes = <String>[];

  for (var index = texto.length; index > 0; index -= 3) {
    final inicio = (index - 3).clamp(0, texto.length);
    partes.insert(0, texto.substring(inicio, index));
  }

  return partes.join('.');
}
