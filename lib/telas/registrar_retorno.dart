import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../control/nota_retorno_controller.dart';
import '../model/nota_retorno.dart';
import 'conferencia_nota.dart';

class RegistrarRetorno extends StatefulWidget {
  const RegistrarRetorno({super.key});

  @override
  State<RegistrarRetorno> createState() => _RegistrarRetornoState();
}

class _RegistrarRetornoState extends State<RegistrarRetorno> {
  final ImagePicker _imagePicker = ImagePicker();
  late final NotaRetornoController _controller;
  String? _fotoPath;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _controller = NotaRetornoController();
  }

  @override
  void dispose() {
    unawaited(_controller.fechar());
    super.dispose();
  }

  Future<void> _selecionarFoto(ImageSource origem) async {
    if (_processando) return;
    try {
      final foto = await _imagePicker.pickImage(
        source: origem,
        imageQuality: 90,
        maxWidth: 2400,
      );
      if (foto == null) return;

      setState(() {
        _processando = true;
        _fotoPath = foto.path;
      });

      final fotoSalva = await _copiarParaArmazenamento(foto);
      if (!mounted) return;
      setState(() => _fotoPath = fotoSalva.path);

      final nota = await _controller.lerNota(fotoSalva.path);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              ConferenciaNota(nota: nota, caminhoFoto: fotoSalva.path),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível ler a nota: $error')),
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<File> _copiarParaArmazenamento(XFile foto) async {
    final diretorioBase = await getDatabasesPath();
    final diretorioFotos = Directory(p.join(diretorioBase, 'notas_retorno'));
    await diretorioFotos.create(recursive: true);
    final extensao = p.extension(foto.path).isEmpty
        ? '.jpg'
        : p.extension(foto.path);
    final nome = 'nota_${DateTime.now().millisecondsSinceEpoch}$extensao';
    return File(foto.path).copy(p.join(diretorioFotos.path, nome));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        title: const Text('Registrar retorno'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LinearProgressIndicator(
                value: 1 / 3,
                minHeight: 4,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Color(0xFF2864D7),
                backgroundColor: Color(0xFFE6EBF0),
              ),
              const SizedBox(height: 28),
              const Text(
                'Fotografe a nota de retorno',
                style: TextStyle(
                  color: Color(0xFF152536),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enquadre o número da OS e os dados do serviço.',
                style: TextStyle(color: Color(0xFF748396), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFD6E3EF)),
                  ),
                  child: _fotoPath == null
                      ? const _OrientacaoFoto()
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_fotoPath!),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const _OrientacaoFoto(),
                            ),
                            if (_processando)
                              ColoredBox(
                                color: Color(0x88000000),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'Lendo os dados da nota…',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _processando
                    ? null
                    : () => _selecionarFoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Abrir câmera'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2864D7),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _processando
                    ? null
                    : () => _selecionarFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Selecionar foto da galeria'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2864D7),
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Color(0xFFD6E3EF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrientacaoFoto extends StatelessWidget {
  const _OrientacaoFoto();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: Color(0xFFEAF1FC),
          child: Icon(
            Icons.photo_camera_outlined,
            size: 42,
            color: Color(0xFF2864D7),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'A nota aparecerá aqui',
          style: TextStyle(
            color: Color(0xFF152536),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Mantenha o documento inteiro visível e com boa iluminação.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF748396), fontSize: 13),
          ),
        ),
      ],
    );
  }
}
