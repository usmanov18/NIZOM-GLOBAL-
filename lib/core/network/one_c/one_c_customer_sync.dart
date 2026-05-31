import 'dart:async';
import 'one_c_api_client.dart';

// ============================================================
// 1C CUSTOMER SYNC - Mijozlarni 1C dan yuklash
// ============================================================

class OneCCustomerSync {
  final OneCAPIClient client;

  OneCCustomerSync(this.client);

  /// Agent biriktirilgan barcha mijozlarni yuklash
  Future<List<OneCCustomer>> fetchAgentCustomers({
    required String agentCode,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    final filters = <String>["Agent/Code eq '$agentCode'"];
    if (sinceDate != null) {
      filters.add("Modified gt datetime'${sinceDate.toIso8601String()}'");
    }

    final response = await client.get(
      '/catalog/Counterparties',
      queryParameters: {
        r'$filter': filters.join(' and '),
        r'$orderby': 'Description asc',
        r'$top': top,
        r'$skip': skip,
        r'$format': 'json',
      },
    );

    final data = response.data['value'] as List;
    return data.map((json) => OneCCustomer.fromJson(json)).toList();
  }

  /// Sahifalab yuklash (katta hajm uchun)
  Future<List<OneCCustomer>> fetchAllCustomers({
    required String agentCode,
    DateTime? sinceDate,
    int pageSize = 500,
  }) async {
    final allCustomers = <OneCCustomer>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final batch = await fetchAgentCustomers(
        agentCode: agentCode,
        sinceDate: sinceDate,
        top: pageSize,
        skip: skip,
      );

      allCustomers.addAll(batch);
      hasMore = batch.length >= pageSize;
      skip += pageSize;
    }

    return allCustomers;
  }
}

/// 1C Mijoz model
class OneCCustomer {
  final String refKey;
  final String code;
  final String name;
  final String fullName;
  final String inn;
  final String address;
  final String phone;
  final String? email;
  final String? contactPerson;
  final String agentCode;
  final String priceGroupKey;
  final String paymentTerms;
  final int paymentDelayDays;
  final double creditLimit;
  final double currentDebt;
  final bool isActive;
  final bool isVIP;
  final double? latitude;
  final double? longitude;
  final DateTime? lastModified;

  const OneCCustomer({
    required this.refKey,
    required this.code,
    required this.name,
    required this.fullName,
    required this.inn,
    required this.address,
    required this.phone,
    this.email,
    this.contactPerson,
    required this.agentCode,
    required this.priceGroupKey,
    required this.paymentTerms,
    required this.paymentDelayDays,
    required this.creditLimit,
    required this.currentDebt,
    required this.isActive,
    required this.isVIP,
    this.latitude,
    this.longitude,
    this.lastModified,
  });

  factory OneCCustomer.fromJson(Map<String, dynamic> json) {
    return OneCCustomer(
      refKey: json['Ref_Key'] ?? '',
      code: json['Code'] ?? '',
      name: json['Description'] ?? '',
      fullName: json['НаименованиеПолное'] ?? json['FullName'] ?? '',
      inn: json['ИНН'] ?? json['INN'] ?? '',
      address: json['ЮридическийАдрес'] ?? json['Address'] ?? '',
      phone: json['ТелефонОсновной'] ?? json['Phone'] ?? '',
      email: json['ЭлектроннаяПочта'] ?? json['Email'],
      contactPerson: json['КонтактноеЛицо'] ?? json['ContactPerson'],
      agentCode: json['Ответственный_Code'] ?? json['Agent_Code'] ?? '',
      priceGroupKey: json['ЦеноваяГруппа_Key'] ?? json['PriceGroup_Key'] ?? '',
      paymentTerms: json['УсловияОплаты'] ?? json['PaymentTerms'] ?? 'NET30',
      paymentDelayDays: json['Отсрочка'] ?? json['PaymentDelayDays'] ?? 30,
      creditLimit:
          (json['КредитныйЛимит'] ?? json['CreditLimit'] ?? 0).toDouble(),
      currentDebt: (json['ТекущийДолг'] ?? json['CurrentDebt'] ?? 0).toDouble(),
      isActive: !(json['ПометкаУдаления'] ?? json['DeletionMark'] ?? false),
      isVIP: json['VIPКлиент'] ?? json['IsVIP'] ?? false,
      latitude: json['Широта']?.toDouble() ?? json['Latitude']?.toDouble(),
      longitude: json['Долгота']?.toDouble() ?? json['Longitude']?.toDouble(),
      lastModified:
          json['Modified'] != null ? DateTime.parse(json['Modified']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'Ref_Key': refKey,
        'Code': code,
        'Description': name,
        'НаименованиеПолное': fullName,
        'ИНН': inn,
        'ЮридическийАдрес': address,
        'ТелефонОсновной': phone,
        'ЭлектроннаяПочта': email,
        'КонтактноеЛицо': contactPerson,
        'Ответственный_Code': agentCode,
        'ЦеноваяГруппа_Key': priceGroupKey,
        'УсловияОплаты': paymentTerms,
        'Отсрочка': paymentDelayDays,
        'КредитныйЛимит': creditLimit,
        'ТекущийДолг': currentDebt,
        'ПометкаУдаления': !isActive,
        'VIPКлиент': isVIP,
        'Широта': latitude,
        'Долгота': longitude,
      };
}
