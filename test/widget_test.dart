import 'package:flutter_test/flutter_test.dart';

import 'package:warkop_ckb_mobile/main.dart';

void main() {
  testWidgets('shows the existing login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);
  });
}
