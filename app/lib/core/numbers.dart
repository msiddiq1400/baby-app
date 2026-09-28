/// Parses numbers typed on any keyboard: Urdu/Persian digits (۰-۹),
/// Arabic-Indic digits (٠-٩), and a comma or Arabic decimal mark.
double? parseLocalizedNumber(String input) {
  final buffer = StringBuffer();
  for (final rune in input.trim().runes) {
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune == 0x2C || rune == 0x066B) {
      buffer.write('.');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return double.tryParse(buffer.toString());
}

/// Whole numbers only; null for "12.5" or non-numbers.
int? parseLocalizedInt(String input) {
  final value = parseLocalizedNumber(input);
  return value != null && value == value.roundToDouble() ? value.round() : null;
}
