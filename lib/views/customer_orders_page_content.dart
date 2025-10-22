import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/models/delivery_method.dart';
import '../models/order_model_with_customer.dart';
import '../viewmodels/customer_orders_view_model.dart';
import '../models/order_model.dart';

class CustomerOrdersPageContent extends StatefulWidget {
  const CustomerOrdersPageContent({super.key});

  @override
  State<CustomerOrdersPageContent> createState() =>
      _CustomerOrdersPageContentState();
}

class _CustomerOrdersPageContentState extends State<CustomerOrdersPageContent> {
  final ScrollController _scrollController = ScrollController();
  final Map<OrderStatus, bool> _selectedStatuses = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final vm = context.read<CustomerOrdersViewModel>();

    // 🔹 Initialisation : exclure "ready" & "delivered" par défaut
    for (var status in OrderStatus.values) {
      _selectedStatuses[status] =
          !(status == OrderStatus.ready || status == OrderStatus.delivered);
    }

    vm.setStatusFilter(_getSelectedStatuses());
    vm.initOrders();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          vm.hasMore &&
          !vm.isLoading) {
        vm.loadMore();
      }
    });
  }

  List<OrderStatus> _getSelectedStatuses() {
    return _selectedStatuses.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  void _onStatusChanged(OrderStatus status, bool value) {
    setState(() => _selectedStatuses[status] = value);
    context.read<CustomerOrdersViewModel>().setStatusFilter(_getSelectedStatuses());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerOrdersViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Commandes clients')),
      endDrawer: _buildFilterDrawer(context),
      body: Column(
        children: [
          // 🔹 Bouton "Filtres"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Liste des commandes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filtres"),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 🔹 Liste des commandes
          Expanded(
            child: vm.orders.isEmpty
                ? vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(
                        child: Text(
                          "Aucune commande trouvée.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: vm.orders.length + (vm.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == vm.orders.length) {
                        vm.loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final orderWithCustomer = vm.orders[index];
                      return CustomerOrderCard(orderWithCustomer: orderWithCustomer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔹 Drawer latéral avec filtres
  Widget _buildFilterDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Filtres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 🔹 Section "Statuts"
            const Text(
              'Statut de la commande',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ...OrderStatus.values.map(
              (status) => CheckboxListTile(
                title: Text(status.label),
                value: _selectedStatuses[status],
                onChanged: (value) {
                  if (value != null) _onStatusChanged(status, value);
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Placeholder pour futurs filtres
            const Text(
              'Autres filtres (à venir)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Exemple : méthode de livraison, date, client, etc.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerOrderCard extends StatelessWidget {
  final OrderModelWithCustomer orderWithCustomer;

  const CustomerOrderCard({super.key, required this.orderWithCustomer});

  @override
  Widget build(BuildContext context) {
    final order = orderWithCustomer.order;
    final customer = orderWithCustomer.customer;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Commande n°${order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _statusColor(order.status),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            if (customer != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Client: ${customer.givenName} ${customer.name}'),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text(
                  'Statut: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  items: OrderStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ))
                      .toList(),
                  onChanged: (newStatus) async {
                    if (newStatus != null) {
                      final vm = context.read<CustomerOrdersViewModel>();
                      await vm.updateOrderStatus(order.id, newStatus);
                    }
                  },
                ),
              ],
            ),
            Text('Méthode de livraison: ${order.deliveryMethod.label}'),
            if (order.notes != null) Text('Notes: ${order.notes}'),
            const SizedBox(height: 8),
            const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '- ${item.vegetable.name} (${item.vegetable.packaging}) - Qté : ${item.quantity}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Créée le: ${order.createdAt.toLocal()}'),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
