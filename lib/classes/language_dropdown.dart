import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/controller/locale_controller.dart';

class LanguageDropdown extends StatelessWidget {
  final localeController = Get.find<LocaleController>();

  LanguageDropdown({super.key});

  String getCountryCodeFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'ID';
      case 'en':
      default:
        return 'US';
    }
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'id':
        return 'Indonesia';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<Locale>(
        value: localeController.locale,
        items:
            localeController.supportedLocales.map((locale) {
              return DropdownMenuItem(
                value: locale,
                child: Text(
                  locale.languageCode == 'en' ? 'English' : 'Bahasa',
                ),
              );
            }).toList(),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            localeController.changeLocale(newLocale);
          }
        },
      );
    });
  }
}
