import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================
// PERFORMANCE OPTIMIZATION SERVICE
// ============================================================

class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance =
      PerformanceOptimizationService._();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._();

  // ============ IMAGE OPTIMIZATION ============

  /// Rasm optimizatsiya sozlamalari
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 80;
  static const int thumbnailSize = 200;

  // ============ CACHE MANAGEMENT ============

  /// Cache sozlamalari
  static const int maxCacheSize = 500 * 1024 * 1024; // 500 MB
  static const Duration cacheExpiration = Duration(days: 7);
  static const int maxCacheEntries = 1000;

  // ============ PAGINATION ============

  /// Pagination sozlamalari
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============ NETWORK OPTIMIZATION ============

  /// Tarmoq sozlamalari
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ============ BATTERY OPTIMIZATION ============

  /// Batareya optimizatsiya
  static const Duration gpsIntervalNormal = Duration(seconds: 30);
  static const Duration gpsIntervalBatterySaver = Duration(seconds: 60);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);

  // ============ MEMORY MANAGEMENT ============

  /// Xotira boshqaruvi
  static const int maxImageCacheSize = 100 * 1024 * 1024; // 100 MB
  static const int maxListItems = 100;
  static const Duration memoryCheckInterval = Duration(minutes: 5);

  // ============ LAZY LOADING ============

  /// Lazy loading sozlamalari
  static const int lazyLoadThreshold = 500; // pixels from bottom
  static const int prefetchCount = 10;

  // ============ SHIMMER LOADING ============

  /// Shimmer loading sozlamalari
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  // ============ OPTIMIZATION CHECK ============

  /// Samaradorlik tekshirish
  Future<PerformanceReport> checkPerformance() async {
    final issues = <PerformanceIssue>[];

    if (maxCacheSize < 10 * 1024 * 1024) {
      issues.add(const PerformanceIssue(
        category: 'cache',
        description: 'Cache hajmi juda kichik sozlangan',
        severity: 'medium',
        suggestion: 'maxCacheSize qiymatini oshiring',
      ));
    }

    return PerformanceReport(
      issues: issues,
      score: 100 - (issues.length * 10),
      checkedAt: DateTime.now(),
    );
  }
}

// ============ MODELS ============

class PerformanceIssue {
  final String category;
  final String description;
  final String severity; // low, medium, high
  final String? suggestion;

  const PerformanceIssue({
    required this.category,
    required this.description,
    required this.severity,
    this.suggestion,
  });
}

class PerformanceReport {
  final List<PerformanceIssue> issues;
  final double score;
  final DateTime checkedAt;

  const PerformanceReport({
    required this.issues,
    required this.score,
    required this.checkedAt,
  });

  bool get isGood => score >= 80;
  bool get isFair => score >= 60;
  bool get isPoor => score < 60;
}
