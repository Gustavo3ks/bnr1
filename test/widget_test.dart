import 'package:flutter_test/flutter_test.dart';

import 'package:bnr1/main.dart';

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
}
