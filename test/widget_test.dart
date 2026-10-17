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

  testWidgets('Preenchimento com 5000 ou 5000,00 gera o mesmo resultado de cálculo financeiro', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AposentaFacilApp());
    await tester.pumpAndSettle();

    // Localiza o campo de renda desejada (valor inicial padrão '10.000,00')
    final incomeFinder = find.widgetWithText(TextField, '10.000,00');
    expect(incomeFinder, findsOneWidget);

    // Digita '5000'
    await tester.enterText(incomeFinder, '5000');
    await tester.pumpAndSettle();

    // Verifica que o patrimônio alvo calculado com 5000 a 0.45% a.m. é R$ 1.111.111,11
    expect(find.textContaining('1.111.111,11'), findsWidgets);

    // Agora digita '5000,00'
    final updatedIncomeFinder = find.widgetWithText(TextField, '5000');
    await tester.enterText(updatedIncomeFinder, '5000,00');
    await tester.pumpAndSettle();

    // O resultado DEVE ser rigorosamente idêntico: R$ 1.111.111,11
    expect(find.textContaining('1.111.111,11'), findsWidgets);
  });

  testWidgets('Renderiza perfeitamente no mobile (360x780) sem nenhum overflow de layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AposentaFacilApp());
    await tester.pumpAndSettle();

    // No mobile, o HeaderBar deve exibir o botão de cópia adaptado ('Copiar') e ícone de metodologia
    expect(find.text('Copiar'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    // Abre o diálogo de Metodologia em tela pequena
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Premissas e Metodologia Financeira'), findsOneWidget);
    expect(find.text('Entendido'), findsOneWidget);

    // Fecha o diálogo
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // Rola a página até encontrar o seletor do gráfico/tabela
    await tester.scrollUntilVisible(
      find.text('Tabela'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Alterna para o modo tabela no gráfico para validar scroll horizontal
    expect(find.text('Tabela'), findsOneWidget);
    await tester.tap(find.text('Tabela'));
    await tester.pumpAndSettle();

    expect(find.text('Renda Passiva/Mês'), findsOneWidget);
  });
}
