import '../../network/one_c/one_c_api_client.dart';
import '../../network/sap/sap_api_client.dart';
import 'territory_assignment_models.dart';

/// 1C/SAP dan region/sklad biriktirish ma'lumotlarini o‘qiydi.
/// Hozir mavjud API clientlar bilan moslashgan, backend to‘liq bo‘lmasa demo fallback repositoryda ishlaydi.
class TerritoryAssignmentRemoteDataSource {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  TerritoryAssignmentRemoteDataSource({
    required this.oneCClient,
    required this.sapClient,
  });

  Future<AgentTerritoryAssignment?> getAgentFrom1C(String agentCode) async {
    final result = await oneCClient.getAgentProfile(agentCode);
    return result.fold(
      (_) => null,
      (data) => AgentTerritoryAssignment.fromJson(data,
          source: AssignmentSource.oneC),
    );
  }

  Future<CustomerTerritoryProfile?> getCustomerFrom1C(String customerId) async {
    final result = await oneCClient.getCustomerDetails(customerId);
    return result.fold(
      (_) => null,
      (data) => CustomerTerritoryProfile.fromJson(data,
          source: AssignmentSource.oneC),
    );
  }

  Future<CustomerTerritoryProfile?> getCustomerFromSAP(
      String customerNumber) async {
    final result = await sapClient.getCustomerDetails(customerNumber);
    return result.fold(
      (_) => null,
      (data) =>
          CustomerTerritoryProfile.fromJson(data, source: AssignmentSource.sap),
    );
  }

  Future<List<SalesWarehouse>> getWarehousesFromSAP({String? plant}) async {
    final result = await sapClient.getStockBalance(plant: plant ?? '1000');
    return result.fold(
      (_) => <SalesWarehouse>[],
      (items) => items
          .map((e) => SalesWarehouse.fromJson(e, source: AssignmentSource.sap))
          .where((w) => w.id.isNotEmpty || w.code.isNotEmpty)
          .toList(),
    );
  }
}
