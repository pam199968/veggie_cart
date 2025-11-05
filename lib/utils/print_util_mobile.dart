import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


/// 🥬 Impression "Préparation par légume"
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

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

/// 👤 Impression "Préparation par client"
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
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              padding: const pw.EdgeInsets.all(8),
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

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

