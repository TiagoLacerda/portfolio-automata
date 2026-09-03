import 'modular_localization_delegate.dart';
import 'modular_localization_entries.dart';
import 'modular_localization_entries_en.dart';

abstract class ModularLocalization {
  const ModularLocalization();

  static ModularLocalizationEntries entries = const ModularLocalizationEntriesEn();

  /// modular_localization's `LocalizationsDelegate`.
  static const delegate = ModularLocalizationDelegate();

  /// Localized resources.
  static const ModularLocalizationInternalClass0 localizations =
      ModularLocalizationInternalClass0();
}

class ModularLocalizationInternalClass0 implements ModularLocalization {
  const ModularLocalizationInternalClass0();

  /// **.home**: `...`
  ///
  ModularLocalizationInternalClass1 get modules => const ModularLocalizationInternalClass1();
}

class ModularLocalizationInternalClass1 implements ModularLocalization {
  const ModularLocalizationInternalClass1();

  /// **.homeView**: `...`
  ///
  ModularLocalizationInternalClass2 get home => const ModularLocalizationInternalClass2();
}

class ModularLocalizationInternalClass2 implements ModularLocalization {
  const ModularLocalizationInternalClass2();

  /// **.brightnessSwitchTooltip**
  ///
  /// `en`: **"Dark/light mode"**
  ///
  /// `pt`: **"Modo claro/escuro"**
  ///
  /// **.clearButtonTooltip**
  ///
  /// `en`: **"Clear"**
  ///
  /// `pt`: **"Limpar"**
  ///
  /// **.homeButtonTooltip**
  ///
  /// `en`: **"Homepage"**
  ///
  /// `pt`: **"Página inicial"**
  ///
  /// **.localeButtonTooltip**
  ///
  /// `en`: **"Language"**
  ///
  /// `pt`: **"Idioma"**
  ///
  /// **.stepButtonTooltip**
  ///
  /// `en`: **"Step once"**
  ///
  /// `pt`: **"Avançar"**
  ///
  /// **.toggleButtonTooltip**
  ///
  /// `en`: **"Play/pause"**
  ///
  /// `pt`: **"Iniciar/pausar"**
  ///
  ModularLocalizationInternalClass3 get homeView => const ModularLocalizationInternalClass3();
}

class ModularLocalizationInternalClass3 implements ModularLocalization {
  const ModularLocalizationInternalClass3();

  /// `en`: **"Dark/light mode"**
  ///
  /// `pt`: **"Modo claro/escuro"**
  ///
  String get brightnessSwitchTooltip => ModularLocalization.entries.entry0;

  /// `en`: **"Clear"**
  ///
  /// `pt`: **"Limpar"**
  ///
  String get clearButtonTooltip => ModularLocalization.entries.entry1;

  /// `en`: **"Homepage"**
  ///
  /// `pt`: **"Página inicial"**
  ///
  String get homeButtonTooltip => ModularLocalization.entries.entry2;

  /// `en`: **"Language"**
  ///
  /// `pt`: **"Idioma"**
  ///
  String get localeButtonTooltip => ModularLocalization.entries.entry3;

  /// `en`: **"Step once"**
  ///
  /// `pt`: **"Avançar"**
  ///
  String get stepButtonTooltip => ModularLocalization.entries.entry4;

  /// `en`: **"Play/pause"**
  ///
  /// `pt`: **"Iniciar/pausar"**
  ///
  String get toggleButtonTooltip => ModularLocalization.entries.entry5;

}


