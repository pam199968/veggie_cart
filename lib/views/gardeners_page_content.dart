import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/account_view_model.dart';
import '../models/user_model.dart';
import 'package:veggie_cart/extensions/context_extension.dart';
import 'dart:async';

class GardenersPageContent extends StatelessWidget {
  const GardenersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = context.watch<AccountViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gardenersListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.addGardenerTooltip,
            onPressed: () => _showAddGardenerDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: accountViewModel.gardenersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(context.l10n.noGardenersFound));
          }

          final gardeners = snapshot.data!;
          final currentUser = accountViewModel.currentUser;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gardeners.length,
            itemBuilder: (context, index) {
              final user = gardeners[index];
              final isCurrentUser = user.id == currentUser.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  title: Text('${user.givenName} ${user.name}'),
                  subtitle: Text(user.email),
                  trailing: isCurrentUser
                      ? null // 👈 pas de bouton pour l'utilisateur courant
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Désactiver",
                          onPressed: () async {
                            try {
                              await accountViewModel.toggleGardenerStatus(
                                context,
                                user,
                                false,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${user.givenName} ${user.name} ${context.l10n.userHasBeenDeactivated}.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${context.l10n.unableToDeactivateUser} ${user.givenName} ${user.name}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddGardenerDialog(BuildContext context) async {
    final accountViewModel = Provider.of<AccountViewModel>(
      context,
      listen: false,
    );
    final TextEditingController searchController = TextEditingController();
    List<UserModel> searchResults = [];
    Timer? debounce;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void onSearchChanged(String query) {
              if (debounce?.isActive ?? false) debounce!.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () async {
                if (query.isNotEmpty) {
                  final results = await accountViewModel.searchCustomers(
                    query.trim(),
                  );
                  setState(() {
                    searchResults = results;
                  });
                } else {
                  setState(() {
                    searchResults = [];
                  });
                }
              });
            }

            return AlertDialog(
              title: Text(context.l10n.addGardenerDialogTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: context.l10n.searchUserLabel,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    if (searchResults.isEmpty)
                      Text(context.l10n.noResults)
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            return ListTile(
                              title: Text('${user.givenName} ${user.name}'),
                              subtitle: Text(user.email),
                              onTap: () async {
                                await accountViewModel.promoteToGardener(
                                  context,
                                  user,
                                );
                                if (context.mounted) Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.cancel),
                ),
              ],
            );
          },
        );
      },
    );

    debounce?.cancel();
  }
}