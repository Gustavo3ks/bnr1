import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class RegistrarManutencao extends StatefulWidget {
  const RegistrarManutencao({super.key});

  @override
  State<RegistrarManutencao> createState() => _RegistrarManutencaoState();
}

class _RegistrarManutencaoState extends State<RegistrarManutencao> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _serieController = TextEditingController();
  final _localController = TextEditingController();
  final _servicoController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _equipamentosFuture;
  Map<String, dynamic>? _equipamentoSelecionado;
  bool _novoEquipamento = true;
  String _prioridade = 'normal';
  bool _salvando = false;

  @override
  void dispose() {
    _clienteController.dispose();
    _nomeController.dispose();
    _modeloController.dispose();
    _serieController.dispose();
    _localController.dispose();
    _servicoController.dispose();
    super.dispose();
  }

  void _alterarModo(bool novo) {
    setState(() {
      _novoEquipamento = novo;
      _equipamentoSelecionado = null;
      _clienteController.clear();
      _nomeController.clear();
      _modeloController.clear();
      _serieController.clear();
      _localController.clear();
      if (!novo) {
        _equipamentosFuture ??= DatabaseHelper.instance.obterEquipamentos();
      }
    });
  }

  void _selecionarEquipamento(Map<String, dynamic>? item) {
    setState(() {
      _equipamentoSelecionado = item;
      _clienteController.text = item?['cliente'] as String? ?? '';
      _nomeController.text = item?['nome'] as String? ?? '';
      _modeloController.text = item?['modelo'] as String? ?? '';
      _serieController.text = item?['numero_serie'] as String? ?? '';
      _localController.text = item?['local_instalacao'] as String? ?? '';
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _salvando) return;
    if (!_novoEquipamento && _equipamentoSelecionado == null) return;
    setState(() => _salvando = true);
    try {
      final item = _equipamentoSelecionado;
      final id = item?['legado'] == true ? null : item?['id'] as String?;
      await DatabaseHelper.instance.cadastrarEquipamentoEManutencao(
        cliente: _clienteController.text,
        equipamento: _nomeController.text,
        modelo: _modeloController.text,
        numeroSerie: _serieController.text,
        localInstalacao: _localController.text,
        servico: _servicoController.text,
        prioridade: _prioridade,
        equipamentoId: id,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível salvar. Confira a conexão e as permissões do Firebase e tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _obrigatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    final somenteLeitura = !_novoEquipamento;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Registrar manutenção')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Novo equipamento'),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Já cadastrado'),
                      icon: Icon(Icons.list_alt),
                    ),
                  ],
                  selected: {_novoEquipamento},
                  onSelectionChanged: _salvando
                      ? null
                      : (selection) => _alterarModo(selection.first),
                ),
                if (!_novoEquipamento) ...[
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _equipamentosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Não foi possível carregar os equipamentos. Verifique a conexão.',
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final itens = snapshot.data!;
                      if (itens.isEmpty) {
                        return const Text(
                          'Ainda não há equipamentos cadastrados.',
                        );
                      }
                      return DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: _equipamentoSelecionado,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Selecione o equipamento *',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: itens
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  '${item['nome']} · ${item['cliente']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _salvando ? null : _selecionarEquipamento,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Dados do equipamento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _Campo(
                  controller: _clienteController,
                  label: 'Cliente *',
                  validator: _obrigatorio,
                  readOnly: somenteLeitura,
                ),
                _Campo(
                  controller: _nomeController,
                  label: 'Nome do equipamento *',
                  validator: _obrigatorio,
                  readOnly: somenteLeitura,
                ),
                _Campo(
                  controller: _modeloController,
                  label: 'Modelo ou identificação',
                  readOnly: somenteLeitura,
                ),
                _Campo(
                  controller: _serieController,
                  label: 'Número de série',
                  readOnly: somenteLeitura,
                ),
                _Campo(
                  controller: _localController,
                  label: 'Local de instalação',
                  readOnly: somenteLeitura,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manutenção',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _Campo(
                  controller: _servicoController,
                  label: 'Problema ou serviço solicitado *',
                  validator: _obrigatorio,
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _prioridade,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                  ],
                  onChanged: _salvando
                      ? null
                      : (valor) =>
                            setState(() => _prioridade = valor ?? 'normal'),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_salvando ? 'Salvando…' : 'Registrar manutenção'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF2864D7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
