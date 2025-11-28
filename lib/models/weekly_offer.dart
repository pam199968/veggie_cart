// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'vegetable_model.dart';

/// Enum représentant les états d'une offre hebdomadaire
enum WeeklyOfferStatus {
  draft,     // Brouillon
  published, // Publiée
  closed,    // Fermée
}

extension WeeklyOfferStatusExtension on WeeklyOfferStatus {
  String get label {
    switch (this) {
      case WeeklyOfferStatus.draft:
        return 'Brouillon';
      case WeeklyOfferStatus.published:
        return 'Publiée';
      case WeeklyOfferStatus.closed:
        return 'Fermée';
    }
  }

  static WeeklyOfferStatus fromString(String value) {
    switch (value) {
      case 'published':
        return WeeklyOfferStatus.published;
      case 'closed':
        return WeeklyOfferStatus.closed;
      case 'draft':
      default:
        return WeeklyOfferStatus.draft;
    }
  }
}

class WeeklyOffer {
  final String? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final WeeklyOfferStatus status;
  final List<VegetableModel> vegetables;

  WeeklyOffer({
    this.id, // Firestore générera l’ID si null
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.vegetables,
  });

  /// Conversion Firestore → Objet
  factory WeeklyOffer.fromMap(Map<String, dynamic> map, String documentId) {
    return WeeklyOffer(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: WeeklyOfferStatusExtension.fromString(map['status'] ?? 'draft'),
      vegetables: (map['vegetables'] as List<dynamic>? ?? [])
          .map((v) => VegetableModel.fromMap(Map<String, dynamic>.from(v), v['id'] ?? ''))
          .toList(),
    );
  }

  /// Conversion Objet → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name, // 'draft', 'published', 'closed'
      'vegetables': vegetables.map((v) => v.toMap()..['id'] = v.id).toList(),
    };
  }

  /// Facilite la duplication / modification partielle
  WeeklyOffer copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    WeeklyOfferStatus? status,
    List<VegetableModel>? vegetables,
  }) {
    return WeeklyOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      vegetables: vegetables ?? this.vegetables,
    );
  }

  /// Utilitaire pratique pour savoir si l’offre est publiée
  bool get isPublished => status == WeeklyOfferStatus.published;
}
