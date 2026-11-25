import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/pedido_servico.dart';
import 'registrar_manutencao.dart';

const _muted = Color(0xFF748396);
const _navy = Color(0xFF123B63);

class EquipamentosPage extends StatefulWidget {
  const EquipamentosPage({
    super.key,
    this.onCadastroConcluido,
    this.carregarEquipamentos,
  });

  final Future<void> Function()? onCadastroConcluido;
  final Future<List<Map<String, dynamic>>> Function()? carregarEquipamentos;

  @override
  State<EquipamentosPage> createState() => _EquipamentosPageState();
}

class _EquipamentosPageState extends State<EquipamentosPage> {
  late Future<List<Map<String, dynamic>>> _equipamentos;

  @override
  void initState() {
    super.initState();
    _equipamentos =
        widget.carregarEquipamentos?.call() ??
        DatabaseHelper.instance.obterEquipamentos();
  }

  Future<void> _abrirCadastro() async {
    final cadastrado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const RegistrarManutencao()),
    );
    if (cadastrado != true || !mounted) return;
    setState(() => _equipamentos = DatabaseHelper.instance.obterEquipamentos());
    await widget.onCadastroConcluido?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Equipamento e manutenção cadastrados.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(title: const Text('Equipamentos')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _abrirCadastro,
      icon: const Icon(Icons.add),
      label: const Text('Cadastrar'),
      backgroundColor: const Color(0xFF2864D7),
      foregroundColor: Colors.white,
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _equipamentos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _Aviso(
            texto: 'Não foi possível carregar os equipamentos.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final itens = snapshot.data!;
        if (itens.isEmpty) {
          return const _Aviso(
            texto: 'Nenhum equipamento cadastrado. Toque em Cadastrar para abrir uma manutenção.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          itemCount: itens.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _EquipamentoCard(item: itens[index]),
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
        if (snapshot.hasError) {
          return const _Aviso(
            texto: 'Não foi possível carregar os pedidos de serviço.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final itens = snapshot.data!;
        if (itens.isEmpty) {
          return const _Aviso(texto: 'Nenhum pedido de serviço registrado.');
        }
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
              status: '${item.statusLabel} · Prioridade ${item.prioridade}',
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

class _EquipamentoCard extends StatelessWidget {
  const _EquipamentoCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final nome = item['nome'] as String? ?? 'Equipamento';
    final cliente = item['cliente'] as String? ?? '';
    final modelo = item['modelo'] as String? ?? '';
    final serie = item['numero_serie'] as String? ?? '';
    final local = item['local_instalacao'] as String? ?? '';
    final os = item['ultima_os'] as String? ?? item['numero_os'] as String?;
    final detalhes = [
      if (modelo.isNotEmpty) modelo,
      if (serie.isNotEmpty) 'Série $serie',
      if (local.isNotEmpty) local,
      if (os != null && os.isNotEmpty) 'OS $os',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBF0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.precision_manufacturing_outlined, color: _navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF152536),
                  ),
                ),
                if (cliente.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    cliente,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
                if (detalhes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    detalhes.join(' · '),
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
