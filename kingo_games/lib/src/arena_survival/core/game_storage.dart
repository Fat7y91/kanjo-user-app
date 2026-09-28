import '../models/save_data.dart';

abstract class ArenaGameStorage {
  Future<ArenaSaveData> load();

  Future<void> save(ArenaSaveData data);
}

class MemoryArenaGameStorage implements ArenaGameStorage {
  ArenaSaveData _data = const ArenaSaveData();

  @override
  Future<ArenaSaveData> load() async => _data;

  @override
  Future<void> save(ArenaSaveData data) async {
    _data = data;
  }
}

/// String-backed storage so the host app can persist with GetStorage / prefs.
class CallbackArenaGameStorage implements ArenaGameStorage {
  CallbackArenaGameStorage({
    required this.readJson,
    required this.writeJson,
  });

  final Map<String, dynamic>? Function() readJson;
  final Future<void> Function(Map<String, dynamic> json) writeJson;

  @override
  Future<ArenaSaveData> load() async {
    final json = readJson();
    if (json == null || json.isEmpty) return const ArenaSaveData();
    return ArenaSaveData.fromJson(json);
  }

  @override
  Future<void> save(ArenaSaveData data) {
    return writeJson(data.toJson());
  }
}
