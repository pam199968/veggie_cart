import 'package:cloud_firestore/cloud_firestore.dart';
import 'vegetable_model.dart';

class WeeklyOffer {
  final String? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublished;
  final List<VegetableModel> vegetables;

  WeeklyOffer({
    this.id, // Firestore générera l’ID si null
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isPublished,
    required this.vegetables,
  });

  /// Conversion Map → Objet
  factory WeeklyOffer.fromMap(Map<String, dynamic> map, String documentId) {
    return WeeklyOffer(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isPublished: map['isPublished'] ?? false,
      vegetables: (map['vegetables'] as List<dynamic>? ?? [])
          .map((v) => VegetableModel.fromMap(Map<String, dynamic>.from(v), v['id'] ?? ''))
          .toList(),
    );
  }

  /// Conversion Objet → Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isPublished': isPublished,
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
    bool? isPublished,
    List<VegetableModel>? vegetables,
  }) {
    return WeeklyOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isPublished: isPublished ?? this.isPublished,
      vegetables: vegetables ?? this.vegetables,
    );
  }
}
