import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phista/constant/show_toast_dialog.dart';

import '../constant/constant.dart';
import '../model/tax_model.dart';

Future<File> generateAndSavePdf(
    String parkingDetailName,
    String address,
    String parkingSlotId,
    String vehicleName,
    String duration,
    String subTotalAmount,
    String couponAmount,
    String calculateAmount,
    List<TaxModel>? taxList
    ) async {
  final pdf = pw.Document();

  // Load the asset image first (async)
  final imageData = await rootBundle.load('assets/images/PhistaOwnerLogo.png');
  final image = pw.MemoryImage(imageData.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Row(

                children: [

                  pw.Container(
                    width: 50,
                    height: 50,
                    child: pw.Image(image, fit: pw.BoxFit.cover),
                  ),
                  pw.SizedBox(width: 10),

                  pw.Expanded(
                    child:  pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            parkingDetailName,
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF3B5F75),
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            address,
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF2C4A5C),
                              fontSize: 14,
                            ),
                          ),
                        ])
                  )
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
              pw.SizedBox(height: 50),

              pw.Container(
                decoration: pw.BoxDecoration(
                  color:PdfColor.fromInt(0xFF3B5F75),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Padding(
                  padding:  pw.EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.symmetric(vertical: 5),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Sub Total',
                                style: pw.TextStyle(
                                  color:  PdfColor.fromInt(0xFFABBBCB),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            pw.Text(
                              subTotalAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFFABBBCB),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.symmetric(vertical: 5),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Coupon Applied',
                                style: pw.TextStyle(
                                  color: PdfColor.fromInt(0xFFABBBCB),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            pw.Text(
                             couponAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFFABBBCB),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      taxList == null
                          ?  pw.SizedBox()
                          : pw.ListView.builder(
                          itemCount: taxList.length,
                          itemBuilder: (pw.Context context, int index){
                            TaxModel taxModel = taxList[index];
                            return pw.Padding(
                              padding:  pw.EdgeInsets.symmetric(
                                  vertical: 5),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(
                                      "${taxModel.title.toString()} (${taxModel.type == "fix"
                                          ? Constant.amountShow(
                                          amount: taxModel.tax)
                                          : "${taxModel.tax}%"})",
                                      style: pw.TextStyle(
                                        color: PdfColor.fromInt(0xFFABBBCB),
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  pw.Text(
                                    "${Constant.amountShow(
                                        amount: Constant()
                                            .calculateTax(
                                            amount: (double.parse(subTotalAmount.replaceAll("\$", "")) -
                                                double.parse(couponAmount.replaceAll("\$", ""))).toString(),
                                            taxModel: taxModel)
                                            .toStringAsFixed(
                                            Constant.currencyModel!.decimalDigits!).toString())} ",
                                    style: pw.TextStyle(
                                      color: PdfColor.fromInt(0xFFABBBCB), //grey03
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      pw.Divider(
                        thickness: 1,
                        color:PdfColor.fromInt(0xFF192933),
                      ),
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.symmetric(vertical: 5),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total',
                                style: pw.TextStyle(
                                  color: PdfColor.fromInt(0xFFABBBCB),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            pw.Text(
                            calculateAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFFABBBCB),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/invoice.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}




Future<File> sendPdfByEmail(String parkingDetailName,String address,
    String parkingSlotId,
    String vehicleName,
    String duration,
    String subTotalAmount,
    String couponAmount,
    String calculateAmount,
    List<TaxModel>? taxList) async {
  ShowToastDialog.showLoader("");
  final pdfFile = await generateAndSavePdf(parkingDetailName,address,parkingSlotId,vehicleName,duration,
      subTotalAmount,couponAmount,calculateAmount,taxList);
  print("pdfFile :--  $pdfFile");
  ShowToastDialog.closeLoader();
  return pdfFile;
}