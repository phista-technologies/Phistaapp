import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phista/constant/show_toast_dialog.dart';

Future<File> generateAndSavePdf(
    String parkingDetailName,
    String address,
    String parkingSlotId,
    String vehicleName,
    String duration,
    ) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text(
                parkingDetailName,
                style: pw.TextStyle(
                  color: PdfColor.fromInt(0xFF3B5F75),
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    child: pw.Text(
                      address,
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF2C4A5C),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              parkingSlotId,
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF3B5F75),
                                fontSize: 16,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Parking Slot",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF2C4A5C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              vehicleName,
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF2C4A5C),
                                fontSize: 16,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Vehicle Detail",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF2C4A5C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "$duration hours",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF2C4A5C),
                                fontSize: 16,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Time Duration",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF2C4A5C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/parking_receipt.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}




Future<File> sendPdfByEmail(String parkingDetailName,String address,
    String parkingSlotId,
    String vehicleName,
    String duration) async {
  ShowToastDialog.showLoader("");
  final pdfFile = await generateAndSavePdf(parkingDetailName,address,parkingSlotId,vehicleName,duration);
  print("pdfFile :--  $pdfFile");
  ShowToastDialog.closeLoader();
  return pdfFile;
}