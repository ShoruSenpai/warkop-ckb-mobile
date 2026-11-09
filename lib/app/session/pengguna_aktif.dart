enum UserRole { management, cashier, employee }

class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final UserRole role;
}