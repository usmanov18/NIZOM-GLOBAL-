class OrderSyncPayloadIssue {
  final String path;
  final String message;
  final bool blocking;

  const OrderSyncPayloadIssue({
    required this.path,
    required this.message,
    this.blocking = true,
  });
}

class OrderSyncPayloadValidationResult {
  final List<OrderSyncPayloadIssue> issues;

  const OrderSyncPayloadValidationResult(this.issues);

  bool get isValid => issues.where((e) => e.blocking).isEmpty;
  List<String> get blockingMessages => issues
      .where((e) => e.blocking)
      .map((e) => '${e.path}: ${e.message}')
      .toList();
  List<String> get warnings => issues
      .where((e) => !e.blocking)
      .map((e) => '${e.path}: ${e.message}')
      .toList();
}

class OrderSyncPayloadValidator {
  const OrderSyncPayloadValidator._();

  static OrderSyncPayloadValidationResult generic(
      Map<String, dynamic> payload) {
    final issues = <OrderSyncPayloadIssue>[];
    _required(payload, 'orderId', issues);
    _required(payload, 'orderNumber', issues);
    _required(payload, 'customerCode', issues);
    _required(payload, 'warehouseId', issues);
    _required(payload, 'items', issues);

    final items = payload['items'];
    if (items is! List || items.isEmpty) {
      issues.add(
          const OrderSyncPayloadIssue(path: 'items', message: 'Itemlar bo‘sh'));
    } else {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map) {
          issues.add(OrderSyncPayloadIssue(
              path: 'items[$i]', message: 'Item format noto‘g‘ri'));
          continue;
        }
        _required(item, 'productCode', issues, pathPrefix: 'items[$i]');
        _positive(item, 'quantity', issues, pathPrefix: 'items[$i]');
        _nonNegative(item, 'unitPrice', issues, pathPrefix: 'items[$i]');
        if (item['pricing'] == null) {
          issues.add(OrderSyncPayloadIssue(
              path: 'items[$i].pricing',
              message: 'Pricing snapshot yo‘q',
              blocking: false));
        }
      }
    }

    if (payload['territory'] == null) {
      issues.add(const OrderSyncPayloadIssue(
          path: 'territory',
          message: 'Territory snapshot yo‘q',
          blocking: false));
    }

    return OrderSyncPayloadValidationResult(issues);
  }

  static OrderSyncPayloadValidationResult oneC(Map<String, dynamic> payload) {
    final issues = <OrderSyncPayloadIssue>[];
    _required(payload, 'Date', issues);
    _required(payload, 'Number', issues);
    _required(payload, 'Customer', issues);
    _required(payload, 'Warehouse', issues);
    _required(payload, 'Items', issues);
    _required(payload, 'DocumentAmount', issues);

    final items = payload['Items'];
    if (items is! List || items.isEmpty) {
      issues.add(const OrderSyncPayloadIssue(
          path: 'Items', message: '1C itemlar bo‘sh'));
    } else {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map) continue;
        _required(item, 'Product', issues, pathPrefix: 'Items[$i]');
        _positive(item, 'Quantity', issues, pathPrefix: 'Items[$i]');
        _nonNegative(item, 'UnitPrice', issues, pathPrefix: 'Items[$i]');
      }
    }
    return OrderSyncPayloadValidationResult(issues);
  }

  static OrderSyncPayloadValidationResult sap(Map<String, dynamic> payload) {
    final issues = <OrderSyncPayloadIssue>[];
    _required(payload, 'OrderType', issues);
    _required(payload, 'SalesOrganization', issues);
    _required(payload, 'DistributionChannel', issues);
    _required(payload, 'SoldToParty', issues);
    _required(payload, 'PurchaseOrderNumber', issues);
    _required(payload, 'to_Item', issues);

    final items = payload['to_Item'];
    if (items is! List || items.isEmpty) {
      issues.add(const OrderSyncPayloadIssue(
          path: 'to_Item', message: 'SAP itemlar bo‘sh'));
    } else {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map) continue;
        _required(item, 'Material', issues, pathPrefix: 'to_Item[$i]');
        _required(item, 'Plant', issues, pathPrefix: 'to_Item[$i]');
        _positive(item, 'RequestedQuantity', issues, pathPrefix: 'to_Item[$i]');
      }
    }
    return OrderSyncPayloadValidationResult(issues);
  }

  static void _required(
      Map data, String key, List<OrderSyncPayloadIssue> issues,
      {String pathPrefix = ''}) {
    final value = data[key];
    if (value == null || (value is String && value.trim().isEmpty)) {
      issues.add(OrderSyncPayloadIssue(
          path: pathPrefix.isEmpty ? key : '$pathPrefix.$key',
          message: 'Majburiy maydon yo‘q'));
    }
  }

  static void _positive(
      Map data, String key, List<OrderSyncPayloadIssue> issues,
      {String pathPrefix = ''}) {
    final value = data[key];
    final numValue =
        value is num ? value : num.tryParse(value?.toString() ?? '');
    if (numValue == null || numValue <= 0) {
      issues.add(OrderSyncPayloadIssue(
          path: pathPrefix.isEmpty ? key : '$pathPrefix.$key',
          message: '0 dan katta bo‘lishi kerak'));
    }
  }

  static void _nonNegative(
      Map data, String key, List<OrderSyncPayloadIssue> issues,
      {String pathPrefix = ''}) {
    final value = data[key];
    final numValue =
        value is num ? value : num.tryParse(value?.toString() ?? '');
    if (numValue == null || numValue < 0) {
      issues.add(OrderSyncPayloadIssue(
          path: pathPrefix.isEmpty ? key : '$pathPrefix.$key',
          message: 'manfiy bo‘lmasligi kerak'));
    }
  }
}

extension OrderSyncPayloadValidationSummary
    on OrderSyncPayloadValidationResult {
  String summary() {
    final errors = issues.where((e) => e.blocking).length;
    final warnings = issues.where((e) => !e.blocking).length;
    if (errors == 0 && warnings == 0) return 'OK';
    return '$errors error, $warnings warning';
  }
}
