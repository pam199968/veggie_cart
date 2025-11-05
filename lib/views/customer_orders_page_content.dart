import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model_with_customer.dart';
import '../viewmodels/customer_orders_view_model.dart';
import '../models/order_model.dart';
import 'preparation_tab.dart';
import 'package:veggie_cart/extensions/context_extension.dart';

class CustomerOrdersPageContent extends StatefulWidget {
  const CustomerOrdersPageContent({super.key});

  @override
  State<CustomerOrdersPageContent> createState() =>
      _CustomerOrdersPageContentState();
}

class _CustomerOrdersPageContentState extends State<CustomerOrdersPageContent>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<OrderStatus, bool> _selectedStatuses = {};
  final Map<String, bool> _selectedOffers = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  List<WeeklyOfferSummary> _availableOffers = [];

  late final CustomerOrdersViewModel vm;
  late final VoidCallback _vmListener;

  @override
  void initState() {
    super.initState();

    // 🔹 Initialisation du ViewModel une seule fois
    vm = context.read<CustomerOrdersViewModel>();

    // 🔹 Initialisation des statuts
    for (var status in OrderStatus.values) {
      _selectedStatuses[status] =
          !(status == OrderStatus.ready || status == OrderStatus.delivered);
    }

    // 🔹 Appliquer le filtre initial
    vm.setStatusFilter(_getSelectedStatuses());
    vm.initOrders();

    // 🔹 Écoute du ViewModel
    _vmListener = () {
      if (!mounted) return;
      _updateAvailableOffers();
      setState(() {});
    };
    vm.addListener(_vmListener);

    // 🔹 Scroll infini
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          vm.hasMore &&
          !vm.isLoading) {
        vm.loadMore();
      }
    });

    // 🔹 Onglets
    _tabController = TabController(length: 2, vsync: this);

    // 🔹 Charger les offres initiales
    _updateAvailableOffers();
  }

  @override
  void dispose() {
    vm.removeListener(_vmListener);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<OrderStatus> _getSelectedStatuses() => _selectedStatuses.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  void _applyFilters() {
    vm.setStatusFilter(_getSelectedStatuses());
  }

  void _updateAvailableOffers() {
    final orders = vm.orders.map((o) => o.order).toList();
    final Map<String, WeeklyOfferSummary> unique = {};

    for (var order in orders) {
      final offer = order.offerSummary;
      if (offer.id.isNotEmpty) {
        unique[offer.id] = offer;
      }
    }

    _availableOffers = unique.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    // initialiser les cases à cocher si nécessaire
    for (var offer in _availableOffers) {
      _selectedOffers.putIfAbsent(offer.id, () => true);
    }
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(context.l10n.customerOrdersTitle),
        //automaticallyImplyLeading: false, // suppression du menu redondant
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: context.l10n.ordersListTitle,
              icon: const Icon(Icons.list_alt),
            ),
            Tab(
              text: context.l10n.preparationTitle,
              icon: const Icon(Icons.shopping_basket_outlined),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
            ), // 👈 ton icône personnalisée
            tooltip: context.l10n.filtersTitle, // texte d’aide
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // 👈 ouvre le drawer
            },
          ),
        ],
      ),
      endDrawer: _buildFilterDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrdersTab(), const PreparationTab()],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        // 🔹 Bouton Filtres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${context.l10n.ordersListTitle} (${vm.orders.length})",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ElevatedButton.icon(
              //   icon: const Icon(Icons.filter_list),
              //   label: Text(context.l10n.filtersTitle),
              //   onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              // ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: vm.orders.isEmpty
              ? vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Text(
                          context.l10n.noOrdersFound,
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
                    return CustomerOrderCard(
                      orderWithCustomer: orderWithCustomer,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Drawer _buildFilterDrawer() {
    final allOffersSelected =
        _availableOffers.isNotEmpty &&
        _availableOffers.every((offer) => _selectedOffers[offer.id] == true);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filtres',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Statuts des commandes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                children: OrderStatus.values.map((status) {
                  return CheckboxListTile(
                    title: Text(status.label),
                    value: _selectedStatuses[status],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatuses[status] = value);
                        _applyFilters();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Offres rattachées',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      final newValue = !allOffersSelected;
                      setState(() {
                        for (var offer in _availableOffers) {
                          _selectedOffers[offer.id] = newValue;
                        }
                      });
                      _applyFilters();
                    },
                    child: Text(
                      allOffersSelected
                          ? context.l10n.deselectAll
                          : context.l10n.selectAll,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: _availableOffers.isEmpty
                  ? const Center(child: Text('Aucune offre disponible'))
                  : ListView(
                      children: _availableOffers.map((offer) {
                        final weekRange =
                            "${context.l10n.weekRange} ${_formatDate(offer.startDate)}";
                        return CheckboxListTile(
                          title: Text(offer.title),
                          subtitle: Text(weekRange),
                          value: _selectedOffers[offer.id] ?? true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedOffers[offer.id] = value;
                              });
                              _applyFilters();
                            }
                          },
                        );
                      }).toList(),
                    ),
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
                  '${context.l10n.orderDetails}${order.orderNumber}',
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
                child: Text(
                  '${context.l10n.customer}${customer.givenName} ${customer.name}',
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${context.l10n.status} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  items: OrderStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
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
            Text(
              '${context.l10n.offer} ${order.offerSummary.title} '
              '(${_formatDate(order.offerSummary.startDate)})',
            ),
            Text('${context.l10n.deliveryMethod}${order.deliveryMethod.label}'),
            if (order.notes != null)
              Text('${context.l10n.notes}${order.notes}'),
            const SizedBox(height: 8),
            Text(
              context.l10n.items,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '- ${item.vegetable.name} (${item.vegetable.packaging}) - Qté : ${item.quantity}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";

  static Color _statusColor(OrderStatus status) {
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
