import 'package:flutter/material.dart';

// ============================================================
// APP LOCALIZATIONS - Multi-til tizimi
// ============================================================

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('uz', 'UZ'), // O'zbek
    Locale('ru', 'RU'), // Rus
    Locale('en', 'US'), // Ingliz
  ];

  // Get translations
  late final Map<String, String> _localizedStrings = _getLocalizedStrings();

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Short alias
  String t(String key) => translate(key);

  Map<String, String> _getLocalizedStrings() {
    switch (locale.languageCode) {
      case 'uz':
        return _uzbekStrings;
      case 'ru':
        return _russianStrings;
      case 'en':
      default:
        return _englishStrings;
    }
  }
}

// ============ DELEGATE ============

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

// ============ O'ZBEK TILI ============

const Map<String, String> _uzbekStrings = {
  // General
  'app_name': 'NIZOM GLOBAL',
  'ok': 'OK',
  'cancel': 'Bekor qilish',
  'save': 'Saqlash',
  'delete': 'O\'chirish',
  'edit': 'Tahrirlash',
  'add': 'Qo\'shish',
  'search': 'Qidirish',
  'filter': 'Filtrlash',
  'refresh': 'Yangilash',
  'loading': 'Yuklanmoqda...',
  'error': 'Xatolik',
  'success': 'Muvaffaqiyatli',
  'no_data': 'Ma\'lumot topilmadi',
  'retry': 'Qayta urinish',
  'yes': 'Ha',
  'no': 'Yo\'q',

  // Auth
  'login': 'Kirish',
  'logout': 'Chiqish',
  'username': 'Login',
  'password': 'Parol',
  'forgot_password': 'Parolni unutdingizmi?',
  'reset_password': 'Parolni tiklash',
  'phone': 'Telefon',
  'otp_code': 'SMS kod',
  'verify': 'Tasdiqlash',
  'biometric': 'Barmoq izi',
  'sso_login': 'SSO orqali kirish',

  // Navigation
  'home': 'Bosh sahifa',
  'orders': 'Buyurtmalar',
  'customers': 'Mijozlar',
  'products': 'Mahsulotlar',
  'visits': 'Tashriflar',
  'map': 'Xarita',
  'profile': 'Profil',
  'settings': 'Sozlamalar',
  'more': 'Ko\'proq',

  // Orders
  'new_order': 'Yangi buyurtma',
  'order_number': 'Buyurtma raqami',
  'order_status': 'Holat',
  'order_total': 'Jami',
  'order_items': 'Mahsulotlar',
  'create_order': 'Buyurtma yaratish',
  'order_created': 'Buyurtma yaratildi',
  'order_confirmed': 'Tasdiqlangan',
  'order_delivered': 'Yetkazilgan',
  'order_cancelled': 'Bekor qilingan',

  // Cart
  'cart': 'Savat',
  'add_to_cart': 'Savatga qo\'shish',
  'cart_empty': 'Savat bo\'sh',
  'total': 'Jami',
  'subtotal': 'Ortiqcha',
  'discount': 'Chegirma',

  // Delivery
  'delivery': 'Yetkazib berish',
  'delivery_address': 'Manzil',
  'delivery_date': 'Sana',
  'delivery_time': 'Vaqt',
  'delivered': 'Yetkazildi',
  'failed': 'Muvaffaqiyatsiz',
  'returned': 'Qaytarildi',

  // Customers
  'customer_name': 'Mijoz nomi',
  'customer_code': 'Mijoz kodi',
  'customer_address': 'Manzil',
  'customer_phone': 'Telefon',
  'customer_debt': 'Qarzdorlik',

  // Products
  'product_name': 'Mahsulot nomi',
  'product_code': 'Mahsulot kodi',
  'product_price': 'Narxi',
  'product_stock': 'Omborda',
  'product_category': 'Kategoriya',

  // Payments
  'payment': 'To\'lov',
  'payment_method': 'To\'lov usuli',
  'cash': 'Naqd pul',
  'card': 'Plastik karta',
  'transfer': 'Bank o\'tkazmasi',
  'credit': 'Kredit',
  'amount': 'Summa',

  // Reports
  'report': 'Hisobot',
  'daily_report': 'Kunlik hisobot',
  'sales': 'Sotuv',
  'visits_count': 'Tashriflar',
  'collections': 'Yig\'imlar',

  // Settings
  'language': 'Til',
  'theme': 'Mavzu',
  'notifications': 'Bildirishnomalar',
  'biometric_auth': 'Biometrik autentifikatsiya',
  'about': 'Ilova haqida',
  'version': 'Versiya',
  'sync': 'Sinxronlash',

  // Errors
  'network_error': 'Internetga ulanmagan',
  'server_error': 'Server xatosi',
  'auth_error': 'Autentifikatsiya xatosi',
  'timeout_error': 'Vaqt tugadi',
  'unknown_error': 'Noma\'lum xatolik',
};

// ============ RUS TILI ============

