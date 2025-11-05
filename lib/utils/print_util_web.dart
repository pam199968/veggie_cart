import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 🥬 Version Web - "Préparation par légume"
Future<void> printVegetableTableImpl(List<List<String>> rows) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (_) => [
        pw.Center(
          child: pw.Text(
            'Préparation par légume',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Légume', 'Qté totale', 'Conditionnement'],
          data: rows,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
          border: pw.TableBorder.all(color: PdfColors.grey),
        ),
      ],
    ),
  );

  final Uint8List bytes = await pdf.save();

  // Convertir les bytes en JSUint8Array
  final jsArray = bytes.toJS;

  // Créer un Blob à partir des bytes
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'application/pdf'));

  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  web.URL.revokeObjectURL(url);
}

/// 👤 Version Web - "Préparation par client"
Future<void> printCustomerOrdersImpl(Map<String, List<dynamic>> ordersByCustomer) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (_) {
        final widgets = <pw.Widget>[
          pw.Center(
            child: pw.Text(
              'Préparation par client',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
        ];

        ordersByCustomer.forEach((customerName, orders) {
          final deliveryMethod = orders.first.deliveryMethod.label;
          final List<List<String>> vegRows = [];

          for (var order in orders) {
            for (var item in order.items) {
              vegRows.add([
                item.vegetable.name,
                item.quantity.toString(),
                "${item.vegetable.standardQuantity} ${item.vegetable.packaging}",
              ]);
            }
          }

          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        customerName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.Text('Livraison : $deliveryMethod'),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.TableHelper.fromTextArray(
                    headers: ['Légume', 'Quantité', 'Conditionnement'],
                    data: vegRows,
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.teal),
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                  ),
                ],
              ),
            ),
          );
        });

        return widgets;
      },
    ),
  );

  final Uint8List bytes = await pdf.save();

  // Convertir les bytes en JSUint8Array
  final jsArray = bytes.toJS;

  // Créer un Blob à partir des bytes
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'application/pdf'));
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  web.URL.revokeObjectURL(url);
}


