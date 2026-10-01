import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';
import '../../../shared/widgets/cyber_button.dart';
import '../../../shared/widgets/glass_container.dart';

class ContactSection extends ConsumerStatefulWidget {
  const ContactSection({super.key});

  @override
  ConsumerState<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends ConsumerState<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(LanguageNotifier lang) {
    if (_formKey.currentState!.validate()) {
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(lang.tr('contact_success')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final accentColor = isDark ? AppColors.accentGold : AppColors.accentGoldLightMode;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GlassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  lang.tr('contact_title'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              lang.tr('contact_subtitle'),
              style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Divider(color: isDark ? AppColors.borderSubtle : AppColors.borderSubtleLight, height: 20),

            Text(
              lang.tr('contact_desc'),
              style: TextStyle(color: secondaryTextColor, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),

            // Form inputs
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: lang.tr('lbl_name'),
                hintText: lang.tr('hint_name'),
                prefixIcon: const Icon(Icons.person_outline, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? lang.tr('err_name_req') : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: lang.tr('lbl_email'),
                hintText: lang.tr('hint_email'),
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return lang.tr('err_email_req');
                if (!v.contains('@') || !v.contains('.')) return lang.tr('err_email_invalid');
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: lang.tr('lbl_subject'),
                hintText: lang.tr('hint_subject'),
                prefixIcon: const Icon(Icons.subject, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? lang.tr('err_subject_req') : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: lang.tr('lbl_message'),
                hintText: lang.tr('hint_message'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(Icons.chat_bubble_outline, size: 20),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? lang.tr('err_msg_req') : null,
            ),
            const SizedBox(height: 20),

            CyberButton(
              text: lang.tr('btn_send_msg'),
              icon: Icons.send,
              primaryColor: accentColor,
              onPressed: () => _sendMessage(lang),
            ),
          ],
        ),
      ),
    );
  }
}
