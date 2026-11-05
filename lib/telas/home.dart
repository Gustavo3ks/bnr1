import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/manutencao.dart';
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
  List<Manutencao> _manutencoesAtivas = [];
  List<Manutencao> _manutencoesRecentes = [];

  @override
  void initState() {
    super.initState();
    unawaited(_carregarPainel());
  }

  Future<void> _carregarPainel() async {
    try {
      final database = DatabaseHelper.instance;
      final ativas = await database.obterManutencoesAtivas();
      final recentes = await database.obterManutencoesRecentes(limite: 4);
      final retornos = await database.contarRetornos();
      if (!mounted) return;
      setState(() {
        _manutencoesAtivas = ativas;
        _manutencoesRecentes = recentes;
        _retornosRegistrados = retornos;
      });
    } catch (_) {
      // As listas continuam acessíveis mesmo se o banco local não iniciar.
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
        return const ManutencoesPage();
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
                titulo: 'Em manutenção',
                valor: _manutencoesAtivas.length.toString(),
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
                'Manutenções recentes',
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
        if (_manutencoesRecentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma manutenção registrada.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          )
        else
          ..._manutencoesRecentes.map(
            (manutencao) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ResumoManutencao(manutencao: manutencao),
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

class _ResumoManutencao extends StatelessWidget {
  const _ResumoManutencao({required this.manutencao});
  final Manutencao manutencao;

  @override
  Widget build(BuildContext context) {
    final concluida = manutencao.status == 'Concluída';
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
                  manutencao.equipamento,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF152536),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'OS ${manutencao.numeroOs} · ${manutencao.status}',
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
