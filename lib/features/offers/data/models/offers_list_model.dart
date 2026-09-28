import 'package:heraj/features/location/domain/entities/location_context_entity.dart';

import 'offer_model.dart';

class OffersListModel {
  const OffersListModel({
    required this.data,
    this.locationContext,
  });

  final List<OfferModel> data;
  final LocationContextEntity? locationContext;

  factory OffersListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final items = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <OfferModel>[];

    final contextRaw = json['location_context'];
    return OffersListModel(
      data: items,
      locationContext: contextRaw is Map
          ? LocationContextEntity.fromJson(
              Map<String, dynamic>.from(contextRaw),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'location_context': locationContext?.toJson(),
      };
}
