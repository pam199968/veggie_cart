import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/models/delivery_method.dart';
import '../viewmodels/customer_orders_view_model.dart';
import '../models/order_model.dart';
import '../utils/print_util.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class PreparationTab extends StatefulWidget {
  const PreparationTab({super.key});

  @override
  State<PreparationTab> createState() => _PreparationTabState();
}

class _PreparationTabState extends State<PreparationTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerOrdersViewModel>();
    final filteredOrders = vm.orders.map((o) => o.order).toList();

    // 🔹 Grouper par légume et sommer les quantités
    final Map<String, Map<String, dynamic>> vegTotals = {};
    for (var order in filteredOrders) {
      for (var item in order.items) {
        final veg = item.vegetable;
        final key = veg.name;
        if (vegTotals.containsKey(key)) {
          vegTotals[key]!['quantity'] += item.quantity;
        } else {
          vegTotals[key] = {
            'quantity': item.quantity,
            'packaging': veg.packaging,
            'standardQuantity': veg.standardQuantity,
          };
        }
      }
    }

    // 🔹 Grouper par client pour “Par client”
    final Map<String, List<OrderModel>> ordersByCustomer = {};
    for (var orderWithCustomer in vm.orders) {
      final customer = orderWithCustomer.customer;
      if (customer != null) {
        final customerKey = "${customer.givenName} ${customer.name}";
        ordersByCustomer
            .putIfAbsent(customerKey, () => [])
            .add(orderWithCustomer.order);
      }
    }

    return SafeArea(
      child: Column(
        children: [
          TabBar(
            controller: _subTabController,
            tabs: [
              Tab(text: context.l10n.byVegetable),
              Tab(text: context.l10n.byCustomer),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _subTabController,
              children: [
                // 🥬 Onglet "Par légume"
                vegTotals.isEmpty
                    ? Center(child: Text(context.l10n.noOrders))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.vegetablePreparation,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print),
                                  tooltip: context.l10n.print,
                                  onPressed: () async {
                                    final rows = vegTotals.entries.map((entry) {
                                      final data = entry.value;
                                      return [
                                        entry.key,
                                        data['quantity'].toString(),
                                        "${data['standardQuantity']} ${data['packaging']}",
                                      ];
                                    }).toList();
                                    await printVegetableTable(rows);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: [
                                      DataColumn(
                                        label: Text(context.l10n.vegetable),
                                      ),
                                      DataColumn(
                                        label: Text(context.l10n.totalQuantity),
                                      ),
                                      DataColumn(
                                        label: Text(context.l10n.packaging),
                                      ),
                                    ],
                                    rows: vegTotals.entries.map((entry) {
                                      final data = entry.value;
                                      final conditionnement =
                                          "${data['standardQuantity']} ${data['packaging']}";
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(entry.key)),
                                          DataCell(
                                            Text(data['quantity'].toString()),
                                          ),
                                          DataCell(Text(conditionnement)),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                // 👤 Onglet "Par client" — affichage direct et imprimable
                ordersByCustomer.isEmpty
                    ? Center(child: Text(context.l10n.noOrders))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.customerPreparation,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print),
                                  tooltip: context.l10n.print,
                                  onPressed: () async {
                                    await printCustomerOrders(ordersByCustomer);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: ordersByCustomer.entries.map((entry) {
                                  final customerName = entry.key;
                                  final orders = entry.value;
                                  final deliveryMethod =
                                      orders.first.deliveryMethod.label;

                                  // Agréger tous les légumes de ce client
                                  final List<Map<String, String>> vegetables =
                                      [];
                                  for (var order in orders) {
                                    for (var item in order.items) {
                                      vegetables.add({
                                        'name': item.vegetable.name,
                                        'quantity': item.quantity.toString(),
                                        'packaging':
                                            "${item.vegetable.standardQuantity} ${item.vegetable.packaging}",
                                      });
                                    }
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                customerName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                context.l10n.delivery +
                                                    deliveryMethod,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(
                                                    label: Text(
                                                      context.l10n.vegetable,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      context.l10n.quantity,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      context.l10n.packaging,
                                                    ),
                                                  ),
                                                ],
                                                rows: vegetables.map((veg) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(veg['name']!),
                                                      ),
                                                      DataCell(
                                                        Text(veg['quantity']!),
                                                      ),
                                                      DataCell(
                                                        Text(veg['packaging']!),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
