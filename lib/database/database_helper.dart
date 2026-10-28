import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../model/manutencao.dart';
import '../model/nota_retorno.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'bnr1.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getDatabasesPath();
    _database = await openDatabase(
      p.join(directory, _databaseName),
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE manutencoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_os TEXT NOT NULL UNIQUE,
        cliente TEXT NOT NULL,
        equipamento TEXT NOT NULL,
        servico TEXT NOT NULL,
        status TEXT NOT NULL,
        data_criacao TEXT NOT NULL,
        data_conclusao TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE notas_retorno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocolo TEXT,
        manutencao_id INTEGER NOT NULL,
        numero_os TEXT NOT NULL UNIQUE,
        data_retorno TEXT NOT NULL,
        cliente TEXT NOT NULL,
        equipamento TEXT NOT NULL,
        servico TEXT NOT NULL,
        situacao_nota TEXT,
        observacao TEXT,
        equipamento_funcionando INTEGER NOT NULL,
        caminho_foto TEXT NOT NULL,
        texto_ocr TEXT NOT NULL,
        data_registro TEXT NOT NULL,
        FOREIGN KEY (manutencao_id) REFERENCES manutencoes(id)
      )
    ''');

    await db.insert('manutencoes', {
      'numero_os': '2026-0187',
      'cliente': 'Mercado Central Itapetininga',
      'equipamento': 'Câmara fria comercial · CF-03',
      'servico': 'Manutenção de câmara fria',
      'status': 'Retorno pendente',
      'data_criacao': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Manutencao>> obterManutencoesAtivas() async {
    final db = await database;
    final rows = await db.query(
      'manutencoes',
      where: 'status != ?',
      whereArgs: ['Concluída'],
      orderBy: 'id DESC',
    );
    return rows.map(Manutencao.fromMap).toList();
  }

  Future<List<Manutencao>> obterManutencoesRecentes({int limite = 5}) async {
    final db = await database;
    final rows = await db.query(
      'manutencoes',
      orderBy: 'id DESC',
      limit: limite,
    );
    return rows.map(Manutencao.fromMap).toList();
  }

  Future<Manutencao?> buscarManutencaoAtivaPorOs(String numeroOs) async {
    final db = await database;
    final rows = await db.query(
      'manutencoes',
      where: 'numero_os = ? AND status != ?',
      whereArgs: [_normalizarOs(numeroOs), 'Concluída'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Manutencao.fromMap(rows.first);
  }

  Future<int> contarRetornos() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM notas_retorno',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> registrarRetorno({
    required Manutencao manutencao,
    required NotaRetornoExtraida nota,
    required bool equipamentoFuncionando,
    required String caminhoFoto,
  }) async {
    final manutencaoId = manutencao.id;
    if (manutencaoId == null) {
      throw StateError('A manutenção selecionada não possui identificador.');
    }

    final db = await database;
    return db.transaction<int>((txn) async {
      final atual = await txn.query(
        'manutencoes',
        where: 'id = ? AND status != ?',
        whereArgs: [manutencaoId, 'Concluída'],
        limit: 1,
      );
      if (atual.isEmpty) {
        throw StateError(
          'Esta manutenção já foi baixada ou não está disponível.',
        );
      }

      final dataRegistro = DateTime.now().toIso8601String();
      final retornoId = await txn.insert('notas_retorno', {
        'manutencao_id': manutencaoId,
        'numero_os': _normalizarOs(nota.numeroOs),
        'data_retorno': nota.dataRetorno,
        'cliente': nota.cliente.trim(),
        'equipamento': nota.equipamento.trim(),
        'servico': nota.servico.trim(),
        'situacao_nota': nota.situacao.trim(),
        'observacao': nota.observacao.trim(),
        'equipamento_funcionando': equipamentoFuncionando ? 1 : 0,
        'caminho_foto': caminhoFoto,
        'texto_ocr': nota.textoOriginal,
        'data_registro': dataRegistro,
      });
      final protocolo =
          'RET-${DateTime.now().year}-${retornoId.toString().padLeft(4, '0')}';
      await txn.update(
        'notas_retorno',
        {'protocolo': protocolo},
        where: 'id = ?',
        whereArgs: [retornoId],
      );
      await txn.update(
        'manutencoes',
        {'status': 'Concluída', 'data_conclusao': dataRegistro},
        where: 'id = ?',
        whereArgs: [manutencaoId],
      );
      return retornoId;
    });
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
}
