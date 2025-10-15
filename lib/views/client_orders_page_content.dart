import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/delivery_method.dart';
import '../viewmodels/account_view_model.dart';
import '../i18n/strings.dart';

class ClientOrdersPageContent extends StatelessWidget {
  const ClientOrdersPageContent({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Liste des commandes'));
  }
}
