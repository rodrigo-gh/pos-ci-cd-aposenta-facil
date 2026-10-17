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
    expect(find.text('Calcular Meu Futuro'), findsOneWidget);
    expect(find.text('Seus Dados & Metas'), findsOneWidget);
  });
}
