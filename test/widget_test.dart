import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnr1/main.dart';
import 'package:bnr1/telas/telas_navegacao.dart';

void main() {
  testWidgets('abre o painel de manutenção', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Controle de manutenção'), findsOneWidget);
    expect(find.text('Registrar retorno'), findsOneWidget);
    expect(find.text('Pedidos de serviço recentes'), findsOneWidget);
  });

  testWidgets('abre o fluxo de registro de retorno', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar retorno').last);
    await tester.pumpAndSettle();
    expect(find.text('Fotografe a nota de retorno'), findsOneWidget);
    expect(find.text('Abrir câmera'), findsOneWidget);
    expect(find.text('Selecionar foto da galeria'), findsOneWidget);
  });

  Future<void> abrirFormulario(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: EquipamentosPage(carregarEquipamentos: () async => [])),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
  }

  Future<void> rolarAteSalvar(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
  }

  testWidgets('abre o formulário de cadastro de manutenção', (tester) async {
    await abrirFormulario(tester);
    expect(find.text('Novo equipamento'), findsOneWidget);
    expect(find.text('Já cadastrado'), findsOneWidget);
    expect(find.text('Nome do equipamento *'), findsOneWidget);
    expect(find.text('Problema ou serviço solicitado *'), findsOneWidget);
    await rolarAteSalvar(tester);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('valida os campos obrigatórios da manutenção', (tester) async {
    await abrirFormulario(tester);
    await rolarAteSalvar(tester);
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsNWidgets(3));
  });
}
