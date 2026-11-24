import '../app_dependencies.dart';
import '../session/current_user.dart';
import 'main_app_shell.dart';

class CashierAppShell extends MainAppShell {
  const CashierAppShell({
    required CurrentUser currentUser,
    required AppDependencies dependencies,
    String? initialRoute,
    super.key,
  }) : super(
         currentUser: currentUser,
         dependencies: dependencies,
         initialRoute: initialRoute,
       );
}
