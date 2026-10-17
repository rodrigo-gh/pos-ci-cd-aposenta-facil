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

  testWidgets('Permite digitar livremente a idade de aposentadoria sem sobrescrever o campo', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AposentaFacilApp());
    await tester.pumpAndSettle();

    // Localiza o campo de idade de aposentadoria (valor inicial '55')
    final targetAgeFinder = find.widgetWithText(TextField, '55');
    expect(targetAgeFinder, findsOneWidget);

    // Simula o usuário apagando e digitando '6' (que é menor que a idade atual 28)
    await tester.enterText(targetAgeFinder, '6');
    await tester.pump();

    // O texto digitado '6' DEVE permanecer no campo e NÃO ser forçado para '29' durante a digitação
    expect(find.widgetWithText(TextField, '6'), findsOneWidget);

    // O usuário completa a digitação para '68'
    await tester.enterText(find.widgetWithText(TextField, '6'), '68');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '68'), findsOneWidget);
    expect(find.text('Meta aos 68 anos'), findsOneWidget);
  });
}
