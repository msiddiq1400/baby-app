import 'package:baby_app/features/transfer/csv.dart';
import 'package:flutter_test/flutter_test.dart';

final bom = String.fromCharCode(0xFEFF);

void main() {
  group('parseCsv', () {
    test('plain fields and a last line without a line break', () {
      expect(parseCsv('a,b,c\n1,2,3'), [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
    });

    test('quoted commas and doubled quotes', () {
      expect(parseCsv('"a, b","say ""hi""",c\n'), [
        ['a, b', 'say "hi"', 'c'],
      ]);
    });

    test('line breaks inside quotes stay in the field', () {
      expect(parseCsv('x,"line 1\nline 2\r\nline 3",y\nnext,row,here\n'), [
        ['x', 'line 1\nline 2\r\nline 3', 'y'],
        ['next', 'row', 'here'],
      ]);
    });

    test('CRLF and LF line ends, blank lines dropped', () {
      expect(parseCsv('a,b\r\n1,2\r\n\r\n3,4\n\n'), [
        ['a', 'b'],
        ['1', '2'],
        ['3', '4'],
      ]);
    });

    test('a UTF-8 BOM is dropped', () {
      expect(parseCsv('$bom"Type",Start\nFeed,x\n').first, ['Type', 'Start']);
    });

    test('empty fields, quoted and not', () {
      expect(parseCsv('"Feed",,"",x,\n'), [
        ['Feed', '', '', 'x', ''],
      ]);
    });

    test('Urdu text passes through', () {
      expect(parseCsv('نام,"دودھ, پانی"\n'), [
        ['نام', 'دودھ, پانی'],
      ]);
    });
  });

  group('CsvTable', () {
    final table = CsvTable.parse(' Type ,Start,Notes,Extra\nFeed,2025-01-01 10:00\nSleep,2025-01-02,"  zzz  ",x\n');

    test('looks columns up by name, ignoring case and padding', () {
      expect(table.header, ['Type', 'Start', 'Notes', 'Extra']);
      expect(table.has('type'), isTrue);
      expect(table.has('Missing'), isFalse);
      expect(table.get(table.rows[1], 'TYPE'), 'Sleep');
      expect(table.get(table.rows[1], 'notes'), 'zzz');
    });

    test('short rows, missing columns and empty fields give null', () {
      final short = table.rows[0];
      expect(short, hasLength(2));
      expect(table.get(short, 'Notes'), isNull);
      expect(table.get(short, 'Extra'), isNull);
      expect(table.get(short, 'Nope'), isNull);
    });

    test('an empty file has no header and no rows', () {
      final empty = CsvTable.parse('');
      expect(empty.header, isEmpty);
      expect(empty.rows, isEmpty);
    });
  });

  group('writing', () {
    test('csvField quotes only when it must', () {
      expect(csvField('plain'), 'plain');
      expect(csvField(null), '');
      expect(csvField(12.5), '12.5');
      expect(csvField('a,b'), '"a,b"');
      expect(csvField('say "hi"'), '"say ""hi"""');
      expect(csvField('two\nlines'), '"two\nlines"');
      expect(csvField(' padded'), '" padded"');
    });

    test('csvDocument has a BOM and CRLF line ends', () {
      final doc = csvDocument(
        ['a', 'b'],
        [
          [1, null],
        ],
      );
      expect(doc, '${bom}a,b\r\n1,\r\n');
    });

    test('round trip through csvDocument and parseCsv', () {
      final rows = [
        ['Feed', 'comma, inside', 'quote " inside', 'line\nbreak', '', ' padded ', 'اردو'],
        ['Sleep', '', '', '', '', '', ''],
      ];
      final header = ['Type', 'A', 'B', 'C', 'D', 'E', 'F'];
      expect(parseCsv(csvDocument(header, rows)), [header, ...rows]);
    });
  });
}
