import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/l10n/app_language_provider.dart';
import '../../../shared/l10n/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme_provider.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final data = [
      ('350+', 'stats_portfolio_projects'),
      ('200+', 'stats_portfolio_clients'),
      ('15', 'stats_portfolio_experience'),
      ('12', 'stats_portfolio_certificates')
    ];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.get('stats_section_title', lang),
                  style: TextStyle(
                      color: dark
                          ? AppColors.accentGold
                          : AppColors.accentGoldLightMode,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .7)),
              const SizedBox(height: 12),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: data.length,
                  itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data[index].$1,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: dark
                                            ? AppColors.accentGold
                                            : AppColors.accentGoldLightMode)),
                            const SizedBox(height: 4),
                            Text(AppStrings.get(data[index].$2, lang),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall)
                          ])))
            ])));
  }
}
