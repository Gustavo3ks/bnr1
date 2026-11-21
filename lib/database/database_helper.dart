import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/pedido_servico.dart';
import '../model/nota_retorno.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const statusPendente = 'pendente';
  static const statusEmAndamento = 'em_andamento';
  static const statusConcluida = 'concluida';

  CollectionReference<Map<String, dynamic>> get _ordens =>
      _firestore.collection('ordens_servico');

  Future<void> garantirDadosDemonstracao() async {
    const numeroOs = '2026-0187';
    final ordemRef = _ordens.doc(_normalizarOs(numeroOs));
    await _firestore.runTransaction<void>((transaction) async {
      final existente = await transaction.get(ordemRef);
      if (existente.exists) return;

      final agora = DateTime.now().toIso8601String();
      transaction.set(ordemRef, {
        'numero_os': numeroOs,
        'status': statusPendente,
        'data_criacao': agora,
        'pedidos_total': 2,
        'pedidos_concluidos': 0,
      });
      transaction.set(
        ordemRef.collection('pedidos').doc('pedido-camara-fria'),
        {
          'numero_pedido': 'SOL-2026-001',
          'numero_os': numeroOs,
          'cliente': 'Mercado Central Itapetininga',
          'equipamento': 'Câmara fria comercial · CF-03',
          'servico': 'Manutenção de câmara fria',
          'status': statusPendente,
          'data_criacao': agora,
        },
      );
      transaction.set(ordemRef.collection('pedidos').doc('pedido-freezer'), {
        'numero_pedido': 'SOL-2026-002',
        'numero_os': numeroOs,
        'cliente': 'Mercado Central Itapetininga',
        'equipamento': 'Freezer horizontal · FZ-02',
        'servico': 'Avaliação do sistema de refrigeração',
        'status': statusPendente,
        'data_criacao': agora,
      });
    });
  }

  Future<String> adicionarPedido({
    required String numeroOs,
    required String numeroPedido,
    required String cliente,
    required String equipamento,
    required String servico,
  }) async {
    final ordemRef = _ordens.doc(_normalizarOs(numeroOs));
    final pedidoRef = ordemRef.collection('pedidos').doc();
    await _firestore.runTransaction<void>((transaction) async {
      final ordem = await transaction.get(ordemRef);
      if (!ordem.exists) throw StateError('A ordem de serviço não existe.');
      final dados = ordem.data()!;
      final total = (dados['pedidos_total'] as num?)?.toInt() ?? 0;
      transaction.set(pedidoRef, {
        'numero_pedido': numeroPedido.trim(),
        'numero_os': _normalizarOs(numeroOs),
        'cliente': cliente.trim(),
        'equipamento': equipamento.trim(),
        'servico': servico.trim(),
        'status': statusPendente,
        'data_criacao': DateTime.now().toIso8601String(),
      });
      transaction.update(ordemRef, {
        'pedidos_total': total + 1,
        'status': statusEmAndamento,
        'data_conclusao': FieldValue.delete(),
      });
    });
    return pedidoRef.id;
  }

  Future<List<PedidoServico>> obterPedidosAtivos() async {
    final snapshot = await _firestore.collectionGroup('pedidos').get();
    final pedidos =
        snapshot.docs
            .where((doc) => doc.data()['status'] != statusConcluida)
            .map(PedidoServico.fromFirestore)
            .toList()
          ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return pedidos;
  }

  Future<List<PedidoServico>> obterPedidosRecentes({int limite = 5}) async {
    final snapshot = await _firestore.collectionGroup('pedidos').get();
    final pedidos = snapshot.docs.map(PedidoServico.fromFirestore).toList()
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return pedidos.take(limite).toList();
  }

  Future<PedidoServico?> buscarPedidoAtivoPorOs(String numeroOs) async {
    final snapshot = await _firestore
        .collectionGroup('pedidos')
        .where('numero_os', isEqualTo: _normalizarOs(numeroOs))
        .get();
    for (final doc in snapshot.docs) {
      if (doc.data()['status'] != statusConcluida) {
        return PedidoServico.fromFirestore(doc);
      }
    }
    return null;
  }

  Future<int> contarRetornos() async {
    final snapshot = await _firestore
        .collectionGroup('notas_retorno')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<String> registrarRetorno({
    required PedidoServico pedido,
    required NotaRetornoExtraida nota,
    required bool equipamentoFuncionando,
  }) async {
    final pedidoRef = _ordens
        .doc(pedido.ordemServicoId)
        .collection('pedidos')
        .doc(pedido.id);
    final ordemRef = _ordens.doc(pedido.ordemServicoId);
    final retornoRef = pedidoRef.collection('notas_retorno').doc('retorno');
    final ano = DateTime.now().year;
    final contadorRef = _firestore
        .collection('contadores')
        .doc('retornos_$ano');
    return _firestore.runTransaction<String>((transaction) async {
      final ordem = await transaction.get(ordemRef);
      final pedidoSnapshot = await transaction.get(pedidoRef);
      final retorno = await transaction.get(retornoRef);
      final contador = await transaction.get(contadorRef);

      if (!ordem.exists || !pedidoSnapshot.exists) {
        throw StateError('A OS ou o pedido não existe mais.');
      }
      if (retorno.exists ||
          pedidoSnapshot.data()?['status'] == statusConcluida) {
        throw StateError('Este pedido já possui uma nota de retorno.');
      }

      final ordemData = ordem.data()!;
      final totalPedidos = (ordemData['pedidos_total'] as num?)?.toInt() ?? 1;
      final concluidos =
          (ordemData['pedidos_concluidos'] as num?)?.toInt() ?? 0;
      final novoTotal = concluidos + 1;
      final ordemConcluida = novoTotal >= totalPedidos;
      final sequencia = ((contador.data()?['valor'] as num?)?.toInt() ?? 0) + 1;
      final protocolo = 'RET-$ano-${sequencia.toString().padLeft(4, '0')}';
      final agora = DateTime.now().toIso8601String();

      transaction.set(retornoRef, {
        'protocolo': protocolo,
        'pedido_id': pedido.id,
        'numero_pedido': pedido.numeroPedido,
        'ordem_servico_id': pedido.ordemServicoId,
        'numero_os': _normalizarOs(nota.numeroOs),
        'data_retorno': nota.dataRetorno,
        'cliente': nota.cliente.trim(),
        'equipamento': nota.equipamento.trim(),
        'servico': nota.servico.trim(),
        'situacao_nota': nota.situacao.trim(),
        'observacao': nota.observacao.trim(),
        'equipamento_funcionando': equipamentoFuncionando,
        'texto_ocr': nota.textoOriginal,
        'data_registro': agora,
      });
      transaction.update(pedidoRef, {
        'status': statusConcluida,
        'data_conclusao': agora,
      });
      transaction.update(ordemRef, {
        'pedidos_concluidos': novoTotal,
        'status': ordemConcluida ? statusConcluida : statusEmAndamento,
        if (ordemConcluida) 'data_conclusao': agora,
      });
      transaction.set(contadorRef, {'valor': sequencia});
      return protocolo;
    });
  }

  String _normalizarOs(String numeroOs) {
    return numeroOs
        .trim()
        .toUpperCase()
        .replaceFirst(
          RegExp(r'^(?:N[º°.]?\s*(?:DA\s*)?OS|OS)\s*[:#\-]?\s*'),
          '',
        )
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'\s+'), '');
  }
}
