import 'package:heraj/features/vendor/domain/entities/vendor_type_name_entity.dart';
import 'slider_target_type.dart';

class SliderTargetEntity {
  final SliderTargetType type;
  final int id;
  final Map<String, dynamic> data;

  const SliderTargetEntity({
    required this.type,
    required this.id,
    this.data = const {},
  });

  factory SliderTargetEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SliderTargetEntity(
        type: SliderTargetType.product,
        id: 0,
      );
    }

    final dataRaw = json['data'];
    return SliderTargetEntity(
      type: SliderTargetType.tryParse(json['type']?.toString()) ??
          SliderTargetType.product,
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      data: dataRaw is Map<String, dynamic>
          ? dataRaw
          : (dataRaw is Map
              ? Map<String, dynamic>.from(dataRaw)
              : const <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
        'id': id,
        'data': data,
      };

  String localizedName([String? languageCode]) {
    final name = data['name'];
    if (name is Map) {
      return VendorTypeNameEntity.fromJson(
        Map<String, dynamic>.from(name),
      ).localized(languageCode);
    }
    return name?.toString() ?? '';
  }
}
