import 'dart:async';

// ============================================================
// CURRENCY SERVICE - Multi-valyuta tizimi
// ============================================================

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  // Kurslar
  final Map<String, double> _exchangeRates = {
    'UZS': 1.0,
    'USD': 12650.0,
    'EUR': 13800.0,
    'RUB': 140.0,
    'KZT': 28.0,
  };

  // Default valyuta
  String _defaultCurrency = 'UZS';

  // ============ ASOSIY ============

  String get defaultCurrency => _defaultCurrency;

  void setDefaultCurrency(String currency) {
    _defaultCurrency = currency;
  }

  List<String> get supportedCurrencies => _exchangeRates.keys.toList();

  // ============ KURS ============

  double getRate(String from, String to) {
    final fromRate = _exchangeRates[from] ?? 1.0;
    final toRate = _exchangeRates[to] ?? 1.0;
    return toRate / fromRate;
  }

  Future<void> updateRates() async {
    // Offline fallback kurslari. Real API ulanganda shu map server javobi bilan yangilanadi.
    _exchangeRates.updateAll((currency, rate) => rate);
  }

  // ============ KONVERTATSIYA ============

  double convert(double amount, String from, String to) {
    final rate = getRate(from, to);
    return amount * rate;
  }

  String format(double amount, String currency) {
    switch (currency) {
      case 'UZS':
        return '${_formatNumber(amount)} so\'m';
      case 'USD':
        return '\$${_formatNumber(amount)}';
      case 'EUR':
        return '€${_formatNumber(amount)}';
      case 'RUB':
        return '${_formatNumber(amount)} ₽';
      default:
        return '${_formatNumber(amount)} $currency';
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
