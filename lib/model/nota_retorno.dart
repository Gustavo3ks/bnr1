class NotaRetornoExtraida {
  const NotaRetornoExtraida({
    required this.numeroOs,
    required this.dataRetorno,
    required this.cliente,
    required this.equipamento,
    required this.servico,
    required this.situacao,
    required this.observacao,
    required this.textoOriginal,
  });

  final String numeroOs;
  final String dataRetorno;
  final String cliente;
  final String equipamento;
  final String servico;
  final String situacao;
  final String observacao;
  final String textoOriginal;

  List<String> get camposObrigatoriosAusentes => [
    if (numeroOs.trim().isEmpty) 'Número da OS',
    if (dataRetorno.trim().isEmpty) 'Data',
    if (cliente.trim().isEmpty) 'Cliente',
    if (equipamento.trim().isEmpty) 'Equipamento',
    if (servico.trim().isEmpty) 'Serviço realizado',
  ];
}
