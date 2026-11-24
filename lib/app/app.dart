import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/app_loading.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'app_dependencies.dart';
import 'router/app_router.dart';
import 'shells/main_app_shell.dart';
import 'session/current_user.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppDependencies _dependencies = AppDependencies();
  bool _isRestoring = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await initializeDateFormatting('id_ID', null);
    try {
      await _dependencies.sessionManager.restore();
    } catch (_) {
      try {
        await _dependencies.sessionManager.clear();
      } catch (_) {
        // Secure storage may be unavailable on unsupported test targets.
      }
    }
    if (mounted) setState(() => _isRestoring = false);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _dependencies.sessionManager.session,
    builder: (context, _) {
      if (_isRestoring) {
        return const MaterialApp(home: Scaffold(body: AppLoading()));
      }
      final user = _dependencies.sessionManager.session.currentUser;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cak Kebo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0B1C30),
            ),
          ),
        ),
        onGenerateRoute: AppRouter(_dependencies).onGenerateRoute,
        home: user == null
            ? LoginPage(authRepository: _dependencies.authRepository)
            : _homeForRole(user),
      );
    },
  );

  Widget _homeForRole(CurrentUser user) =>
      MainAppShell(currentUser: user, dependencies: _dependencies);
}
