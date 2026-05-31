class MappingHelper {
  static double readDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String readString(dynamic value, {String defaultValue = ''}) {
    return value?.toString() ?? defaultValue;
  }
}
