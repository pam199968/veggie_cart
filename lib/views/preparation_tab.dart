import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/customer_orders_view_model.dart';
import '../models/order_model.dart';
import '../utils/print_util.dart';
import '../extensions/context_extension.dart';

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
                                    rows:
                                        (vegTotals.entries.toList()..sort(
                                              (a, b) => a.key.compareTo(b.key),
                                            )) // 🔹 Tri alphabétique
                                            .map((entry) {
                                              final data = entry.value;
                                              final conditionnement =
                                                  "${data['standardQuantity']} ${data['packaging']}";
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(entry.key)),
                                                  DataCell(
                                                    Text(
                                                      data['quantity']
                                                          .toString(),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(conditionnement),
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                // 👤 Onglet "Par client" — affichage détaillé par commande
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
                                          Text(
                                            customerName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // 🔽 Affichage des commandes du client
                                          ...orders.map((order) {
                                            // Info commande
                                            final deliveryMethod =
                                                order.deliveryMethod.label;
                                            final orderId =
                                                order.orderNumber ?? "–";

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "🧾 ${context.l10n.order} $orderId",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        deliveryMethod,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Tableau des items de la commande
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: DataTable(
                                                      columns: [
                                                        DataColumn(
                                                          label: Text(
                                                            context
                                                                .l10n
                                                                .vegetable,
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Text(
                                                            context
                                                                .l10n
                                                                .quantity,
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Text(
                                                            context
                                                                .l10n
                                                                .packaging,
                                                          ),
                                                        ),
                                                      ],
                                                      rows: (() {
                                                        // 🔹 Tri alphabétique des légumes
                                                        final sortedItems =
                                                            order.items..sort(
                                                              (a, b) => a
                                                                  .vegetable
                                                                  .name
                                                                  .compareTo(
                                                                    b
                                                                        .vegetable
                                                                        .name,
                                                                  ),
                                                            );

                                                        return sortedItems.map((
                                                          item,
                                                        ) {
                                                          return DataRow(
                                                            cells: [
                                                              DataCell(
                                                                Text(
                                                                  item
                                                                      .vegetable
                                                                      .name,
                                                                ),
                                                              ),
                                                              DataCell(
                                                                Text(
                                                                  item.quantity
                                                                      .toString(),
                                                                ),
                                                              ),
                                                              DataCell(
                                                                Text(
                                                                  "${item.vegetable.standardQuantity} ${item.vegetable.packaging}",
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList();
                                                      })(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
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
