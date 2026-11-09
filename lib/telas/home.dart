import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/pedido_servico.dart';
import 'registrar_retorno.dart';
import 'telas_navegacao.dart';

const _navy = Color(0xFF123B63);
const _blue = Color(0xFF2864D7);
const _muted = Color(0xFF748396);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int _retornosRegistrados = 0;
  List<PedidoServico> _pedidosAtivas = [];
  List<PedidoServico> _pedidosRecentes = [];

  @override
  void initState() {
    super.initState();
    unawaited(_carregarPainel());
  }

  Future<void> _carregarPainel() async {
    try {
      final database = DatabaseHelper.instance;
      await database.garantirDadosDemonstracao();
      final ativas = await database.obterPedidosAtivos();
      final recentes = await database.obterPedidosRecentes(limite: 4);
      final retornos = await database.contarRetornos();
      if (!mounted) return;
      setState(() {
        _pedidosAtivas = ativas;
        _pedidosRecentes = recentes;
        _retornosRegistrados = retornos;
      });
    } catch (_) {
      // Mantém o painel acessível se a consulta remota falhar.
    }
  }

  Future<void> _abrirRegistro() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const RegistrarRetorno()),
    );
    await _carregarPainel();
  }

  void _selecionarAba(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(child: _paginaSelecionada()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selecionarAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Equipamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Manutenções',
          ),
        ],
      ),
    );
  }

  Widget _paginaSelecionada() {
    switch (_selectedIndex) {
      case 1:
        return const EquipamentosPage();
      case 2:
        return const PedidosServicoPage();
      default:
        return _paginaInicio();
    }
  }

  Widget _paginaInicio() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      children: [
        const Text(
          'Controle de manutenção',
          style: TextStyle(
            color: Color(0xFF152536),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Registre o retorno usando a foto da nota.',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _Indicador(
                titulo: 'Pedidos ativos',
                valor: _pedidosAtivas.length.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Indicador(
                titulo: 'Retornos registrados',
                valor: _retornosRegistrados.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _abrirRegistro,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Registrar retorno'),
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pedidos de serviço recentes',
                style: TextStyle(
                  color: Color(0xFF152536),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _selecionarAba(2),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        if (_pedidosRecentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhum pedido de serviço registrado.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          )
        else
          ..._pedidosRecentes.map(
            (pedido) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ResumoPedidoServico(pedido: pedido),
            ),
          ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.titulo, required this.valor});
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EBF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            color: _navy,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ResumoPedidoServico extends StatelessWidget {
  const _ResumoPedidoServico({required this.pedido});
  final PedidoServico pedido;

  @override
  Widget build(BuildContext context) {
    final concluida = pedido.status == 'concluida';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBF0)),
      ),
      child: Row(
        children: [
          Icon(
            concluida ? Icons.check_circle_outline : Icons.build_outlined,
            color: concluida ? const Color(0xFF18825B) : _navy,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.equipamento,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF152536),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pedido ${pedido.numeroPedido} · OS ${pedido.numeroOs} · ${pedido.statusLabel}',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
