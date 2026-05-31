import 'dart:async';
import 'sap_api_client.dart';

// ============================================================
// SAP CUSTOMER SYNC - Mijozlarni SAP dan yuklash
// ============================================================

class SAPCustomerSync {
  final SAPAPIClient client;

  SAPCustomerSync(this.client);

  /// Agent biriktirilgan barcha mijozlarni yuklash
  Future<List<SAPCustomer>> fetchAgentCustomers({
    required String salesPerson,
    DateTime? sinceDate,
    int top = 500,
    int skip = 0,
  }) async {
    final filters = <String>["SalesPerson eq '$salesPerson'"];
    if (sinceDate != null) {
      filters.add(
          "LastChangedDateTime ge datetime'${sinceDate.toIso8601String()}'");
    }

    final response = await client.get(
      '/API_BUSINESS_PARTNER/A_Customer',
      queryParameters: {
        if (filters.isNotEmpty) r'$filter': filters.join(' and '),
        r'$orderby': 'CustomerName asc',
        r'$top': top,
        r'$skip': skip,
      },
    );

    final data = response.data['d']['results'] as List;
    return data.map((json) => SAPCustomer.fromJson(json)).toList();
  }

  /// Sahifalab yuklash
  Future<List<SAPCustomer>> fetchAllCustomers({
    required String salesPerson,
    DateTime? sinceDate,
    int pageSize = 500,
  }) async {
    final allCustomers = <SAPCustomer>[];
    int skip = 0;
    bool hasMore = true;

    while (hasMore) {
      final batch = await fetchAgentCustomers(
        salesPerson: salesPerson,
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

/// SAP Mijoz model
class SAPCustomer {
  final String customer;
  final String customerName;
  final String organizationName;
  final String taxNumber;
  final String street;
  final String city;
  final String region;
  final String country;
  final String phoneNumber;
  final String? emailAddress;
  final String salesPerson;
  final String salesOrganization;
  final String distributionChannel;
  final String customerPriceGroup;
  final String paymentTerms;
  final int paymentDays;
  final double creditLimit;
  final double creditExposure;
  final String currency;
  final bool isBlocked;
  final double? latitude;
  final double? longitude;
  final DateTime? lastChanged;

  const SAPCustomer({
    required this.customer,
    required this.customerName,
    required this.organizationName,
    required this.taxNumber,
    required this.street,
    required this.city,
    required this.region,
    required this.country,
    required this.phoneNumber,
    this.emailAddress,
    required this.salesPerson,
    required this.salesOrganization,
    required this.distributionChannel,
    required this.customerPriceGroup,
    required this.paymentTerms,
    required this.paymentDays,
    required this.creditLimit,
    required this.creditExposure,
    required this.currency,
    required this.isBlocked,
    this.latitude,
    this.longitude,
    this.lastChanged,
  });

  factory SAPCustomer.fromJson(Map<String, dynamic> json) {
    return SAPCustomer(
      customer: json['Customer'] ?? '',
      customerName: json['CustomerName'] ?? '',
      organizationName: json['OrganizationBPName1'] ?? '',
      taxNumber: json['TaxNumber1'] ?? '',
      street: json['Street'] ?? '',
      city: json['CityName'] ?? '',
      region: json['Region'] ?? '',
      country: json['Country'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      emailAddress: json['EmailAddress'],
      salesPerson: json['SalesPerson'] ?? '',
      salesOrganization: json['SalesOrganization'] ?? '',
      distributionChannel: json['DistributionChannel'] ?? '',
      customerPriceGroup: json['CustomerPriceGroup'] ?? '',
      paymentTerms: json['PaymentTerms'] ?? '',
      paymentDays: json['PaymentDays'] ?? 30,
      creditLimit: (json['CreditLimit'] ?? 0).toDouble(),
      creditExposure: (json['CreditExposure'] ?? 0).toDouble(),
      currency: json['Currency'] ?? 'UZS',
      isBlocked: json['IsBlocked'] ?? false,
      latitude: json['Latitude']?.toDouble(),
      longitude: json['Longitude']?.toDouble(),
      lastChanged: json['LastChangedDateTime'] != null
          ? DateTime.parse(json['LastChangedDateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'Customer': customer,
        'CustomerName': customerName,
        'OrganizationBPName1': organizationName,
        'TaxNumber1': taxNumber,
        'Street': street,
        'CityName': city,
        'Region': region,
        'Country': country,
        'PhoneNumber': phoneNumber,
        'EmailAddress': emailAddress,
        'SalesPerson': salesPerson,
        'SalesOrganization': salesOrganization,
        'DistributionChannel': distributionChannel,
        'CustomerPriceGroup': customerPriceGroup,
        'PaymentTerms': paymentTerms,
        'PaymentDays': paymentDays,
        'CreditLimit': creditLimit,
        'CreditExposure': creditExposure,
        'Currency': currency,
        'IsBlocked': isBlocked,
        'Latitude': latitude,
        'Longitude': longitude,
      };
}
