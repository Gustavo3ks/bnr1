import 'package:flutter/material.dart';

class SucessoRetorno extends StatelessWidget {
  const SucessoRetorno({
    super.key,
    required this.protocolo,
    required this.numeroOs,
    required this.cliente,
    required this.equipamento,
    required this.servico,
  });

  final String protocolo;
  final String numeroOs;
  final String cliente;
  final String equipamento;
  final String servico;

  void _voltarInicio(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          children: [
            const Text(
              'Retorno registrado!',
              style: TextStyle(
                color: Color(0xFF152536),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nota registrada e manutenção baixada.',
              style: TextStyle(color: Color(0xFF748396), fontSize: 13),
            ),
            const SizedBox(height: 38),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE8F5EF),
              child: Icon(
                Icons.check_rounded,
                size: 56,
                color: Color(0xFF18825B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'A manutenção foi encerrada com sucesso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF748396), fontSize: 14),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6EBF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nº DO RETORNO',
                    style: TextStyle(
                      color: Color(0xFF748396),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    protocolo,
                    style: const TextStyle(
                      color: Color(0xFF152536),
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(height: 24),
                  _ResumoItem(label: 'OS', valor: numeroOs),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'CLIENTE', valor: cliente),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'EQUIPAMENTO', valor: equipamento),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'SERVIÇO REALIZADO', valor: servico),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => _voltarInicio(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2864D7),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Voltar ao início'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _voltarInicio(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2864D7),
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: Color(0xFFD6E3EF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Ver manutenção baixada'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  const _ResumoItem({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF748396),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Color(0xFF152536),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
