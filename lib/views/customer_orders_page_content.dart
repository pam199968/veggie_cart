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

  String? _selectedOfferId;
  List<WeeklyOfferSummary> _availableOffers = [];
  late final VoidCallback _vmListener;

  @override
  void initState() {
    super.initState();
    final vm = context.read<CustomerOrdersViewModel>();

    // 🔹 Initialisation : exclure "ready" & "delivered" par défaut
    for (var status in OrderStatus.values) {
      _selectedStatuses[status] =
          !(status == OrderStatus.ready || status == OrderStatus.delivered);
    }

    // applique le filtre initial (cela lance un reload côté ViewModel)
    vm.setStatusFilter(_getSelectedStatuses());

    // écoute le ViewModel pour mettre à jour les offres disponibles
    _vmListener = () {
      // lorsque vm.orders change, on met à jour les offres disponibles
      _updateAvailableOffers();
      // on remplace l'appel à setState seulement si mounted et si l'UI a besoin d'être rafraîchi
      if (mounted) setState(() {});
    };
    vm.addListener(_vmListener);

    // initialise le chargement (initOrders fera notifyListeners lorsque prêt)
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

  final Map<String, bool> _selectedOffers = {};

  List<WeeklyOfferSummary> _getAvailableOffers(CustomerOrdersViewModel vm) {
    final offers = vm.orders.map((o) => o.order.offerSummary).toSet().toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    // Synchroniser les nouvelles offres dans la map
    for (var offer in offers) {
      _selectedOffers.putIfAbsent(offer.id, () => true);
    }
    return offers;
  }

  void _applyFilters(CustomerOrdersViewModel vm) {
    final filteredStatuses = _getSelectedStatuses();
    final selectedOfferIds = _selectedOffers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    vm.setStatusFilter(filteredStatuses);
    // Tu pourras ensuite étendre ici pour ajouter un setOfferFilter(selectedOfferIds)
  }

  void _refreshOfferFilter(CustomerOrdersViewModel vm) {
    setState(() {
      _selectedOffers.clear();
      for (var offer in _getAvailableOffers(vm)) {
        _selectedOffers[offer.id] = true;
      }
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  void _updateAvailableOffers() {
    final vm = context.read<CustomerOrdersViewModel>();

    // récupère les offers uniquement depuis les commandes présentes
    final orders = vm.orders.map((o) => o.order).toList();

    // construit une map id -> WeeklyOfferSummary (ignore id nuls/vide)
    final Map<String, WeeklyOfferSummary> unique = {};
    for (var order in orders) {
      final offer = order.offerSummary;
      if (offer.id.isNotEmpty) {
        unique[offer.id] = offer;
      }
    }

    _availableOffers = unique.values.toList();
  }

  @override
  void dispose() {
    final vm = context.read<CustomerOrdersViewModel>();
    vm.removeListener(_vmListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerOrdersViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Commandes clients')),
      endDrawer: _buildFilterDrawer(vm),
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
                      return CustomerOrderCard(
                        orderWithCustomer: orderWithCustomer,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔹 Drawer latéral avec filtres
  Drawer _buildFilterDrawer(CustomerOrdersViewModel vm) {
    // 🔹 On synchronise les offres disponibles avant tout
    final availableOffers = _getAvailableOffers(vm);

    // 🔹 Calcul dynamique : est-ce que toutes les offres sont cochées ?
    final allOffersSelected =
        availableOffers.isNotEmpty &&
        availableOffers.every((offer) => _selectedOffers[offer.id] == true);

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

            // 🔹 Filtre par statut
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
                        setState(() {
                          _selectedStatuses[status] = value;
                        });
                        vm.setStatusFilter(_getSelectedStatuses());
                        _refreshOfferFilter(vm);
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            // 🔹 Filtre par offre
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
                        for (var offer in availableOffers) {
                          _selectedOffers[offer.id] = newValue;
                        }
                      });
                      _applyFilters(vm);
                    },
                    child: Text(
                      allOffersSelected ? 'Tout décocher' : 'Tout cocher',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 3,
              child: availableOffers.isEmpty
                  ? const Center(child: Text('Aucune offre disponible'))
                  : ListView(
                      children: availableOffers.map((offer) {
                        final weekRange =
                            "Semaine du ${_formatDate(offer.startDate)}";
                        return CheckboxListTile(
                          title: Text(offer.title),
                          subtitle: Text(weekRange),
                          value: _selectedOffers[offer.id] ?? true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedOffers[offer.id] = value;
                              });
                              _applyFilters(vm);
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
              'Offre : ${order.offerSummary.title} '
              '(${_formatDate(order.offerSummary.startDate)})',
            ),
            Text('Méthode de livraison: ${order.deliveryMethod.label}'),
            if (order.notes != null) Text('Notes: ${order.notes}'),
            const SizedBox(height: 8),
            const Text(
              'Articles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
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
