import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/pedido_servico.dart';

const _muted = Color(0xFF748396);
const _navy = Color(0xFF123B63);

class EquipamentosPage extends StatelessWidget {
  const EquipamentosPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(title: const Text('Equipamentos')),
    body: FutureBuilder<List<PedidoServico>>(
      future: DatabaseHelper.instance.obterPedidosRecentes(limite: 100),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const _Aviso(
            texto: 'Não foi possível carregar os equipamentos.',
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final unicos = <String, PedidoServico>{};
        for (final item in snapshot.data!) {
          unicos.putIfAbsent(item.equipamento, () => item);
        }
        if (unicos.isEmpty)
          return const _Aviso(texto: 'Nenhum equipamento cadastrado.');
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: unicos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = unicos.values.elementAt(index);
            return _Linha(
              titulo: item.equipamento,
              detalhe: '${item.cliente} · OS ${item.numeroOs}',
              status: item.statusLabel,
            );
          },
        );
      },
    ),
  );
}

class PedidosServicoPage extends StatelessWidget {
  const PedidosServicoPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(title: const Text('Pedidos de serviço')),
    body: FutureBuilder<List<PedidoServico>>(
      future: DatabaseHelper.instance.obterPedidosRecentes(limite: 100),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const _Aviso(
            texto: 'Não foi possível carregar os pedidos de serviço.',
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final itens = snapshot.data!;
        if (itens.isEmpty)
          return const _Aviso(texto: 'Nenhum pedido de serviço registrado.');
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: itens.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = itens[index];
            return _Linha(
              titulo: 'Pedido ${item.numeroPedido}',
              detalhe:
                  'OS ${item.numeroOs} · ${item.equipamento} · ${item.cliente}',
              status: item.statusLabel,
            );
          },
        );
      },
    ),
  );
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.titulo,
    required this.detalhe,
    required this.status,
  });
  final String titulo;
  final String detalhe;
  final String status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EBF0)),
    ),
    child: Row(
      children: [
        const Icon(Icons.build_outlined, color: _navy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF152536),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detalhe,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: _navy, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});
  final String texto;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted),
      ),
    ),
  );
}
