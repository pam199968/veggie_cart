import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/weekly_offer.dart';
import '../repositories/weekly_offers_repository.dart';

enum OfferFilter { all, draft, published, closed }

class WeeklyOffersViewModel extends ChangeNotifier {
  final WeeklyOffersRepository _repository;

  WeeklyOffersViewModel({required WeeklyOffersRepository repository})
    : _repository = repository {
    loadOffers();
  }

  List<WeeklyOffer> _offers = [];
  bool _loading = false;
  bool get loading => _loading;
  List<WeeklyOffer> get offers => _offers;

  OfferFilter _offerFilter = OfferFilter.draft;
  OfferFilter get offerFilter => _offerFilter;
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

  void setOfferFilter(OfferFilter filter) {
    _offerFilter = filter;
    loadOffers(); // recharge directement depuis le repository avec filtre
  }

  //// 🔹 Chargement des offres depuis Firestore
  Future<void> loadOffers() async {
    _loading = true;
    safeNotifyListeners();

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

    _offers = await _repository.getAllWeeklyOffers(status: status);
    _loading = false;
    safeNotifyListeners();
  }

  /// 🔹 Création d'une nouvelle offre
  Future<void> createOffer(WeeklyOffer offer) async {
    final newOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.createWeeklyOffer(newOffer);
    await loadOffers();
  }

  /// 🔹 Mise à jour
  Future<void> updateOffer(WeeklyOffer offer) async {
    await _repository.updateWeeklyOffer(offer);
    await loadOffers();
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
    await loadOffers();
  }

  /// 🔹 Publication
  /// 🔹 Publication d'une offre (avec envoi de notification)
  Future<void> publishOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.published);
    await _repository.updateWeeklyOffer(updatedOffer);

    final dateFormatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    final callable = FirebaseFunctions.instance.httpsCallable(
      'sendWeeklyOfferEmail',
    );

    try {
      // 🔸 Préparation de la liste des légumes (format simple et clair)
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

    await loadOffers();
  }

  /// 🔹 Clôturer / Réouvrir
  Future<void> closeOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.closed);
    await _repository.updateWeeklyOffer(updatedOffer);
    await loadOffers();
  }

  Future<void> reopenOffer(WeeklyOffer offer) async {
    final updatedOffer = offer.copyWith(status: WeeklyOfferStatus.draft);
    await _repository.updateWeeklyOffer(updatedOffer);
    await loadOffers();
  }
}
