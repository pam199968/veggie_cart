// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/weekly_offer.dart';
import '../repositories/weekly_offers_repository.dart';

enum OfferFilter { all, draft, published, closed }

class WeeklyOffersViewModel extends ChangeNotifier {
  final WeeklyOffersRepository _repository;
  StreamSubscription<List<WeeklyOffer>>? _subscription;

  WeeklyOffersViewModel({required WeeklyOffersRepository repository})
    : _repository = repository {
    _subscribeToOffers(); // 🔹 écoute en temps réel dès l’instanciation
  }

  List<WeeklyOffer> _offers = [];
  bool _loading = true;
  bool isPublishing = false;
  bool get loading => _loading;
  List<WeeklyOffer> get offers => _offers;

  OfferFilter _offerFilter = OfferFilter.published; // 🔹 filtre par défaut
  OfferFilter get offerFilter => _offerFilter;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel(); // 🔹 on arrête le stream proprement
    super.dispose();
  }

  /// 🔹 Annulation des streams lors de la déconnexion
  void cancelSubscriptions() {
    _subscription?.cancel();
    _subscription = null;
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  /// 🔹 Changement du filtre (rafraîchit le stream)
  void setOfferFilter(OfferFilter filter) {
    _offerFilter = filter;
    _subscribeToOffers(); // 🔹 recharge le flux Firestore avec le nouveau filtre
    safeNotifyListeners();
  }

  /// 🔹 Écoute en temps réel via Firestore Stream
  void _subscribeToOffers() {
    _subscription?.cancel(); // annule l’ancien abonnement s’il existe

    WeeklyOfferStatus? status;
    switch (_offerFilter) {
      case OfferFilter.draft:
        status = WeeklyOfferStatus.draft;
        break;
      case OfferFilter.published:
        status = WeeklyOfferStatus.published;
        break;
      case OfferFilter.closed:
        status = WeeklyOfferStatus.closed;
        break;
      case OfferFilter.all:
        status = null;
        break;
    }

    _loading = true;
    safeNotifyListeners();

    // 🔹 on écoute les changements Firestore en temps réel
    _subscription = _repository.streamWeeklyOffers(status: status).listen((
      snapshot,
    ) {
      _offers = snapshot;
      _loading = false;
      safeNotifyListeners();
    });
  }

  /// 🔹 Création d'une nouvelle offre
  Future<void> createOffer(WeeklyOffer offer) async {
    final newOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.createWeeklyOffer(newOffer);
  }

  /// 🔹 Mise à jour
  Future<void> updateOffer(WeeklyOffer offer) async {
    await _repository.updateWeeklyOffer(offer);
  }

  /// 🔹 Duplication
  Future<void> duplicateOffer(
    WeeklyOffer source,
    DateTime start,
    DateTime end,
  ) async {
    await _repository.duplicateWeeklyOffer(
      original: source,
      newStartDate: start,
      newEndDate: end,
    );
  }

  /// 🔹 Publication d'une offre (avec envoi d’email via Cloud Functions)
  Future<void> publishOffer(WeeklyOffer offer, BuildContext context) async {
    if (isPublishing) return;
    isPublishing = true;
    safeNotifyListeners();

    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.published);
    await _repository.updateWeeklyOffer(updatedOffer);

    final dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    final callable = FirebaseFunctions.instance.httpsCallable(
      'sendWeeklyOfferEmail',
    );

    try {
      final List<Map<String, dynamic>> vegetableList = offer.vegetables.map((
        veg,
      ) {
        return {
          'name': veg.name,
          'price': veg.price ?? 0,
          'packaging': veg.packaging,
          'standardQuantity': veg.standardQuantity,
        };
      }).toList();

      await callable.call({
        'offer': {
          'title': offer.title,
          'description': offer.description,
          'startDate': dateFormatter.format(offer.startDate),
          'endDate': dateFormatter.format(offer.endDate),
          'vegetables': vegetableList,
        },
      });
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de la notification : $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification non envoyée.')),
        );
      }
    } finally {
      isPublishing = false;
      safeNotifyListeners();
    }
  }

  /// 🔹 Clôturer / Réouvrir
  Future<void> closeOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.closed);
    await _repository.updateWeeklyOffer(updatedOffer);
  }

  Future<void> reopenOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.updateWeeklyOffer(updatedOffer);
  }
}
