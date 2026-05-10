import 'package:flutter_test/flutter_test.dart';

import 'package:untitled11/main.dart';

void main() {
  testWidgets('renders setup screen when supabase is not configured', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Supabase не настроен'), findsOneWidget);
  });
}
