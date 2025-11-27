import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 🥬 Version Web - "Préparation par légume"
Future<void> printVegetableTableImpl(List<List<String>> rows) async {
  // 🔹 Tri alphabétique des légumes (colonne 0)
  rows.sort((a, b) => a[0].compareTo(b[0]));

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
  final jsArray = bytes.toJS;
  final blob = web.Blob(
    [jsArray].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  web.URL.revokeObjectURL(url);
}

/// 👤 Version Web - "Préparation par client" (détail par commande)
Future<void> printCustomerOrdersImpl(
  Map<String, List<dynamic>> ordersByCustomer,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
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

        // 🔹 Tri alphabétique des clients
        final sortedCustomers = ordersByCustomer.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        for (var entry in sortedCustomers) {
          final customerName = entry.key;
          final orders = entry.value;

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
                  // 👤 Nom du client
                  pw.Text(
                    customerName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // 🔽 Affichage des commandes du client
                  ...orders.map((order) {
                    final orderId = order.orderNumber ?? "-";
                    final deliveryMethod = order.deliveryMethod.label;

                    // 🔹 Création et tri des légumes dans la commande
                    final List<List<String>> vegRows = order.items
                        .map<List<String>>(
                          (item) => <String>[
                            item.vegetable.name,
                            item.quantity.toString(),
                            "${item.vegetable.standardQuantity} ${item.vegetable.packaging}",
                          ],
                        )
                        .toList()
                        .cast<List<String>>();
                    
                    // ✅ Tri alphabétique
                    vegRows.sort((a, b) => a[0].compareTo(b[0]));

                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // 🧾 En-tête de commande
                        pw.Text(
                          "Commande $orderId - $deliveryMethod",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        pw.SizedBox(height: 4),

                        // Tableau des légumes de la commande
                        pw.TableHelper.fromTextArray(
                          headers: ['Légume', 'Quantité', 'Conditionnement'],
                          data: vegRows,
                          headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.teal,
                          ),
                          border: pw.TableBorder.all(color: PdfColors.grey300),
                        ),
                        pw.SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }

        return widgets;
      },
    ),
  );

  final Uint8List bytes = await pdf.save();
  final jsArray = bytes.toJS;
  final blob = web.Blob(
    [jsArray].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
  web.URL.revokeObjectURL(url);
}
