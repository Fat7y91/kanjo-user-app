import 'package:intl/intl.dart';

import '../core/service/local_data_manager.dart';

abstract class FormatDate {
  static String call(dynamic value, {bool addJm = false}) {
    const pattern = "d MMM yyy";
    var function = DateFormat(pattern, dataManager.getLanguage?.locale.languageCode??"en");
    if (addJm) {
      function = function.add_jm();
    }
    late String result;
    if (value is DateTime) {
      result = function.format(value);
    } else if (value is String) {
      final parsed = tryParse(value);
      result = parsed == null ? value : function.format(parsed);
    } else if (value == null) {
      result = '';
    } else {
      result = value.toString();
    }
    return Bidi.enforceLtrInText(result);
  }

  static DateTime? tryParse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    const patterns = [
      'd-M-yyyy',
      'dd-MM-yyyy',
      'd/M/yyyy',
      'dd/MM/yyyy',
      'yyyy-M-d',
      'yyyy-MM-dd',
    ];
    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(trimmed);
      } catch (_) {}
    }
    return null;
  }
}
