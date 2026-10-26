class AdminStatsModel {
  final int totalUsers;
  final int totalActive;
  final int totalLocked;
  final int successLogins;
  final int failedLogins;
  final int newRegistrations;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalActive,
    required this.totalLocked,
    this.successLogins = 0,
    this.failedLogins = 0,
    this.newRegistrations = 0,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalActive: json['totalActive'] ?? 0,
      totalLocked: json['totalLocked'] ?? 0,
      successLogins: (json['last7Days'] as Map?)?['successLogins'] as int? ?? 0,
      failedLogins: (json['last7Days'] as Map?)?['failedLogins'] as int? ?? 0,
      newRegistrations:
          (json['last7Days'] as Map?)?['newRegistrations'] as int? ?? 0,
    );
  }
}
