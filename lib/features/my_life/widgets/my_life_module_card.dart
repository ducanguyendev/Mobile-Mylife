import 'package:flutter/material.dart';

class MyLifeModuleCard extends StatelessWidget {
  const MyLifeModuleCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.description,
      required this.openLabel,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String title;
  final String description;
  final String openLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DecoratedBox(
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(icon, color: color, size: 25))),
              const Spacer(),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(children: [
                Text(openLabel,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 16, color: color)
              ]),
            ]),
          )),
    );
  }
}
