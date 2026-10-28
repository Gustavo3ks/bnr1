import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/manutencao.dart';

const _background = Color(0xFFF7F8FA);
const _navy = Color(0xFF123B63);
const _muted = Color(0xFF748396);

class EquipamentosPage extends StatelessWidget {
  const EquipamentosPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(title: const Text('Equipamentos')),
    body: FutureBuilder<List<Manutencao>>(
      future: DatabaseHelper.instance.obterManutencoesRecentes(limite: 100),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _ErroCarregamento();
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final itens = snapshot.data!;
        if (itens.isEmpty)
          return const _Vazio(
            icon: Icons.devices_outlined,
            texto: 'Nenhum equipamento cadastrado.',
          );
        final unicos = <String, Manutencao>{};
        for (final item in itens) {
          unicos.putIfAbsent(item.equipamento, () => item);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: unicos.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final equipamento = unicos.values.elementAt(index);
            return _Cartao(
              icon: Icons.ac_unit_outlined,
              titulo: equipamento.equipamento,
              detalhe: '${equipamento.cliente} · OS ${equipamento.numeroOs}',
              etiqueta: equipamento.status,
            );
          },
        );
      },
    ),
  );
}

class ManutencoesPage extends StatelessWidget {
  const ManutencoesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(title: const Text('Manutenções')),
    body: FutureBuilder<List<Manutencao>>(
      future: DatabaseHelper.instance.obterManutencoesRecentes(limite: 100),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _ErroCarregamento();
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final itens = snapshot.data!;
        if (itens.isEmpty)
          return const _Vazio(
            icon: Icons.sync_outlined,
            texto: 'Nenhuma manutenção registrada.',
          );
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: itens.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = itens[index];
            return _Cartao(
              icon: item.status == 'Concluída'
                  ? Icons.check_circle_outline
                  : Icons.build_outlined,
              titulo: 'OS ${item.numeroOs}',
              detalhe: '${item.equipamento} · ${item.cliente}',
              etiqueta: item.status,
            );
          },
        );
      },
    ),
  );
}

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(title: const Text('Mais')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _Cartao(
          icon: Icons.info_outline,
          titulo: 'Sobre o aplicativo',
          detalhe: 'Protótipo de controle de manutenção e registro de notas de retorno.',
          etiqueta: 'BNR1',
        ),
        SizedBox(height: 10),
        _Cartao(
          icon: Icons.document_scanner_outlined,
          titulo: 'Leitura de notas',
          detalhe: 'O reconhecimento e a conferência são iniciados ao registrar um retorno.',
          etiqueta: 'OCR',
        ),
      ],
    ),
  );
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.icon,
    required this.titulo,
    required this.detalhe,
    required this.etiqueta,
  });
  final IconData icon;
  final String titulo;
  final String detalhe;
  final String etiqueta;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE6EBF0)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFEAF1FC),
          child: Icon(icon, color: _navy),
        ),
        const SizedBox(width: 14),
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
              const SizedBox(height: 5),
              Text(
                detalhe,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          etiqueta,
          style: const TextStyle(
            color: _navy,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.icon, required this.texto});
  final IconData icon;
  final String texto;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: _muted),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
    ),
  );
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento();
  @override
  Widget build(BuildContext context) => const _Vazio(
    icon: Icons.storage_outlined,
    texto: 'Os dados locais não estão disponíveis nesta plataforma.',
  );
}
