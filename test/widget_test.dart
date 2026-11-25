// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mobile_ckb/main.dart';
import 'package:mobile_ckb/app/navigation/widgets/app_bottom_navigation.dart';
import 'package:mobile_ckb/features/cashier/pos/halaman_kasir.dart';
import 'package:mobile_ckb/features/employee/attendance/halaman_absensi.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets('shows the existing login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);
  });

  testWidgets('server dialog rejects an invalid URL and allows correction', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
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

  testWidgets(
    'restored Owner can open attendance and POS and logout clears the shell',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      FlutterSecureStorage.setMockInitialValues({
        'presensi_token': 'owner-test-token',
        'auth_user': jsonEncode({
          'id': '7',
          'name': 'Owner Uji',
          'role': 'owner',
        }),
      });
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      final footer = find.byType(AppBottomNavigation);
      await tester.tap(
        find.descendant(of: footer, matching: find.text('Absensi')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.tap(find.descendant(of: footer, matching: find.text('POS')));
      await tester.pumpAndSettle();
      expect(find.byType(KasirScreen), findsOneWidget);
      await tester.tap(
        find.descendant(of: footer, matching: find.text('Profil')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Keluar Akun'));
      await tester.tap(find.text('Keluar Akun'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, Keluar'));
      await tester.pumpAndSettle();
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
    },
  );
}
