import 'package:flutter/material.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;

  const LanguageSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return ListenableBuilder(
      listenable: loc,
      builder: (context, _) {
        final current = loc.currentLanguage;
        return PopupMenuButton<AppLanguage>(
          tooltip: t('select_language'),
          initialValue: current,
          onSelected: (AppLanguage lang) {
            loc.setLanguage(lang);
          },
          itemBuilder: (context) => AppLanguage.values.map((lang) {
            final isSelected = lang == current;
            return PopupMenuItem<AppLanguage>(
              value: lang,
              child: Row(
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    lang.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : const Color(0xFF2C2523),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check, size: 16, color: AppColors.primary),
                ],
              ),
            );
          }).toList(),
          child: compact
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2DCD5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(current.flag, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      Text(
                        current.shortName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A524C),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF5A524C)),
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: null, // Handled by PopupMenuButton parent
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(current.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${current.shortName} • ${current.label}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
