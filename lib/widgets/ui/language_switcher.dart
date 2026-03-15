// lib/widgets/language_switcher.dart

import 'package:flutter/material.dart';
import '../../services/language_provider.dart';
import '../../services/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final LanguageProvider languageProvider;

  const LanguageSwitcher({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF047857).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF047857),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LanguageProvider.languageFlags[languageProvider.locale.languageCode] ?? '🌐',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              languageProvider.locale.languageCode.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF047857),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF047857),
              size: 20,
            ),
          ],
        ),
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (String languageCode) {
        languageProvider.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return LanguageProvider.supportedLocales.map((Locale locale) {
          final languageCode = locale.languageCode;
          final isSelected = languageProvider.locale.languageCode == languageCode;
          
          return PopupMenuItem<String>(
            value: languageCode,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF047857).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    LanguageProvider.languageFlags[languageCode] ?? '🌐',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LanguageProvider.languageNames[languageCode] ?? languageCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? const Color(0xFF047857)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF047857),
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}

// Compact version for mobile
class LanguageSwitcherCompact extends StatelessWidget {
  final LanguageProvider languageProvider;

  const LanguageSwitcherCompact({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF047857).withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF047857),
            width: 1.5,
          ),
        ),
        child: Text(
          LanguageProvider.languageFlags[languageProvider.locale.languageCode] ?? '🌐',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      onPressed: () {
        _showLanguageDialog(context);
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.language, color: Color(0xFF047857)),
              SizedBox(width: 12),
              Text('Select Language'),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageProvider.supportedLocales.map((Locale locale) {
              final languageCode = locale.languageCode;
              final isSelected = languageProvider.locale.languageCode == languageCode;
              
              return InkWell(
                onTap: () {
                  languageProvider.changeLanguage(languageCode);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF047857).withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Text(
                        LanguageProvider.languageFlags[languageCode] ?? '🌐',
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          LanguageProvider.languageNames[languageCode] ?? languageCode,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? const Color(0xFF047857)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF047857),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
