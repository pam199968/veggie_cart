// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:au_bio_jardin_app/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../extensions/context_extension.dart';
import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../viewmodels/account_view_model.dart';
import 'offers_page_content.dart';

class CustomersPageContent extends StatefulWidget {
  final void Function(UserModel customer)? onCreateOrder;
  const CustomersPageContent({super.key, this.onCreateOrder});

  @override
  State<CustomersPageContent> createState() => _CustomersPageContentState();
}

class _CustomersPageContentState extends State<CustomersPageContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();

    return Column(
      children: [
        // 🔍 Barre de recherche
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: AppLocalizations.of(context)!.searchCustomer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: accountVM.customersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${context.l10n.errorLoadingData} : ${snapshot.error}',
                  ),
                );
              }

              var customers = snapshot.data ?? [];

              // 🔎 Filtrage local par nom ou prénom
              if (_searchQuery.isNotEmpty) {
                customers = customers.where((c) {
                  final fullName = '${c.givenName} ${c.name}'.toLowerCase();
                  return fullName.contains(_searchQuery);
                }).toList();
              }

              if (customers.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noCustomersFound),
                );
              }

              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  final isActive = customer.isActive;

                  return Card(
                    color: isActive ? Colors.white : Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: isActive
                                  ? Colors.green
                                  : Colors.grey,
                              child: Icon(
                                isActive ? Icons.person : Icons.person_off,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${customer.givenName} ${customer.name}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.black : Colors.grey,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customer.email.isNotEmpty)
                                  Text(customer.email),
                                if (customer.phoneNumber.isNotEmpty)
                                  Text('📞 ${customer.phoneNumber}'),
                                if (customer.address.isNotEmpty)
                                  Text('🏠 ${customer.address}'),
                                if (!isActive)
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.accountDeactivated,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🔒 Activer / désactiver
                                IconButton(
                                  icon: Icon(
                                    isActive ? Icons.lock : Icons.lock_open,
                                    color: isActive
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                  ),
                                  tooltip: isActive
                                      ? AppLocalizations.of(
                                          context,
                                        )!.disableAccount
                                      : AppLocalizations.of(
                                          context,
                                        )!.reactivateAccount,
                                  onPressed: () async {
                                    if (context.mounted) {
                                      if (isActive) {
                                        await accountVM.disableCustomerAccount(
                                          context,
                                          customer,
                                        );
                                      } else {
                                        await accountVM.enableCustomerAccount(
                                          context,
                                          customer,
                                        );
                                      }
                                    }
                                  },
                                ),

                                // 🗑️ SUPPRESSION (visible seulement pour gardener)
                                if (accountVM.currentUser.profile ==
                                    Profile.gardener)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Supprimer",
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text(
                                            "Confirmer la suppression",
                                          ),
                                          content: Text(
                                            "Supprimer définitivement ${customer.givenName} ${customer.name} ?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text("Annuler"),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                "Supprimer",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && context.mounted) {
                                        await accountVM.deleteCustomer(
                                          context,
                                          customer,
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 🟩 Bouton "Créer une commande"
                          if (isActive)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Créer une commande',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          title: Text('Offres disponibles'),
                                        ),
                                        body: OffersPageContent(user: customer),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
