import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phista/constant/show_toast_dialog.dart';
import 'package:phista/env.dart';

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
  final imageData = await rootBundle.load('assets/images/phistaIcon.png');
  final image = pw.MemoryImage(imageData.buffer.asUint8List());
  final String formattedDate = "Date: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}";

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
             // pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 105,
                    height: 52,
                    child: pw.Image(image, fit: pw.BoxFit.cover),
                  ),
                  pw.Text(
                    "INVOICE",
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold
                    ),
                  ),
                ]
              ),
              pw.SizedBox(height: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Phista Technologies inc.",
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 15.5,
                        fontWeight: pw.FontWeight.normal
                    ),
                  ),
                  pw.Text(
                    "2551 Saint-Louis, Gatineau, QC J8V 1A4",
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 15.5,
                        fontWeight: pw.FontWeight.normal
                    ),
                  ),
                  pw.Text(
                    ENV.adminEmail,
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 15.5,
                        fontWeight: pw.FontWeight.normal
                    ),
                  ),
                ]
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                formattedDate,
                style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF000000),
                    fontSize: 15.5,
                    fontWeight: pw.FontWeight.normal
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                "Bill to:",
                style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF000000),
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold
                ),
              ),
              pw.Row(
                children:[
                  pw.Text(
                    "Name: ",
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 15,
                        fontWeight: pw.FontWeight.normal
                    ),
                  ),
                  pw.Text(
                    Constant.currentUserModel.value?.fullName??"",
                    style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF000000),
                        fontSize: 15,
                        fontWeight: pw.FontWeight.normal
                    ),
                  ),

                ]
              ),
              pw.Row(
                  children:[
                    pw.Text(
                      "Email: ",
                      style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFF000000),
                          fontSize: 15,
                          fontWeight: pw.FontWeight.normal
                      ),
                    ),
                    pw.Text(
                      Constant.currentUserModel.value?.email??"",
                      style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFF000000),
                          fontSize: 15,
                          fontWeight: pw.FontWeight.normal
                      ),
                    ),

                  ]
              ),
              pw.Row(
                  children:[
                    pw.Text(
                      "Phone: ",
                      style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFF000000),
                          fontSize: 15,
                          fontWeight: pw.FontWeight.normal
                      ),
                    ),
                    pw.Text(
                      Constant.currentUserModel.value?.phoneNumber??"",
                      style: pw.TextStyle(
                          color: PdfColor.fromInt(0xFF000000),
                          fontSize: 15,
                          fontWeight: pw.FontWeight.normal
                      ),
                    ),

                  ]
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                "Description:",
                style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF000000),
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold
                ),
              ),
              pw.Row(
                children:[
                  /*pw.Container(
                    width: 50,
                    height: 50,
                    child: pw.Image(image, fit: pw.BoxFit.cover),
                  ),
                  pw.SizedBox(width: 10),*/
                  pw.Expanded(
                    child:  pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "ParkingName: $parkingDetailName",
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF000000),
                              fontSize: 15.5,
                              fontWeight: pw.FontWeight.normal
                            ),
                          ),
                          /*pw.SizedBox(height: 10),*/
                          pw.Text(
                            address,
                            style: pw.TextStyle(
                              color: PdfColor.fromInt(0xFF000000),
                              fontSize: 15.5,
                            ),
                          ),
                        ])
                  )
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 5),
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
                                //color: PdfColor.fromInt(0xFF3B5F75),
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Parking Slot",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
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
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Vehicle Detail",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
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
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Time Duration",
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
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
                                  color:  PdfColor.fromInt(0xFF000000),
                                  fontSize: 15.5,
                                ),
                              ),
                            ),
                            pw.Text(
                              subTotalAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
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
                                  color: PdfColor.fromInt(0xFF000000),
                                  fontSize: 15.5,
                                ),
                              ),
                            ),
                            pw.Text(
                             couponAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
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
                                        color: PdfColor.fromInt(0xFF000000),
                                        fontSize: 15.5,
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
                                      color: PdfColor.fromInt(0xFF000000), //grey03
                                      fontSize: 15.5,
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
                                  color: PdfColor.fromInt(0xFF000000),
                                  fontSize: 15.5,
                                ),
                              ),
                            ),
                            pw.Text(
                            calculateAmount.toString(),
                              style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFF000000),
                                fontSize: 15.5,
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