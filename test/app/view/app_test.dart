import 'package:flutter_test/flutter_test.dart';
import 'package:subby/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders App', (tester) async {
      await tester.pumpWidget(const App());
      expect(const App(), isNotNull);
    });
  });
}
