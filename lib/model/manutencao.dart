class Manutencao {
  const Manutencao({
    this.id,
    required this.numeroOs,
    required this.cliente,
    required this.equipamento,
    required this.servico,
    required this.status,
    required this.dataCriacao,
    this.dataConclusao,
  });

  final int? id;
  final String numeroOs;
  final String cliente;
  final String equipamento;
  final String servico;
  final String status;
  final String dataCriacao;
  final String? dataConclusao;

  factory Manutencao.fromMap(Map<String, Object?> map) {
    return Manutencao(
      id: map['id'] as int?,
      numeroOs: map['numero_os'] as String,
      cliente: map['cliente'] as String,
      equipamento: map['equipamento'] as String,
      servico: map['servico'] as String,
      status: map['status'] as String,
      dataCriacao: map['data_criacao'] as String,
      dataConclusao: map['data_conclusao'] as String?,
    );
  }
}
