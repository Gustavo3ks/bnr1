import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/pedido_servico.dart';
import '../model/nota_retorno.dart';
import '../widgets/campo_nota.dart';
import 'sucesso_retorno.dart';

class ConferenciaNota extends StatefulWidget {
  const ConferenciaNota({
    super.key,
    required this.nota,
    required this.caminhoFoto,
  });

  final NotaRetornoExtraida nota;
  final String caminhoFoto;

  @override
  State<ConferenciaNota> createState() => _ConferenciaNotaState();
}

class _ConferenciaNotaState extends State<ConferenciaNota> {
  late final TextEditingController _osController;
  late final TextEditingController _dataController;
  late final TextEditingController _clienteController;
  late final TextEditingController _equipamentoController;
  late final TextEditingController _servicoController;
  late final TextEditingController _situacaoController;
  late final TextEditingController _observacaoController;

  List<PedidoServico> _pedidos = [];
  PedidoServico? _pedidoSelecionado;
  bool? _equipamentoFuncionando;
  bool _carregandoPedidos = true;
  bool _erroCarregamento = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _osController = TextEditingController(text: widget.nota.numeroOs);
    _dataController = TextEditingController(text: widget.nota.dataRetorno);
    _clienteController = TextEditingController(text: widget.nota.cliente);
    _equipamentoController = TextEditingController(
      text: widget.nota.equipamento,
    );
    _servicoController = TextEditingController(text: widget.nota.servico);
    _situacaoController = TextEditingController(text: widget.nota.situacao);
    _observacaoController = TextEditingController(text: widget.nota.observacao);
    unawaited(_carregarPedidos());
  }

  @override
  void dispose() {
    _osController.dispose();
    _dataController.dispose();
    _clienteController.dispose();
    _equipamentoController.dispose();
    _servicoController.dispose();
    _situacaoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarPedidos() async {
    try {
      final pedidos = await DatabaseHelper.instance.obterPedidosAtivos();
      if (!mounted) return;
      final osLida = _normalizarOs(_osController.text);
      final correspondentes = pedidos
          .where((pedido) => _normalizarOs(pedido.numeroOs) == osLida)
          .toList();
      final equipamentoLido = _normalizarCampo(_equipamentoController.text);
      final correspondentesAoEquipamento = correspondentes
          .where(
            (pedido) => _normalizarCampo(pedido.equipamento) == equipamentoLido,
          )
          .toList();
      setState(() {
        _pedidos = pedidos;
        _pedidoSelecionado = correspondentesAoEquipamento.length == 1
            ? correspondentesAoEquipamento.first
            : correspondentes.length == 1
            ? correspondentes.first
            : null;
        _carregandoPedidos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento = true;
        _carregandoPedidos = false;
      });
    }
  }

  String _normalizarCampo(String valor) {
    return valor.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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

  Future<void> _confirmarBaixa() async {
    if (_carregandoPedidos || _pedidos.isEmpty) {
      _mensagem(
        _erroCarregamento
            ? 'Não foi possível carregar os pedidos. Verifique a conexão e a configuração do Firebase.'
            : 'Não há pedidos de serviço ativos para vincular a esta nota.',
      );
      return;
    }
    if (_pedidoSelecionado == null) {
      _mensagem('Selecione o pedido de serviço relacionado à nota.');
      return;
    }
    if (_normalizarOs(_osController.text) !=
        _normalizarOs(_pedidoSelecionado!.numeroOs)) {
      _mensagem('A OS informada precisa corresponder ao pedido selecionado.');
      return;
    }
    if (_osController.text.trim().isEmpty ||
        _dataController.text.trim().isEmpty ||
        _clienteController.text.trim().isEmpty ||
        _equipamentoController.text.trim().isEmpty ||
        _servicoController.text.trim().isEmpty) {
      _mensagem('Preencha os campos obrigatórios antes de continuar.');
      return;
    }
    if (_equipamentoFuncionando == null) {
      _mensagem('Informe se o equipamento voltou a funcionar.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar baixa?'),
        content: Text(
          'A nota será vinculada ao pedido ${_pedidoSelecionado!.numeroPedido}. A OS só será concluída quando todos os pedidos forem baixados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar e revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar baixa'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _salvando = true);
    try {
      final notaConfirmada = NotaRetornoExtraida(
        numeroOs: _osController.text.trim(),
        dataRetorno: _dataController.text.trim(),
        cliente: _clienteController.text.trim(),
        equipamento: _equipamentoController.text.trim(),
        servico: _servicoController.text.trim(),
        situacao: _situacaoController.text.trim(),
        observacao: _observacaoController.text.trim(),
        textoOriginal: widget.nota.textoOriginal,
      );
      final protocolo = await DatabaseHelper.instance.registrarRetorno(
        pedido: _pedidoSelecionado!,
        nota: notaConfirmada,
        equipamentoFuncionando: _equipamentoFuncionando!,
        caminhoFoto: widget.caminhoFoto,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => SucessoRetorno(
            protocolo: protocolo,
            numeroOs: _pedidoSelecionado!.numeroOs,
            numeroPedido: _pedidoSelecionado!.numeroPedido,
            cliente: _clienteController.text.trim(),
            equipamento: _equipamentoController.text.trim(),
            servico: _servicoController.text.trim(),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        _mensagem(
          'Não foi possível registrar a nota. O pedido pode já ter sido baixado ou a conexão com Firebase falhou.',
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final camposAusentes = widget.nota.camposObrigatoriosAusentes;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Conferência da nota')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            const SizedBox(height: 16),
            if (camposAusentes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.nota.textoOriginal.trim().isEmpty
                      ? 'Não conseguimos reconhecer o texto. Preencha os campos manualmente.'
                      : 'Confira os campos sem leitura: ${camposAusentes.join(', ')}.',
                  style: const TextStyle(
                    color: Color(0xFF80520D),
                    fontSize: 13,
                  ),
                ),
              ),
            if (camposAusentes.isNotEmpty) const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(widget.caminhoFoto),
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 90,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Text('Prévia da foto indisponível'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Dados extraídos',
              style: TextStyle(
                color: Color(0xFF152536),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            CampoNota(
              label: 'Número da OS *',
              controller: _osController,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            CampoNota(
              label: 'Data da nota *',
              controller: _dataController,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            CampoNota(label: 'Cliente *', controller: _clienteController),
            const SizedBox(height: 12),
            CampoNota(
              label: 'Equipamento *',
              controller: _equipamentoController,
            ),
            const SizedBox(height: 12),
            CampoNota(
              label: 'Serviço realizado *',
              controller: _servicoController,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CampoNota(
              label: 'Situação na nota',
              controller: _situacaoController,
            ),
            const SizedBox(height: 12),
            CampoNota(
              label: 'Observação',
              controller: _observacaoController,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            const Text(
              'Pedido de serviço relacionado',
              style: TextStyle(
                color: Color(0xFF152536),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_carregandoPedidos)
              const LinearProgressIndicator()
            else if (_pedidos.isEmpty)
              Text(
                _erroCarregamento
                    ? 'Não foi possível carregar os pedidos do Firebase.'
                    : 'Não há pedidos de serviço ativos no Firestore.',
              )
            else
              DropdownButtonFormField<PedidoServico>(
                value: _pedidoSelecionado,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                hint: const Text('Selecione o pedido de serviço'),
                items: _pedidos
                    .map(
                      (pedido) => DropdownMenuItem(
                        value: pedido,
                        child: Text(
                          '${pedido.numeroPedido} · ${pedido.equipamento}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (pedido) {
                  setState(() => _pedidoSelecionado = pedido);
                  if (pedido != null) {
                    _osController.text = pedido.numeroOs;
                    if (_clienteController.text.trim().isEmpty) {
                      _clienteController.text = pedido.cliente;
                    }
                    if (_equipamentoController.text.trim().isEmpty) {
                      _equipamentoController.text = pedido.equipamento;
                    }
                    if (_servicoController.text.trim().isEmpty) {
                      _servicoController.text = pedido.servico;
                    }
                  }
                },
              ),
            const SizedBox(height: 20),
            const Text(
              'O equipamento voltou a funcionar?',
              style: TextStyle(
                color: Color(0xFF152536),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Sim'),
                  selected: _equipamentoFuncionando == true,
                  onSelected: (_) =>
                      setState(() => _equipamentoFuncionando = true),
                ),
                ChoiceChip(
                  label: const Text('Não'),
                  selected: _equipamentoFuncionando == false,
                  onSelected: (_) =>
                      setState(() => _equipamentoFuncionando = false),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _salvando ? null : _confirmarBaixa,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2864D7),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _salvando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirmar e dar baixa'),
            ),
          ],
        ),
      ),
    );
  }
}
