import 'package:intl/intl.dart';

abstract class FormatNumber {
  static String formatNumber(dynamic value) {
    final formatedData = NumberFormat.simpleCurrency(name: '')
        .format(num.tryParse(value?.toString() ?? '0'))
        .replaceAll('.00', '');
    const bool hideBalance = false;
    // ignore: dead_code
    if (hideBalance) {
      return "*" * formatedData.length;
    } else {
      return formatedData;
    }
  }
}
