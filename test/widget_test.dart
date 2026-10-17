import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aposenta_facil/main.dart';

void main() {
  testWidgets('AposentaFacilApp smoke test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AposentaFacilApp());
    await tester.pumpAndSettle();

    expect(find.byType(AposentaFacilApp), findsOneWidget);
    expect(find.text('Parâmetros da Simulação'), findsOneWidget);
    expect(find.text('Copiar Resumo'), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Alterna para o Modo Claro
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    // No modo claro, o botão deve exibir o ícone de lua para voltar ao escuro
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
