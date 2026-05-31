class LogSanitizer {
  static final RegExp _pattern = RegExp(
    r'(Bearer\s+[a-zA-Z0-9\-\._]+)|(password=[^&\s]+)|(Ref_Key=[^&\s]+)',
    caseSensitive: false,
  );

  static String sanitize(String message) {
    // 2026 Optimization: Faqat uzun matnlarni sanitize qilamiz yoki keshlaymiz
    if (message.length < 10) return message;
    return message.replaceAll(_pattern, '[REDACTED]');
  }
}
