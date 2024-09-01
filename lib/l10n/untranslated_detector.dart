import 'dart:convert';
import 'dart:io';

void main() {
  final originalFile = File('lib/l10n/app_en.arb');
  final translatedFile = File('lib/l10n/app_it.arb');

  final originalContent = json.decode(originalFile.readAsStringSync()) as Map<String, dynamic>;
  final translatedContent = json.decode(translatedFile.readAsStringSync()) as Map<String, dynamic>;

  final missingKeys = originalContent.keys
      .where((key) => !translatedContent.containsKey(key))
      .toList();

  if (missingKeys.isEmpty) {
    print('Each key translated');
  } else {
    print('The follow key are not translated:');
    for (var key in missingKeys) {
      print(key);
    }
  }
}