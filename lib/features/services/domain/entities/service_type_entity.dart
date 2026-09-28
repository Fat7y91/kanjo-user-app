import 'package:heraj/features/products/domain/entities/localized_name_entity.dart';
import 'services_json.dart';

class ServiceTypeEntity {
  final int id;
  final LocalizedNameEntity name;
  final LocalizedNameEntity description;
  final String? icon;
  final bool isActive;
  final int sortOrder;

  const ServiceTypeEntity({
    required this.id,
    required this.name,
    this.description = const LocalizedNameEntity(ar: '', en: ''),
    this.icon,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ServiceTypeEntity.fromJson(Map<String, dynamic> json) {
    return ServiceTypeEntity(
      id: asInt(json['id']),
      name: localizedNameFrom(json['name']),
      description: localizedNameFrom(json['description']),
      icon: json['icon']?.toString(),
      isActive: json['is_active'] != false,
      sortOrder: asInt(json['sort_order']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'description': description.toJson(),
      'icon': icon,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
