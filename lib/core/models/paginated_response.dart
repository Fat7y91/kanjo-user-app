class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final int? unreadCount;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from = 0,
    this.to = 0,
    this.unreadCount,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginationMeta.singlePage({
    int total = 0,
    int perPage = 20,
    int? unreadCount,
  }) {
    return PaginationMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: perPage,
      total: total,
      from: total == 0 ? 0 : 1,
      to: total,
      unreadCount: unreadCount,
    );
  }

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return PaginationMeta.singlePage();
    }

    final currentPage = _asInt(json['current_page'] ?? json['page'], 1);
    final lastPage = _asInt(
      json['last_page'] ?? json['totalPages'] ?? json['pages'],
      1,
    );
    final perPage = _asInt(json['per_page'] ?? json['limit'], 20);
    final total = _asInt(json['total'], 0);
    final unreadRaw = json['unread_count'];
    final unreadCount = unreadRaw == null
        ? null
        : _asInt(unreadRaw, 0);

    return PaginationMeta(
      currentPage: currentPage,
      lastPage: lastPage < 1 ? 1 : lastPage,
      perPage: perPage,
      total: total,
      from: _asInt(json['from'], total == 0 ? 0 : 1),
      to: _asInt(json['to'], total),
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
      if (unreadCount != null) 'unread_count': unreadCount,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.empty({int perPage = 20}) {
    return PaginatedResponse(
      data: const [],
      meta: PaginationMeta.singlePage(perPage: perPage),
    );
  }

  Map<String, dynamic> toJson(Object Function(T item) itemToJson) {
    return {
      'data': data.map(itemToJson).toList(),
      'meta': meta.toJson(),
    };
  }
}

class PaginationConfig {
  static const int perPage = 20;
  static const int largePerPage = 50;
}

PaginatedResponse<T> parsePaginatedResponse<T>(
  dynamic json,
  T Function(Map<String, dynamic> item) fromItem,
) {
  if (json == null) return PaginatedResponse.empty();

  if (json is List) {
    final items = _mapItems(json, fromItem);
    return PaginatedResponse(
      data: items,
      meta: PaginationMeta.singlePage(total: items.length),
    );
  }

  if (json is! Map) return PaginatedResponse.empty();

  final root = Map<String, dynamic>.from(json);
  var metaJson = _asMap(root['meta']) ?? _asMap(root['pagination']);
  var list = _extractList(root);

  final nested = root['data'];
  if (nested is Map) {
    final nestedMap = Map<String, dynamic>.from(nested);
    metaJson ??= _asMap(nestedMap['meta']) ?? _asMap(nestedMap['pagination']);
    if (list.isEmpty) {
      list = _extractList(nestedMap);
    }
  }

  final items = _mapItems(list, fromItem);
  return PaginatedResponse(
    data: items,
    meta: metaJson != null
        ? PaginationMeta.fromJson(metaJson)
        : PaginationMeta.singlePage(total: items.length),
  );
}

Future<List<T>> fetchAllPaginatedPages<T>({
  required Future<PaginatedResponse<T>> Function(int page) fetchPage,
}) async {
  final first = await fetchPage(1);
  if (!first.meta.hasMore) return List<T>.from(first.data);

  final all = <T>[...first.data];
  for (var page = 2; page <= first.meta.lastPage; page++) {
    all.addAll((await fetchPage(page)).data);
  }
  return all;
}

List _extractList(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is List) return data;
  if (json['items'] is List) return json['items'] as List;
  if (json['notifications'] is List) return json['notifications'] as List;
  return const [];
}

List<T> _mapItems<T>(
  List list,
  T Function(Map<String, dynamic> item) fromItem,
) {
  return list
      .whereType<Map>()
      .map((e) => fromItem(Map<String, dynamic>.from(e)))
      .toList();
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
