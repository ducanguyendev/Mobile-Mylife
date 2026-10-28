import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/family_member_model.dart';
import '../providers/family_tree_provider.dart';
import '../widgets/member_form_bottom_sheet.dart';
import 'family_member_profile_screen.dart';

class FamilyMemberProfileRoute extends ConsumerWidget {
  const FamilyMemberProfileRoute({super.key, required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(familyTreeProvider);
    return FamilyMemberProfileScreen(
      member: member,
      onOpenRelative: (relative) => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => FamilyMemberProfileRoute(member: relative)),
      ),
      onEdit: () {
        final navigator = Navigator.of(context);
        navigator.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final formContext = navigator.context;
          if (!formContext.mounted) return;
          showModalBottomSheet<void>(
            context: formContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => MemberFormBottomSheet(
              initialMember: member,
              availableMembers: tree.members,
              generations: tree.generations,
              onSave: (candidate) =>
                  ref.read(familyTreeProvider.notifier).updateMember(candidate),
            ),
          );
        });
      },
      onDelete: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(Localizations.localeOf(context).languageCode == 'vi'
                ? 'Xóa thành viên?'
                : 'Delete family member?'),
            content: Text(member.fullName),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                      Localizations.localeOf(context).languageCode == 'vi'
                          ? 'Hủy'
                          : 'Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                      Localizations.localeOf(context).languageCode == 'vi'
                          ? 'Xóa'
                          : 'Delete')),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          final removed = await ref
              .read(familyTreeProvider.notifier)
              .deleteMember(member.id);
          if (removed && context.mounted) Navigator.of(context).pop();
        }
      },
      onUploadAvatar: () async {
        final image = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 82);
        if (image == null || !context.mounted) return;
        await ref
            .read(familyTreeProvider.notifier)
            .uploadAvatar(member.id, File(image.path));
      },
    );
  }
}
