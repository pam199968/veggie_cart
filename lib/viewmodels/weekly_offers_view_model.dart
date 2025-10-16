import 'package:flutter/material.dart';
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

  Future<void> loadOffers({bool publishedOnly = true}) async {
    _loading = true;
    _showPublishedOnly = publishedOnly;
    notifyListeners();

    final result = await _repository.getAllWeeklyOffers();
    _offers = publishedOnly
        ? result.where((o) => o.isPublished).toList()
        : result;
    _loading = false;
    notifyListeners();
  }

  Future<void> createOffer(WeeklyOffer offer) async {
    await _repository.createWeeklyOffer(offer);
    await loadOffers(publishedOnly: _showPublishedOnly);
  }

  Future<void> updateOffer(WeeklyOffer offer) async {
    await _repository.updateWeeklyOffer(offer);
    await loadOffers(publishedOnly: _showPublishedOnly);
  }

  Future<void> deleteOffer(String id) async {
    await _repository.deleteWeeklyOffer(id);
    await loadOffers(publishedOnly: _showPublishedOnly);
  }

  Future<void> duplicateOffer(WeeklyOffer source, DateTime start, DateTime end) async {
    await _repository.duplicateWeeklyOffer(original: source, newStartDate: start, newEndDate: end);
    await loadOffers(publishedOnly: _showPublishedOnly);
  }

  Future<void> publishOffer(WeeklyOffer offer) async {
    await _repository.updateWeeklyOffer(offer.copyWith(isPublished: true));

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendWeeklyOfferEmail',
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'offer': {
          'title': offer.title,
          'description': offer.description,
          'startDate': offer.startDate.toIso8601String(),
          'endDate': offer.endDate.toIso8601String(),
        }
      });
      print('Emails envoyés : ${result.data}');
    } catch (e) {
      print('Erreur envoi email : $e');
    }

    await loadOffers(publishedOnly: _showPublishedOnly);
  }


  void toggleFilter() {
    _showPublishedOnly = !_showPublishedOnly;
    loadOffers(publishedOnly: _showPublishedOnly);
  }
}
