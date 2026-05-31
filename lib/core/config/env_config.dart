enum AppEnvironment { dev, staging, prod }

enum LogLevel { silent, basic, detailed }

/// Backward-compatible aliases used by older config files.
class Environment {
  static const development = AppEnvironment.dev;
  static const staging = AppEnvironment.staging;
  static const production = AppEnvironment.prod;
}

class EnvConfig {
  static AppEnvironment environment = AppEnvironment.dev;
  static LogLevel remoteLogLevel =
      LogLevel.basic; // Can be updated via Firebase Remote Config

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.prod:
        return 'https://api.nizomglobal.uz/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.nizomglobal.uz/v1';
      case AppEnvironment.dev:
        return 'https://dev-api.nizomglobal.uz/v1';
    }
  }

  static String get oneCUrl => baseUrl;
  static String get sapUrl => baseUrl;
  static String get wsUrl => baseUrl.replaceFirst(RegExp(r'^http'), 'ws');

  static bool get isDemoMode => environment == AppEnvironment.dev;
  static bool get enableLogging => remoteLogLevel != LogLevel.silent;
}
