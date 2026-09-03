import 'dart:math';

abstract class ModularLocalizationEntries {
  const ModularLocalizationEntries();

  /// Replaces matches of `RegExp(r'%s')` with given [arguments].
  ///
  /// **example:**
  /// ```dart
  /// print(replaceArguments('I love %s and %s!', ['cakes', 'pie'])) // 'I love cakes and pie!'
  /// ```
  String replaceArguments(
    String string, [
    List<String> arguments = const [],
  ]) {
    var regExp = RegExp(r'%s');

    // Lower between number of arguments and argument slots.
    var limit = min(arguments.length, regExp.allMatches(string).length);

    for (int i = 0; i < limit; i++) {
      string = string.replaceFirst(regExp, arguments[i]);
    }

    return string;
  }

  /// `en`: **"Dark/light mode"**
  ///
  /// `pt`: **"Modo claro/escuro"**
  String get entry0;

  /// `en`: **"Clear"**
  ///
  /// `pt`: **"Limpar"**
  String get entry1;

  /// `en`: **"Homepage"**
  ///
  /// `pt`: **"Página inicial"**
  String get entry2;

  /// `en`: **"Language"**
  ///
  /// `pt`: **"Idioma"**
  String get entry3;

  /// `en`: **"Step once"**
  ///
  /// `pt`: **"Avançar"**
  String get entry4;

  /// `en`: **"Play/pause"**
  ///
  /// `pt`: **"Iniciar/pausar"**
  String get entry5;
}
