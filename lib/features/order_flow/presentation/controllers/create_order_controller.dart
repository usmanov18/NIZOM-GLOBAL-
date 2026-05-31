import 'package:flutter/foundation.dart';

/// Create order ekranidagi savat va hisob-kitob state'i.
/// Hozircha UI bilan mos ravishda mutable list beradi, keyingi bosqichda Cubit/Blocga ko‘chirish oson bo‘ladi.
class CreateOrderController extends ChangeNotifier {
  final List<CreateOrderCartItem> _items = [];

  List<CreateOrderCartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get lineCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  CreateOrderCartItem? findItem(String productId) {
    final matches = _items.where((item) => item.productId == productId);
    return matches.isEmpty ? null : matches.first;
  }

  void addItem({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
    Map<String, dynamic> pricingSnapshot = const {},
  }) {
    final existing = findItem(productId);
    if (existing != null) {
      existing.quantity += quantity;
      existing.price = price;
      existing.pricingSnapshot = pricingSnapshot;
    } else {
      _items.add(CreateOrderCartItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity,
        pricingSnapshot: pricingSnapshot,
      ));
    }
    notifyListeners();
  }

  void incrementItem({
    required String productId,
    required double price,
    required Map<String, dynamic> pricingSnapshot,
  }) {
    final item = findItem(productId);
    if (item == null) return;
    item.quantity++;
    item.price = price;
    item.pricingSnapshot = pricingSnapshot;
    notifyListeners();
  }

  void decrementItem({
    required String productId,
    double? price,
    Map<String, dynamic>? pricingSnapshot,
  }) {
    final item = findItem(productId);
    if (item == null) return;
    if (item.quantity > 1) {
      item.quantity--;
      if (price != null) item.price = price;
      if (pricingSnapshot != null) item.pricingSnapshot = pricingSnapshot;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void replaceItems(List<CreateOrderCartItem> items) {
    _items
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void notifyCartChanged() => notifyListeners();
}

class CreateOrderCartItem {
  final String productId;
  final String productName;
  double price;
  int quantity;
  Map<String, dynamic> pricingSnapshot;

  CreateOrderCartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.pricingSnapshot = const {},
  });

  double get lineTotal => price * quantity;
}
