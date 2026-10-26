class LoginLogModel {
  const LoginLogModel(
      {required this.id,
      required this.attemptEmail,
      required this.status,
      required this.ipAddress,
      required this.createdAt});
  final int id;
  final String attemptEmail, status;
  final String? ipAddress;
  final DateTime? createdAt;
  factory LoginLogModel.fromJson(Map<String, dynamic> j) => LoginLogModel(
      id: (j['id'] as num).toInt(),
      attemptEmail: j['attemptEmail'] as String? ?? '',
      status: j['status'] as String? ?? '',
      ipAddress: j['ipAddress'] as String?,
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''));
}
