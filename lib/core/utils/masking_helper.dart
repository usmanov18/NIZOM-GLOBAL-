class MaskingHelper {
  static String maskPhone(String phone) {
    if (phone.length < 7) return '***';
    return phone.replaceRange(phone.length - 7, phone.length - 2, '*******');
  }

  static String maskINN(String inn) {
    if (inn.length < 5) return '***';
    return inn.replaceRange(2, inn.length - 2, '*****');
  }
}
