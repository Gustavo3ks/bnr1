import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoServico {
  const PedidoServico({
    required this.id,
    required this.ordemServicoId,
    required this.numeroPedido,
    required this.numeroOs,
    required this.cliente,
    required this.equipamento,
    required this.servico,
    required this.status,
    required this.dataCriacao,
    this.dataConclusao,
  });

  final String id;
  final String ordemServicoId;
  final String numeroPedido;
  final String numeroOs;
  final String cliente;
  final String equipamento;
  final String servico;
  final String status;
  final String dataCriacao;
  final String? dataConclusao;

  String get statusLabel {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'em_andamento':
        return 'Em andamento';
      case 'concluida':
        return 'Concluída';
      default:
        return status;
    }
  }

  factory PedidoServico.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final ordemServico = document.reference.parent.parent;
    return PedidoServico(
      id: document.id,
      ordemServicoId: ordemServico?.id ?? '',
      numeroPedido: (data['numero_pedido'] as String?) ?? document.id,
      numeroOs: (data['numero_os'] as String?) ?? '',
      cliente: (data['cliente'] as String?) ?? '',
      equipamento: (data['equipamento'] as String?) ?? '',
      servico: (data['servico'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pendente',
      dataCriacao: (data['data_criacao'] as String?) ?? '',
      dataConclusao: data['data_conclusao'] as String?,
    );
  }
}
