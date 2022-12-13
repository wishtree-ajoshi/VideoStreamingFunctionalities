import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future makePdf(
    {required List responseKeys,
    required List responseValues,
    required String pdfName}) async {
  ///Company logo...
  final image = MemoryImage(
    (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
  );
  final pdf = Document(compress: true, title: pdfName);
  print("$responseValues");
  pdf.addPage(
    Page(
      build: (context) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ///Logo and header..
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(image, height: 20, width: 200, fit: BoxFit.fitHeight),
                    Text(
                      "Wishtree Technologies LLP",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ]),
              SizedBox(height: 40),

              ///Form Title
              Text(
                "RESPONSES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              ///Questions and Answers..
              ListView.builder(
                direction: Axis.vertical,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                spacing: 20,
                itemBuilder: (Context context, int index) => Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Question $index: ${responseKeys[index]}"),
                      Text("Answer: ${responseValues[index].toString()}"),
                    ],
                  ),
                ),
                itemCount: responseKeys.length,
              ),
            ]);
      },
      pageFormat: PdfPageFormat.a4,
    ),
  );

  final output = await getApplicationDocumentsDirectory();
  final file = File('${output.path}/$pdfName.pdf');
  await file.writeAsBytes(await pdf.save());

  //return pdf;
  return file;
}
