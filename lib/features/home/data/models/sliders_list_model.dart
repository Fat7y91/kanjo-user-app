import 'package:heraj/features/location/domain/entities/location_context_entity.dart';

import 'slider_model.dart';

class SlidersListModel {
  const SlidersListModel({
    required this.data,
    this.locationContext,
  });

  final List<SliderModel> data;
  final LocationContextEntity? locationContext;

  factory SlidersListModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final items = rawList is List
        ? rawList
            .whereType<Map>()
            .map((e) => SliderModel.fromJson(Map<String, dynamic>.from(e)))
            .where((slider) => slider.imageUrl.isNotEmpty)
            .toList()
        : const <SliderModel>[];

    final contextRaw = json['location_context'];
    return SlidersListModel(
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
