import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_mylife/features/admin/models/admin_user_model.dart';
import 'package:mobile_mylife/features/auth/models/user_model.dart';

void main() {
  test('parses backend user IDs and provider flags safely', () {
    final user = UserModel.fromJson({
      'id': 42,
      'email': 'admin@example.com',
      'role': 'ADMIN',
      'loginProviders': {'local': true, 'google': true},
    });

    expect(user.id, 42);
    expect(user.role, UserModel.roleAdmin);
    expect(user.isAdmin, isTrue);
    expect(user.hasLocalLogin, isTrue);
    expect(user.hasGoogleLogin, isTrue);
  });

  test('normalizes admin users to integer IDs and API roles', () {
    final user = AdminUserModel.fromJson({
      'id': '7',
      'email': 'member@example.com',
      'role': 'Member',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00Z',
    });

    expect(user.id, 7);
    expect(user.role, UserModel.roleUser);
    expect(user.isAdmin, isFalse);
  });
}
