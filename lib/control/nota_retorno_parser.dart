import '../model/nota_retorno.dart';

class NotaRetornoParser {
  const NotaRetornoParser();

  NotaRetornoExtraida parse(String texto) {
    final linhas = texto
        .split(RegExp(r'\r?\n'))
        .map((linha) => linha.trim())
        .where((linha) => linha.isNotEmpty)
        .toList();

    final numeroOs = _extrairNumeroOs(texto);
    final dataRetorno = _extrairData(texto);

    return NotaRetornoExtraida(
      numeroOs: numeroOs,
      dataRetorno: dataRetorno,
      cliente: _extrairCampo(
        linhas,
        RegExp(r'^\s*(?:CLIENTE|SOLICITANTE)\s*[:=\-]?\s*(.+?)\s*$'),
      ),
      equipamento: _extrairCampo(
        linhas,
        RegExp(r'^\s*EQUIPAMENTO\s*[:=\-]?\s*(.+?)\s*$'),
      ),
      servico: _extrairCampo(
        linhas,
        RegExp(
          r'^\s*(?:SERVIÇO|SERVICO)(?:\s+REALIZADO)?\s*[:=\-]?\s*(.+?)\s*$',
        ),
      ),
      situacao: _extrairCampo(
        linhas,
        RegExp(r'^\s*(?:SITUAÇÃO|SITUACAO|STATUS)\s*[:=\-]?\s*(.+?)\s*$'),
      ),
      observacao: _extrairCampo(
        linhas,
        RegExp(r'^\s*(?:OBSERVAÇÃO|OBSERVACAO|OBS\.)\s*[:=\-]?\s*(.+?)\s*$'),
      ),
      textoOriginal: texto,
    );
  }

  String _extrairNumeroOs(String texto) {
    final match = RegExp(
      r'(?:N[º°.]?\s*(?:DA\s*)?OS|ORDEM\s+DE\s+SERVIÇO|ORDEM\s+DE\s+SERVICO|OS)\s*[:#=\-]?\s*((?:\d{4}[-/]\d{3,}|\d{5,}))',
      caseSensitive: false,
    ).firstMatch(texto);
    if (match != null) return match.group(1)!.replaceAll('/', '-');

    final fallback = RegExp(r'\b(\d{4}-\d{3,})\b').firstMatch(texto);
    return fallback?.group(1) ?? '';
  }

  String _extrairData(String texto) {
    final labeled = RegExp(
      r'(?:DATA(?:\s+DO\s+RETORNO)?|EMITIDA\s+EM)\s*[:=\-]?\s*(\d{2}[./-]\d{2}[./-]\d{4})',
      caseSensitive: false,
    ).firstMatch(texto);
    final match =
        labeled ?? RegExp(r'\b(\d{2}[./-]\d{2}[./-]\d{4})\b').firstMatch(texto);
    return match?.group(1)?.replaceAll('.', '/').replaceAll('-', '/') ?? '';
  }

  String _extrairCampo(List<String> linhas, RegExp padrao) {
    for (var index = 0; index < linhas.length; index++) {
      final match = padrao.firstMatch(linhas[index]);
      if (match == null) continue;
      final valor = match.group(1)?.trim() ?? '';
      if (valor.isNotEmpty) return valor;
      if (index + 1 < linhas.length) return linhas[index + 1].trim();
    }
    return '';
  }
}
