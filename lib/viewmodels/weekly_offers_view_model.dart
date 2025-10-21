import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/weekly_offer.dart';
import '../repositories/weekly_offers_repository.dart';

class WeeklyOffersViewModel extends ChangeNotifier {
  final WeeklyOffersRepository _repository;


  WeeklyOffersViewModel({required WeeklyOffersRepository repository})
      : _repository = repository;

  List<WeeklyOffer> _offers = [];
  bool _loading = false;
  bool get loading => _loading;
  List<WeeklyOffer> get offers => _offers;

  bool _showPublishedOnly = true;
  bool get showPublishedOnly => _showPublishedOnly;

  bool _showClosedOffers = false;
  bool get showClosedOffers => _showClosedOffers;
  bool _disposed = false;

@override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
  /// 🔹 Chargement des offres depuis Firestore
  Future<void> loadOffers({
    bool publishedOnly = true,
    bool includeClosed = false,
  }) async {
    _loading = true;
    _showPublishedOnly = publishedOnly;
    _showClosedOffers = includeClosed;
    safeNotifyListeners();

    final result = await _repository.getAllWeeklyOffers();

    // 🔸 Étape 1 : filtrer selon statut "publié uniquement" ou non
    var filtered = publishedOnly
        ? result.where((o) => o.status == WeeklyOfferStatus.published).toList()
        : result;

    // 🔸 Étape 2 : exclure les offres fermées si on ne souhaite pas les voir
    if (!includeClosed) {
      filtered = filtered
          .where((o) => o.status != WeeklyOfferStatus.closed)
          .toList();
    }

    _offers = filtered;
    _loading = false;
    notifyListeners();
  }

  /// 🔹 Création d'une nouvelle offre
  Future<void> createOffer(WeeklyOffer offer) async {
    final newOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.createWeeklyOffer(newOffer);
    await loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  /// 🔹 Mise à jour
  Future<void> updateOffer(WeeklyOffer offer) async {
    await _repository.updateWeeklyOffer(offer);
    await loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  /// 🔹 Duplication
  Future<void> duplicateOffer(WeeklyOffer source, DateTime start, DateTime end) async {
    await _repository.duplicateWeeklyOffer(
      original: source,
      newStartDate: start,
      newEndDate: end,
    );
    await loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  /// 🔹 Publication
/// 🔹 Publication d'une offre (avec envoi de notification)
Future<void> publishOffer(WeeklyOffer offer) async {
  final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.published);
  await _repository.updateWeeklyOffer(updatedOffer);

  final dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');
  final callable = FirebaseFunctions.instance.httpsCallable('sendWeeklyOfferEmail');

  try {
    // 🔸 Préparation de la liste des légumes (format simple et clair)
    final List<Map<String, dynamic>> vegetableList = offer.vegetables.map((veg) {
      return {
        'name': veg.name,
        'price': veg.price ?? 0,
        'packaging': veg.packaging,
        'standardQuantity': veg.standardQuantity,
      };
    }).toList();

    // 🔸 Appel de la fonction Firebase avec les données complètes
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
  }

  await loadOffers(
    publishedOnly: _showPublishedOnly,
    includeClosed: _showClosedOffers,
  );
}

  /// 🔹 Clôturer / Réouvrir
  Future<void> closeOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.closed);
    await _repository.updateWeeklyOffer(updatedOffer);
    await loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  Future<void> reopenOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.updateWeeklyOffer(updatedOffer);
    await loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  /// 🔹 Basculer le filtre "publiées seulement"
  void toggleFilter() {
    _showPublishedOnly = !_showPublishedOnly;
    loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }

  /// 🔹 Basculer l’affichage des offres fermées
  void toggleShowClosed() {
    _showClosedOffers = !_showClosedOffers;
    loadOffers(
      publishedOnly: _showPublishedOnly,
      includeClosed: _showClosedOffers,
    );
  }
}
