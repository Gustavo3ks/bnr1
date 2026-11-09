import 'package:flutter/material.dart';

class SucessoRetorno extends StatelessWidget {
  const SucessoRetorno({
    super.key,
    required this.protocolo,
    required this.numeroOs,
    required this.numeroPedido,
    required this.cliente,
    required this.equipamento,
    required this.servico,
  });

  final String protocolo;
  final String numeroOs;
  final String numeroPedido;
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
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Color(0xFF18825B),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retorno registrado!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF152536),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A nota foi registrada e o pedido de serviço foi baixado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF748396), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6EBF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResumoItem(label: 'Protocolo', valor: protocolo),
                  const Divider(height: 24),
                  _ResumoItem(label: 'OS', valor: numeroOs),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'Pedido', valor: numeroPedido),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'Cliente', valor: cliente),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'Equipamento', valor: equipamento),
                  const SizedBox(height: 12),
                  _ResumoItem(label: 'Serviço realizado', valor: servico),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => _voltarInicio(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2864D7),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Voltar ao início'),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF748396), fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        valor,
        style: const TextStyle(
          color: Color(0xFF152536),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
