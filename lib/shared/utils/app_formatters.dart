class AppFormatters {
  AppFormatters._();

  static String money(num amount, {String suffix = 'so\'m'}) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return suffix.isEmpty ? formatted : '$formatted $suffix';
  }

  static String compactMoney(num amount) {
    if (amount.abs() >= 1000000000)
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    if (amount.abs() >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount.abs() >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  static String date(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  static String dateTime(DateTime date) {
    return "${AppFormatters.date(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  static String relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }
}
