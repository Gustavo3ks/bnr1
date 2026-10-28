import 'dart:async';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/manutencao.dart';
import 'registrar_retorno.dart';
import 'telas_navegacao.dart';

const _navy = Color(0xFF123B63);
const _blue = Color(0xFF2864D7);
const _background = Color(0xFFF7F8FA);
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
      // Mantém o protótipo navegável em plataformas sem suporte ao SQLite nativo.
    }
  }

  Future<void> _openReturnFlow() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RegistrarRetorno()));
    await _carregarPainel();
  }

  void _selecionarAba(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) unawaited(_carregarPainel());
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _paginaInicio(),
      const EquipamentosPage(),
      const ManutencoesPage(),
      const MaisPage(),
    ];
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: paginas),
      ),
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
            icon: Icon(Icons.sync_outlined),
            label: 'Manutenções',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }

  Widget _paginaInicio() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, equipe',
                    style: TextStyle(
                      color: Color(0xFF152536),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Controle de manutenção',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFEAF1FC),
              child: Text(
                'CM',
                style: TextStyle(color: _navy, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EM MANUTENÇÃO',
                      style: TextStyle(
                        color: Color(0xFFD9E8F5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _manutencoesAtivas.length.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Equipamentos sob acompanhamento',
                      style: TextStyle(color: Color(0xFFD9E8F5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF28567F),
                child: Icon(
                  Icons.build_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Retornados',
                value: _retornosRegistrados.toString().padLeft(2, '0'),
                detail: 'registrados',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF18825B),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                title: 'Pendentes',
                value: _manutencoesAtivas.length.toString().padLeft(2, '0'),
                detail: 'aguardando baixa',
                icon: Icons.schedule_outlined,
                color: const Color(0xFF9A6513),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Ação rápida',
          style: TextStyle(
            color: Color(0xFF152536),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _openReturnFlow,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: _blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar retorno',
                          style: TextStyle(
                            color: Color(0xFF152536),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fotografar nota de retorno',
                          style: TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _muted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
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
        const SizedBox(height: 6),
        if (_manutencoesRecentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Nenhuma manutenção registrada.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          )
        else
          ..._manutencoesRecentes.map((manutencao) {
            final concluida = manutencao.status == 'Concluída';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MaintenanceTile(
                icon: concluida
                    ? Icons.check_circle_outline
                    : Icons.build_outlined,
                title: manutencao.equipamento,
                detail: 'OS ${manutencao.numeroOs} · ${manutencao.status}',
                status: concluida ? 'CONCLUÍDA' : 'PENDENTE',
                statusColor: concluida
                    ? const Color(0xFF18825B)
                    : const Color(0xFF9A6513),
                statusBackground: concluida
                    ? const Color(0xFFE8F5EF)
                    : const Color(0xFFFFF3DA),
              ),
            );
          }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 112),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE6EBF0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ),
            Icon(icon, color: color, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF152536),
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(detail, style: const TextStyle(color: _muted, fontSize: 10)),
      ],
    ),
  );
}

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
  });
  final IconData icon;
  final String title;
  final String detail;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE6EBF0)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFF0F3F7),
          child: Icon(icon, color: _navy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF152536),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
