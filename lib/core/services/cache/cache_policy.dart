class CachePolicy {
  static bool isExpired(DateTime cachedAt, {int hours = 1}) {
    final now = DateTime.now();
    return now.difference(cachedAt).inHours >= hours;
  }
}
