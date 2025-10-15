import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/account_view_model.dart';
import '../models/user_model.dart';
import '../models/profile.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';

class GardenersPageContent extends StatelessWidget {
  const GardenersPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final accountViewModel = context.watch<AccountViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gardenersListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.addGardenerTooltip,
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
            return Center(child: Text(AppLocalizations.of(context)!.noGardenersFound));
          }

          final gardeners = snapshot.data!;
          final currentUser = accountViewModel.currentUser;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: gardeners.length,
            itemBuilder: (context, index) {
              final user = gardeners[index];
              final isGardener = user.profile == Profile.gardener;
              final isCurrentUser = user.id == currentUser.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  title: Text('${user.givenName} ${user.name}'),
                  subtitle: Text(user.email),
                  trailing: Checkbox(
                    value: isGardener,
                    onChanged: isCurrentUser
                      ? null
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
              title: Text(AppLocalizations.of(context)!.addGardenerDialogTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.searchUserLabel,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    if (searchResults.isEmpty)
                      Text(AppLocalizations.of(context)!.noResults)
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
                  child: Text(AppLocalizations.of(context)!.cancel),
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
