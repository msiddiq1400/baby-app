// CSV reading and writing (RFC 4180): fields with commas, quotes or line
// breaks are quoted, quotes inside are doubled. Used by the export and by
// the importers (Nara, Huckleberry, Palna's own export).

/// Splits [text] into rows of fields. Handles quoted fields with commas,
/// doubled quotes and line breaks, CRLF or LF line ends, a UTF-8 BOM, and a
/// last line without a line break. Blank lines are dropped.
List<List<String>> parseCsv(String text) {
  if (text.startsWith('﻿')) text = text.substring(1);
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var fieldStarted = false;

  void endField() {
    row.add(field.toString());
    field.clear();
    fieldStarted = false;
  }

  void endRow() {
    endField();
    if (!(row.length == 1 && row.single.isEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"' && !fieldStarted) {
      inQuotes = true;
      fieldStarted = true;
    } else if (c == ',') {
      endField();
    } else if (c == '\r') {
      if (i + 1 < text.length && text[i + 1] == '\n') i++;
      endRow();
    } else if (c == '\n') {
      endRow();
    } else {
      field.write(c);
      fieldStarted = true;
    }
  }
  if (field.isNotEmpty || row.isNotEmpty || fieldStarted) endRow();
  return rows;
}

/// A table read from CSV, with fields looked up by column name (exports
/// leave out or reorder columns, so never by position).
class CsvTable {
  CsvTable(List<List<String>> rows)
      : header = rows.isEmpty ? const [] : [for (final h in rows.first) h.trim()],
        rows = rows.length <= 1 ? const [] : rows.sublist(1) {
    for (var i = 0; i < header.length; i++) {
      _index.putIfAbsent(header[i].toLowerCase(), () => i);
    }
  }

  factory CsvTable.parse(String text) => CsvTable(parseCsv(text));

  final List<String> header;
  final List<List<String>> rows;
  final _index = <String, int>{};

  bool has(String column) => _index.containsKey(column.toLowerCase());

  /// The trimmed field, or null when the column is missing or the field is
  /// empty. Short rows (some exports drop trailing empty fields) are fine.
  String? get(List<String> row, String column) {
    final i = _index[column.toLowerCase()];
    if (i == null || i >= row.length) return null;
    final v = row[i].trim();
    return v.isEmpty ? null : v;
  }
}

/// One CSV line (without the line break).
String csvLine(Iterable<Object?> fields) => fields.map(csvField).join(',');

String csvField(Object? value) {
  final s = value?.toString() ?? '';
  if (s.contains(RegExp(r'[",\r\n]')) || s.startsWith(' ') || s.endsWith(' ')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

/// A whole CSV file: a BOM so Excel reads Urdu correctly, CRLF line ends.
String csvDocument(List<Object?> header, Iterable<List<Object?>> rows) =>
    '﻿${[csvLine(header), for (final r in rows) csvLine(r)].join('\r\n')}\r\n';
