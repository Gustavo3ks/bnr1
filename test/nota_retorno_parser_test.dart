import 'package:flutter_test/flutter_test.dart';
import 'package:bnr1/control/nota_retorno_parser.dart';

void main() {
  const parser = NotaRetornoParser();

  test('extrai campos da nota com rótulos em português', () {
    final nota = parser.parse('''
OS: 2026-0187
DATA DO RETORNO: 21/11/2026
CLIENTE: Mercado Central
EQUIPAMENTO: Câmara fria CF-03
SERVIÇO REALIZADO: Troca do termostato
SITUAÇÃO: Concluído
OBSERVAÇÃO: Teste de temperatura realizado
''');

    expect(nota.numeroOs, '2026-0187');
    expect(nota.dataRetorno, '21/11/2026');
    expect(nota.cliente, 'Mercado Central');
    expect(nota.equipamento, 'Câmara fria CF-03');
    expect(nota.servico, 'Troca do termostato');
    expect(nota.situacao, 'Concluído');
    expect(nota.observacao, 'Teste de temperatura realizado');
    expect(nota.camposObrigatoriosAusentes, isEmpty);
  });

  test('retorna campos vazios quando o texto não contém uma nota', () {
    final nota = parser.parse('Documento sem dados reconhecíveis.');

    expect(nota.numeroOs, isEmpty);
    expect(nota.dataRetorno, isEmpty);
    expect(
      nota.camposObrigatoriosAusentes,
      containsAll([
        'Número da OS',
        'Data',
        'Cliente',
        'Equipamento',
        'Serviço realizado',
      ]),
    );
  });
}
