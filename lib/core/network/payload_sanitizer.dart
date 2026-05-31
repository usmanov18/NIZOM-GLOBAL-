class PayloadSanitizer {
  // Faqat ushbu maydonlar serverga chiqib keta oladi
  static const Set<String> _allowedGlobalFields = {
    'Date',
    'Number',
    'Customer',
    'Agent',
    'Warehouse',
    'Items',
    'DocumentAmount',
    'Currency',
    'PaymentMethod',
    'Comment'
  };

  static Map<String, dynamic> clean(Map<String, dynamic> payload) {
    final Map<String, dynamic> cleanData = {};
    payload.forEach((key, value) {
      if (_allowedGlobalFields.contains(key)) {
        cleanData[key] = value;
      }
    });
    return cleanData;
  }
}
