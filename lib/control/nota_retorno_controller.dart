import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../model/nota_retorno.dart';
import 'nota_retorno_parser.dart';

class NotaRetornoController {
  NotaRetornoController()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;
  final NotaRetornoParser _parser = const NotaRetornoParser();

  Future<NotaRetornoExtraida> lerNota(String caminhoFoto) async {
    final imagem = InputImage.fromFile(File(caminhoFoto));
    final textoReconhecido = await _recognizer.processImage(imagem);
    final linhas = textoReconhecido.blocks
        .expand((bloco) => bloco.lines)
        .map((linha) => linha.text)
        .toList();
    final texto = linhas.isEmpty ? textoReconhecido.text : linhas.join('\n');
    return _parser.parse(texto);
  }

  Future<void> fechar() => _recognizer.close();
}
