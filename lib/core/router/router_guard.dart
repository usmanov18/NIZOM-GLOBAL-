class RouterGuard {
  static bool canAccess(String path, bool isLoggedIn) {
    final publicPaths = ['/login', '/splash', '/onboarding'];
    if (!isLoggedIn && !publicPaths.contains(path)) return false;
    return true;
  }
}
