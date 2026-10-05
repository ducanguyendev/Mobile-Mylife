class ApiEndpoints {
  // Auth
  static const String login = '/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/refresh-token';
  static const String googleAuth = '/auth/google';
  static const String me = '/me';
  static const String logout = '/logout';
  static const String updateProfile = '/me/profile';
  static const String changePassword = '/auth/change-password';

  // Avatar
  static const String uploadAvatar = '/avatar/upload';
  static const String deleteAvatar = '/avatar';
  static String getAvatar(String email) => '/avatar/${Uri.encodeComponent(email)}';

  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminStats = '/admin/stats';
  static String adminUpdateStatus(int id) => '/admin/users/$id/status';
  static String adminUpdateRole(int id) => '/admin/users/$id/role';
  static String adminDeleteUser(int id) => '/admin/users/$id';

  // Family Tree
  static const String familyTree = '/family-tree';
  static const String familyTreeGenerations = '$familyTree/generations';
  static String familyTreeMember(int id) => '$familyTree/$id';
}
