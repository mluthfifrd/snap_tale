import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  final Rx<Locale> _locale = const Locale('en').obs;

  Locale get locale => _locale.value;

  void changeLocale(Locale newLocale) {
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
  }

  List<Locale> get supportedLocales => const [Locale('en'), Locale('id')];
}
