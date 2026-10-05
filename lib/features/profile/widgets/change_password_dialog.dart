import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_error.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/cyber_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/services/auth_api_service.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authApiServiceProvider);
        await authService.changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
          confirmPassword: _confirmController.text,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Đổi mật khẩu thành công!'),
            ),
          );
        }
      } catch (error, stackTrace) {
        debugPrint('Password change failed: $error\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                ApiError.message(
                  error,
                  fallback: 'Mật khẩu hiện tại không đúng hoặc có lỗi xảy ra.',
                ),
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ĐỔI MẬT KHẨU',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _currentController,
                label: 'MẬT KHẨU HIỆN TẠI',
                obscureText: true,
                validator: (v) => v == null || v.isEmpty
                    ? 'Vui lòng nhập mật khẩu hiện tại'
                    : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _newController,
                label: 'MẬT KHẨU MỚI',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _confirmController,
                label: 'NHẬP LẠI MẬT KHẨU MỚI',
                obscureText: true,
                validator: (v) =>
                    Validators.validateConfirmPassword(v, _newController.text),
              ),
              const SizedBox(height: 20),
              CyberButton(
                text: 'XÁC NHẬN ĐỔI',
                isLoading: _isLoading,
                onPressed: _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
