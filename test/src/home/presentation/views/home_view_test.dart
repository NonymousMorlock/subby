import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subby/src/home/presentation/views/home_view.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('HomeView', () {
    testWidgets('renders calculated subnet details after submit', (
      tester,
    ) async {
      await tester.pumpApp(const HomeView());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '192');
      await tester.enterText(fields.at(1), '168');
      await tester.enterText(fields.at(2), '1');
      await tester.enterText(fields.at(3), '10');
      await tester.enterText(fields.at(4), '24');

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Calculated Values'), findsOneWidget);
      expect(find.text('192.168.1.10/24'), findsOneWidget);
      expect(find.text('254'), findsOneWidget);
      expect(find.text('255.255.255.0'), findsOneWidget);
      expect(find.text('192.168.1.0'), findsOneWidget);
      expect(find.text('192.168.1.255'), findsOneWidget);
    });
  });
}
