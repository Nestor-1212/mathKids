import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:math_kids_panama/app/app.dart';

void main() {
  testWidgets('La app arranca y muestra el onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MathKidsApp()),
    );
    await tester.pump();

    expect(find.byType(MathKidsApp), findsOneWidget);
  });
}
