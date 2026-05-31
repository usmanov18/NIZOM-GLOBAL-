import 'dart:math';

enum RoundingMode { bankers, ceil, floor }

class DecimalHelper {
  static double round(double value,
      {int precision = 2, RoundingMode mode = RoundingMode.bankers}) {
    double mod = pow(10.0, precision).toDouble();
    switch (mode) {
      case RoundingMode.bankers:
        return ((value * mod).round().toDouble() / mod);
      case RoundingMode.ceil:
        return ((value * mod).ceil().toDouble() / mod);
      case RoundingMode.floor:
        return ((value * mod).floor().toDouble() / mod);
    }
  }

  static String toSAPFormat(double value) =>
      round(value, mode: RoundingMode.bankers).toStringAsFixed(2);
  static String toOneCFormat(double value) =>
      round(value, mode: RoundingMode.floor).toStringAsFixed(2);
}
