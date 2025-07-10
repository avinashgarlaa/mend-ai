import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/main.dart';

void main() {
  testWidgets('MendApp loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MendApp()));

    expect(find.text('Register'), findsAtLeastNWidgets(1));
    expect(find.text('Login'), findsAtLeastNWidgets(1));
  });
}
