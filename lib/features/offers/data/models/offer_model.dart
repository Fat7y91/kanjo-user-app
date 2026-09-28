import 'package:heraj/features/products/domain/entities/localized_name_entity.dart';

import '../../domain/entities/offer_rules_entity.dart';
import '../../domain/entities/offer_target_type.dart';

class OfferModel {
  const OfferModel({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.rules,
    required this.targetType,
    this.targets = const [],
    this.imageUrl,
  });

  final int id;
  final String type;
  final LocalizedNameEntity name;
  final LocalizedNameEntity description;
  final OfferRulesEntity rules;
  final OfferTargetType? targetType;
  final List<int> targets;
  final String? imageUrl;

  int? get firstTargetId {
    for (final id in targets) {
      if (id > 0) return id;
    }
    return null;
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      name: _localized(json['name']),
      description: _localized(json['description']),
      rules: OfferRulesEntity.fromJson(
        json['rules'] is Map
            ? Map<String, dynamic>.from(json['rules'] as Map)
            : null,
      ),
      targetType: OfferTargetType.tryParse(json['target_type']?.toString()),
      targets: _intList(json['targets']),
      imageUrl: _nullableString(json['image_url'] ?? json['image']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name.toJson(),
        'description': description.toJson(),
        'rules': rules.toJson(),
        'target_type': targetType?.toJson(),
        'targets': targets,
        'image_url': imageUrl,
      };
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

LocalizedNameEntity _localized(dynamic value) {
  if (value is Map) {
    return LocalizedNameEntity.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String && value.trim().isNotEmpty) {
    return LocalizedNameEntity(ar: value, en: value);
  }
  // API may send `description: []` when empty.
  return const LocalizedNameEntity(ar: '', en: '');
}

List<int> _intList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) {
        if (e is int) return e;
        if (e is num) return e.toInt();
        return int.tryParse(e?.toString() ?? '') ?? 0;
      })
      .where((id) => id > 0)
      .toList();
}
