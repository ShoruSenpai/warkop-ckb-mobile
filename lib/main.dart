import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/aplikasi.dart';

export 'app/aplikasi.dart' show MyApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}
