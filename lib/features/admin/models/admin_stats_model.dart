class AdminStatsModel {
  final int totalUsers;
  final int totalActive;
  final int totalLocked;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalActive,
    required this.totalLocked,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalActive: json['totalActive'] ?? 0,
      totalLocked: json['totalLocked'] ?? 0,
    );
  }
}
