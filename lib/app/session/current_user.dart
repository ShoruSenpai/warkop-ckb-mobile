enum UserRole { management, cashier, employee }

class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.name,
    required this.role,
    this.employeeCode = '',
    this.position = '',
    this.outlet = '',
    this.shift = '',
  });

  final String id;
  final String name;
  final UserRole role;
  final String employeeCode;
  final String position;
  final String outlet;
  final String shift;
  String get displayName => name.isEmpty ? 'Karyawan' : name;

  factory CurrentUser.fromApi(Map<String, dynamic> json) {
    final rawRole = (json['role'] ?? json['position'] ?? '').toString();
    final roleText = rawRole.trim().toLowerCase();
    final UserRole? role =
        roleText.contains('cashier') || roleText.contains('kasir')
        ? UserRole.cashier
        : roleText.contains('management') ||
              roleText.contains('manager') ||
              roleText.contains('admin') ||
              roleText.contains('supervisor')
        ? UserRole.management
        : roleText.contains('employee') ||
              roleText.contains('staff') ||
              roleText.contains('staf') ||
              roleText.contains('barista')
        ? UserRole.employee
        : null;
    if (role == null)
      throw FormatException('Role pengguna tidak dikenali: $rawRole');
    return CurrentUser(
      id: (json['id'] ?? json['employee_id'] ?? json['employee_code'] ?? '')
          .toString(),
      name: (json['name'] ?? json['full_name'] ?? json['nama'] ?? '')
          .toString(),
      role: role,
      employeeCode: (json['employee_code'] ?? json['code'] ?? '').toString(),
      position: (json['position'] ?? json['role'] ?? '').toString(),
      outlet: (json['outlet'] ?? '').toString(),
      shift: (json['shift'] ?? '').toString(),
    );
  }

  factory CurrentUser.fromStorage(Map<String, dynamic> json) =>
      CurrentUser.fromApi(json);
}
