import 'dart:io';
import 'dart:typed_data';

import 'package:baby_app/features/health/summary_pdf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  pw.Font font(String file) =>
      pw.Font.ttf(ByteData.view(Uint8List.fromList(File('assets/fonts/$file').readAsBytesSync()).buffer));

  test('the summary becomes a PDF', () async {
    const text = '''Health summary: Aisha
Age: 5 months, 20 days
Period: 27 Sep to 30 Sep
Latest weight: 6.95 kg (16 Sep)

Symptoms
• Fever: 27 Sep to 30 Sep, 3 times; highest 38.9°C (102.0°F) on Sun 28 Sep, 7:40 AM
• Cough: 28 Sep to 29 Sep, 2 times

Feeding
• 7 feeds a day (usually 8)

Medicines
• Paracetamol syrup 2.5 ml: given 3 times, last Tue 30 Sep, 8:30 AM''';

    final bytes = await buildSummaryPdf(
      text,
      fonts: SummaryPdfFonts(
        heading: font('Lora-SemiBold.ttf'),
        body: font('Nunito-Regular.ttf'),
        bold: font('Nunito-Bold.ttf'),
      ),
      generatedOn: '30 Sep 2026, 9:00 AM',
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(2000));

    // Kept for a look when PDF_OUT is set (not part of the normal run).
    final out = Platform.environment['PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });
}
