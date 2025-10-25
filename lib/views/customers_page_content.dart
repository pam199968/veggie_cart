import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veggie_cart/extensions/context_extension.dart';
import 'package:veggie_cart/models/delivery_method.dart';
import '../models/user_model.dart';
import '../viewmodels/account_view_model.dart';

class CustomersPageContent extends StatelessWidget {
  const CustomersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();

    return StreamBuilder<List<UserModel>>(
      stream: accountVM.customersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${context.l10n.errorLoadingData} : ${snapshot.error}'),
          );
        }

        final customers = snapshot.data ?? [];

        if (customers.isEmpty) {
          return Center(child: Text(context.l10n.noCustomersFound));
        }

        return ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.greenAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('${customer.givenName} ${customer.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.email.isNotEmpty) Text(customer.email),
                    if (customer.phoneNumber.isNotEmpty)
                      Text('📞 ${customer.phoneNumber}'),
                    if (customer.address.isNotEmpty)
                      Text('🏠 ${customer.address}'),
                  ],
                ),
                trailing: Text(
                  customer.deliveryMethod.label,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
