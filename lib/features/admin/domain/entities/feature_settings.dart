import 'package:equatable/equatable.dart';

// ============================================================
// FEATURE SETTINGS - Har bir funksiya uchun admin sozlamalari
// ============================================================

/// Funksiya sozlamalari
class FeatureSettings extends Equatable {
  final String featureId;
  final String featureName;
  final String description;
  final bool isEnabled;
  final List<String> visibleFor; // Kimlar ko'radi
  final List<String> allowedRoles; // Kimlar ishlatadi
  final bool requiresPermission;
  final Map<String, dynamic> settings; // Maxsus sozlamalar
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;

  const FeatureSettings({
    required this.featureId,
    required this.featureName,
    required this.description,
    required this.isEnabled,
    required this.visibleFor,
    required this.allowedRoles,
    required this.requiresPermission,
    required this.settings,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  /// Funksiya yoqilganmi?
  bool get isDisabled => !isEnabled;

  /// Rol uchun ko'rinadimi?
  bool isVisibleFor(String role) => visibleFor.contains(role);

  /// Rol uchun ruxsat bormi?
  bool isAllowedFor(String role) => allowedRoles.contains(role);

  /// Sozlamani olish
  T? getSetting<T>(String key) {
    return settings[key] as T?;
  }

  factory FeatureSettings.fromJson(Map<String, dynamic> json) {
    return FeatureSettings(
      featureId: json['feature_id'] ?? '',
      featureName: json['feature_name'] ?? '',
      description: json['description'] ?? '',
      isEnabled: json['is_enabled'] ?? false,
      visibleFor: List<String>.from(json['visible_for'] ?? []),
      allowedRoles: List<String>.from(json['allowed_roles'] ?? []),
      requiresPermission: json['requires_permission'] ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'feature_id': featureId,
        'feature_name': featureName,
        'description': description,
        'is_enabled': isEnabled,
        'visible_for': visibleFor,
        'allowed_roles': allowedRoles,
        'requires_permission': requiresPermission,
        'settings': settings,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'created_by': createdBy,
      };

  FeatureSettings copyWith({
    bool? isEnabled,
    List<String>? visibleFor,
    List<String>? allowedRoles,
    Map<String, dynamic>? settings,
  }) {
    return FeatureSettings(
      featureId: featureId,
      featureName: featureName,
      description: description,
      isEnabled: isEnabled ?? this.isEnabled,
      visibleFor: visibleFor ?? this.visibleFor,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      requiresPermission: requiresPermission,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdBy: createdBy,
    );
  }

  @override
  List<Object?> get props => [featureId, isEnabled];
}

// ============================================================
// DEFAULT FEATURE SETTINGS - Barcha funksiyalar uchun
// ============================================================

class DefaultFeatureSettings {
  static List<FeatureSettings> get defaults => [
        // Auth
        _createFeature(
          id: 'auth_biometric',
          name: 'Biometrik kirish',
          description: 'Face ID / Barmoq izi bilan kirish',
          visibleFor: ['admin', 'agent', 'delivery'],
          allowedRoles: ['admin', 'agent', 'delivery'],
          settings: {'type': 'fingerprint'},
        ),
        _createFeature(
          id: 'auth_otp',
          name: 'OTP kirish',
          description: 'SMS kod orqali kirish',
          visibleFor: ['admin', 'agent', 'delivery'],
          allowedRoles: ['admin', 'agent', 'delivery'],
          settings: {'otp_length': 6, 'expiry_seconds': 120},
        ),

        // Orders
        _createFeature(
          id: 'order_create',
          name: 'Buyurtma yaratish',
          description: 'Yangi buyurtma yaratish',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {
            'max_items': 50,
            'max_amount': 50000000,
            'require_approval_above': 30000000,
            'allow_outside_hours': false,
          },
        ),
        _createFeature(
          id: 'order_return',
          name: 'Qaytarish',
          description: 'Buyurtmani qaytarish',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {'require_photo': true, 'require_reason': true},
        ),

        // Payments
        _createFeature(
          id: 'payment_cash',
          name: 'Naqd to\'lov',
          description: 'Naqd pul qabul qilish',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {'max_amount': 100000000},
        ),
        _createFeature(
          id: 'payment_card',
          name: 'Karta to\'lov',
          description: 'Plastik karta qabul qilish',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {},
        ),

        // Delivery
        _createFeature(
          id: 'delivery_photo',
          name: 'Yetkazish rasmi',
          description: 'Yetkazish tasdig\'i rasmi',
          visibleFor: ['admin', 'supervisor', 'delivery'],
          allowedRoles: ['admin', 'supervisor', 'delivery'],
          settings: {'min_photos': 3, 'max_photos': 10},
        ),
        _createFeature(
          id: 'delivery_signature',
          name: 'Imzo olish',
          description: 'Qabul qiluvchi imzosi',
          visibleFor: ['admin', 'supervisor', 'delivery'],
          allowedRoles: ['admin', 'supervisor', 'delivery'],
          settings: {},
        ),
        _createFeature(
          id: 'delivery_gps',
          name: 'GPS kuzatish',
          description: 'Haydovchi GPS kuzatish',
          visibleFor: ['admin', 'supervisor'],
          allowedRoles: ['admin', 'supervisor'],
          settings: {'interval_seconds': 30, 'background': true},
        ),

        // Discounts
        _createFeature(
          id: 'discount_manual',
          name: 'Qo\'lda chegirma',
          description: 'Agent qo\'lda chegirma berishi',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {'max_percent': 10, 'require_approval_above': 10},
        ),
        _createFeature(
          id: 'discount_promo',
          name: 'Promo kod',
          description: 'Promo kod orqali chegirma',
          visibleFor: ['admin', 'supervisor', 'agent'],
          allowedRoles: ['admin', 'supervisor', 'agent'],
          settings: {},
        ),

        // Notifications
        _createFeature(
          id: 'notification_push',
          name: 'Push bildirishnomalar',
          description: 'Push bildirishnomalar',
          visibleFor: ['admin', 'supervisor', 'agent', 'delivery'],
          allowedRoles: ['admin', 'supervisor', 'agent', 'delivery'],
          settings: {},
        ),
        _createFeature(
          id: 'notification_sms',
          name: 'SMS bildirishnomalar',
          description: 'SMS orqali bildirishnomalar',
          visibleFor: ['admin'],
          allowedRoles: ['admin'],
          settings: {},
        ),

        // Reports
        _createFeature(
          id: 'report_export',
          name: 'Hisobot eksport',
          description: 'Hisobotni PDF/Excel ga export',
          visibleFor: ['admin', 'supervisor'],
          allowedRoles: ['admin', 'supervisor'],
          settings: {
            'formats': ['pdf', 'excel', 'csv']
          },
        ),

        // Sync
        _createFeature(
          id: 'sync_auto',
          name: 'Avtomatik sinxronlash',
          description: 'Avtomatik 1C/SAP sinxronlash',
          visibleFor: ['admin'],
          allowedRoles: ['admin'],
          settings: {'interval_minutes': 30},
        ),

        // Printer
        _createFeature(
          id: 'printer_bluetooth',
          name: 'Bluetooth printer',
          description: 'Bluetooth printer bilan ulanish',
          visibleFor: ['admin', 'agent', 'delivery'],
          allowedRoles: ['admin', 'agent', 'delivery'],
          settings: {},
        ),

        // Chat
        _createFeature(
          id: 'chat_enabled',
          name: 'Ichki chat',
          description: 'Ichki chat tizimi',
          visibleFor: ['admin', 'supervisor', 'agent', 'delivery'],
          allowedRoles: ['admin', 'supervisor', 'agent', 'delivery'],
          settings: {},
        ),

        // Barcode
        _createFeature(
          id: 'barcode_scan',
          name: 'Barcode skanerlash',
          description: 'Barcode/QR kod skanerlash',
          visibleFor: ['admin', 'agent', 'delivery'],
          allowedRoles: ['admin', 'agent', 'delivery'],
          settings: {},
        ),

        // Maps
        _createFeature(
          id: 'maps_enabled',
          name: 'Xarita',
          description: 'Google Maps integratsiya',
          visibleFor: ['admin', 'supervisor', 'agent', 'delivery'],
          allowedRoles: ['admin', 'supervisor', 'agent', 'delivery'],
          settings: {},
        ),

        // AI
        _createFeature(
          id: 'ai_recommendations',
          name: 'AI tavsiyalar',
          description: 'AI asosida tavsiyalar',
          visibleFor: ['admin', 'agent'],
          allowedRoles: ['admin', 'agent'],
          settings: {},
        ),

        // Voice
        _createFeature(
          id: 'voice_commands',
          name: 'Ovozli buyruqlar',
          description: 'Ovozli buyruqlar',
          visibleFor: ['admin', 'agent', 'delivery'],
          allowedRoles: ['admin', 'agent', 'delivery'],
          settings: {},
        ),
      ];

  static FeatureSettings _createFeature({
    required String id,
    required String name,
    required String description,
    required List<String> visibleFor,
    required List<String> allowedRoles,
    Map<String, dynamic> settings = const {},
  }) {
    return FeatureSettings(
      featureId: id,
      featureName: name,
      description: description,
      isEnabled: true,
      visibleFor: visibleFor,
      allowedRoles: allowedRoles,
      requiresPermission: false,
      settings: settings,
      createdAt: DateTime.now(),
      createdBy: 'system',
    );
  }
}
