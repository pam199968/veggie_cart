import '../models/weekly_offer.dart';
import '../services/weekly_offers_service.dart';

class WeeklyOffersRepository {
  final WeeklyOffersService _weeklyOffersService;

  /// Constructeur injectable (mockable pour les tests)
  WeeklyOffersRepository({WeeklyOffersService? weeklyOffersService})
      : _weeklyOffersService = weeklyOffersService ?? WeeklyOffersService();

  /// 🔹 CREATE
  Future<String> createWeeklyOffer(WeeklyOffer offer) async {
    return await _weeklyOffersService.addWeeklyOffer(offer);
  }

  /// 🔹 READ
  Future<WeeklyOffer?> getWeeklyOfferById(String id) async {
    return await _weeklyOffersService.getWeeklyOffer(id);
  }

  Future<List<WeeklyOffer>> getAllWeeklyOffers() async {
    return await _weeklyOffersService.getAllWeeklyOffers();
  }

  /// 🔹 UPDATE
  Future<void> updateWeeklyOffer(WeeklyOffer offer) async {
    await _weeklyOffersService.updateWeeklyOffer(offer);
  }

  /// 🔹 DELETE
  Future<void> deleteWeeklyOffer(String id) async {
    await _weeklyOffersService.deleteWeeklyOffer(id);
  }

  /// 🔹 STREAM
  Stream<List<WeeklyOffer>> watchAllWeeklyOffers() {
    return _weeklyOffersService.streamWeeklyOffers();
  }

  // ----------------------------------------------------------------
  // 🧠 MÉTHODE MÉTIER : Duplication d’une offre
  // ----------------------------------------------------------------
  Future<WeeklyOffer?> duplicateWeeklyOffer({
    required WeeklyOffer original,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    final duplicated = original.copyWith(
      id: null, // pour forcer Firestore à générer un nouvel ID
      title: '${original.title} (copie)',
      startDate: newStartDate,
      endDate: newEndDate,
      status: WeeklyOfferStatus.draft,
    );

    final newId = await _weeklyOffersService.addWeeklyOffer(duplicated);
    return duplicated.copyWith(id: newId);
  }
}
