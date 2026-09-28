import '../../domain/entities/ad_entity.dart';

class AdsPaginationModel {
  final int currentPage;
  final List<AdEntity> data;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  AdsPaginationModel({
    required this.currentPage,
    required this.data,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory AdsPaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AdsPaginationModel(
        currentPage: 1,
        data: [],
        from: 0,
        lastPage: 1,
        path: "",
        perPage: 0,
        to: 0,
        total: 0,
      );
    }

    return AdsPaginationModel(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AdEntity.fromJson(e as Map<String, dynamic>?))
          .toList() ??
          [],
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? "",
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
      'from': from,
      'last_page': lastPage,
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}