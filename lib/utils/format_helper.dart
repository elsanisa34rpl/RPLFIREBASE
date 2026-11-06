import 'package:intl/intl.dart';

class FormatHelper {
  static String rupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String tanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}