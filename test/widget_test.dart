// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_ckb/main.dart';

void main() {
  testWidgets('shows the existing login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);
  });

  testWidgets('server dialog rejects an invalid URL and allows correction', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Alamat server'));
    await tester.tap(find.text('Alamat server'));
    await tester.pumpAndSettle();
    expect(find.text('Alamat server Laravel'), findsOneWidget);
    final addressField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(addressField, 'bukan-link');
    await tester.tap(find.text('Cek & simpan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Masukkan link HTTPS'), findsOneWidget);
    expect(tester.widget<TextField>(addressField).enabled, isTrue);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
  });
}
