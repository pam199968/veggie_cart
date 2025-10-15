import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/account_view_model.dart';
import '../models/user_model.dart';
import '../models/profile.dart';
import 'dart:async';

class GardenersPageContent extends StatelessWidget {
  const GardenersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = context.watch<AccountViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des maraîchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un maraîcher',
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
            return const Center(child: Text('Aucun maraîcher trouvé.'));
          }

          final gardeners = snapshot.data!;
          final currentUser = accountViewModel.currentUser; // récupère l'utilisateur connecté

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gardeners.length,
            itemBuilder: (context, index) {
              final user = gardeners[index];
              final isGardener = user.profile == Profile.gardener;
              // Vérifie si c'est l'utilisateur connecté
              final isCurrentUser = user.id == currentUser.id;  

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  title: Text('${user.givenName} ${user.name}'),
                  subtitle: Text(user.email),
                  trailing: Checkbox(
                    value: isGardener,
                    onChanged: isCurrentUser
                  ? null // checkbox read-only si c'est l'utilisateur connecté
                  : (value) {
                      if (value != null) {
                        accountViewModel.toggleGardenerStatus(context, user, value);
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

  /// 🧩 Dialogue d’ajout de maraîcher
  Future<void> _showAddGardenerDialog(BuildContext context) async {
    final accountViewModel = Provider.of<AccountViewModel>(context, listen: false);
    final TextEditingController searchController = TextEditingController();
    List<UserModel> searchResults = [];
    Timer? debounce;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fonction interne de recherche avec délai (debounce)
            void onSearchChanged(String query) {
              if (debounce?.isActive ?? false) debounce!.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () async {
                if (query.isNotEmpty) {
                  final results = await accountViewModel.searchCustomers(query.trim());
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
              title: const Text('Ajouter un maraîcher'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Rechercher un utilisateur',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    if (searchResults.isEmpty)
                      const Text('Aucun résultat')
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
                                await accountViewModel.promoteToGardener(context, user);
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
                  child: const Text('Annuler'),
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