const Map<String, String> _russianStrings = {
  'app_name': 'НИЗОМ ГЛОБАЛ',
  'ok': 'OK',
  'cancel': 'Отмена',
  'save': 'Сохранить',
  'delete': 'Удалить',
  'edit': 'Редактировать',
  'add': 'Добавить',
  'search': 'Поиск',
  'filter': 'Фильтр',
  'refresh': 'Обновить',
  'loading': 'Загрузка...',
  'error': 'Ошибка',
  'success': 'Успешно',
  'no_data': 'Данные не найдены',
  'retry': 'Повторить',
  'yes': 'Да',
  'no': 'Нет',
  'login': 'Войти',
  'logout': 'Выход',
  'username': 'Логин',
  'password': 'Пароль',
  'forgot_password': 'Забыли пароль?',
  'reset_password': 'Сбросить пароль',
  'phone': 'Телефон',
  'otp_code': 'SMS код',
  'verify': 'Подтвердить',
  'biometric': 'Биометрия',
  'sso_login': 'Вход через SSO',
  'home': 'Главная',
  'orders': 'Заказы',
  'customers': 'Клиенты',
  'products': 'Товары',
  'visits': 'Визиты',
  'map': 'Карта',
  'profile': 'Профиль',
  'settings': 'Настройки',
  'more': 'Ещё',
  'new_order': 'Новый заказ',
  'order_number': 'Номер заказа',
  'order_status': 'Статус',
  'order_total': 'Итого',
  'order_items': 'Товары',
  'create_order': 'Создать заказ',
  'order_created': 'Заказ создан',
  'order_confirmed': 'Подтверждён',
  'order_delivered': 'Доставлен',
  'order_cancelled': 'Отменён',
  'cart': 'Корзина',
  'add_to_cart': 'В корзину',
  'cart_empty': 'Корзина пуста',
  'total': 'Итого',
  'subtotal': 'Подитог',
  'discount': 'Скидка',
  'delivery': 'Доставка',
  'delivery_address': 'Адрес',
  'delivery_date': 'Дата',
  'delivery_time': 'Время',
  'delivered': 'Доставлен',
  'failed': 'Не доставлен',
  'returned': 'Возвращён',
  'payment': 'Оплата',
  'payment_method': 'Способ оплаты',
  'cash': 'Наличные',
  'card': 'Карта',
  'transfer': 'Перевод',
  'credit': 'Кредит',
  'amount': 'Сумма',
  'report': 'Отчёт',
  'daily_report': 'Дневной отчёт',
  'sales': 'Продажи',
  'visits_count': 'Визиты',
  'collections': 'Сборы',
  'language': 'Язык',
  'theme': 'Тема',
  'notifications': 'Уведомления',
  'biometric_auth': 'Биометрия',
  'about': 'О приложении',
  'version': 'Версия',
  'sync': 'Синхронизация',
  'network_error': 'Нет подключения',
  'server_error': 'Ошибка сервера',
  'auth_error': 'Ошибка авторизации',
  'timeout_error': 'Время истекло',
  'unknown_error': 'Неизвестная ошибка',
};

// ============ INGLIZ TILI ============

const Map<String, String> _englishStrings = {
  'app_name': 'NIZOM GLOBAL',
  'ok': 'OK',
  'cancel': 'Cancel',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'add': 'Add',
  'search': 'Search',
  'filter': 'Filter',
  'refresh': 'Refresh',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'no_data': 'No data found',
  'retry': 'Retry',
  'yes': 'Yes',
  'no': 'No',
  'login': 'Login',
  'logout': 'Logout',
  'username': 'Username',
  'password': 'Password',
  'forgot_password': 'Forgot password?',
  'reset_password': 'Reset password',
  'phone': 'Phone',
  'otp_code': 'OTP Code',
  'verify': 'Verify',
  'biometric': 'Biometric',
  'sso_login': 'SSO Login',
  'home': 'Home',
  'orders': 'Orders',
  'customers': 'Customers',
  'products': 'Products',
  'visits': 'Visits',
  'map': 'Map',
  'profile': 'Profile',
  'settings': 'Settings',
  'more': 'More',
  'new_order': 'New Order',
  'order_number': 'Order Number',
  'order_status': 'Status',
  'order_total': 'Total',
  'order_items': 'Items',
  'create_order': 'Create Order',
  'order_created': 'Order Created',
  'order_confirmed': 'Confirmed',
  'order_delivered': 'Delivered',
  'order_cancelled': 'Cancelled',
  'cart': 'Cart',
  'add_to_cart': 'Add to Cart',
  'cart_empty': 'Cart is empty',
  'total': 'Total',
  'subtotal': 'Subtotal',
  'discount': 'Discount',
  'delivery': 'Delivery',
  'delivery_address': 'Address',
  'delivery_date': 'Date',
  'delivery_time': 'Time',
  'delivered': 'Delivered',
  'failed': 'Failed',
  'returned': 'Returned',
  'payment': 'Payment',
  'payment_method': 'Payment Method',
  'cash': 'Cash',
  'card': 'Card',
  'transfer': 'Transfer',
  'credit': 'Credit',
  'amount': 'Amount',
  'report': 'Report',
  'daily_report': 'Daily Report',
  'sales': 'Sales',
  'visits_count': 'Visits',
  'collections': 'Collections',
  'language': 'Language',
  'theme': 'Theme',
  'notifications': 'Notifications',
  'biometric_auth': 'Biometric Auth',
  'about': 'About',
  'version': 'Version',
  'sync': 'Sync',
  'network_error': 'No internet connection',
  'server_error': 'Server error',
  'auth_error': 'Authentication error',
  'timeout_error': 'Timeout',
  'unknown_error': 'Unknown error',
};
