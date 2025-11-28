// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:au_bio_jardin_app/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/my_orders_view_model.dart';
import '../models/order_model.dart';
import '../l10n/app_localizations.dart';

class MyOrdersPageContent extends StatefulWidget {
  const MyOrdersPageContent({super.key});

  @override
  State<MyOrdersPageContent> createState() => _MyOrdersPageContentState();
}

class _MyOrdersPageContentState extends State<MyOrdersPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<OrderViewModel>();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myOrders)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.orders.isEmpty
            ? vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Text(
                        AppLocalizations.of(context)!.youHaveNoOrders,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
            : ListView.builder(
                itemCount: vm.orders.length + (vm.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == vm.orders.length) {
                    // déclenche le chargement de la page suivante
                    vm.loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final order = vm.orders[index];
                  return OrderCard(order: order);
                },
              ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OrderViewModel>();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.order +
                  order.orderNumber.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.status + order.status.label,
              style: TextStyle(
                color: _statusColor(order.status),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.deliveryMethod +
                  order.deliveryMethod.label,
            ),
            if (order.notes != null)
              Text('${AppLocalizations.of(context)!.notes} ${order.notes}'),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.items,
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
            const SizedBox(height: 8),
            Text(
              context.l10n.createdAt +
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(order.createdAt.toLocal()),
            ),

            const SizedBox(height: 12),

            /// 🔹 Bouton Annuler si statut = pending
            if (order.status == OrderStatus.pending)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final confirm = await _showCancelDialog(context);
                    if (confirm == true) {
                      vm.cancelOrder(order.id);
                    }
                  },
                  child: Text(context.l10n.cancelOrder),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cancelOrder),
        content: Text(context.l10n.confirmCancelOrder),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.yes),
          ),
        ],
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
