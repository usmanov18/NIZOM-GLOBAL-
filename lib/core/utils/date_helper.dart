import 'package:intl/intl.dart';

class DateHelper {
  static String toOneCFormat(DateTime date) {
    // 2026 OData Standard: YYYY-MM-DDTHH:mm:ss
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  }
}
