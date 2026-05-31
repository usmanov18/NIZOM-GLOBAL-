import '../../../../core/network/one_c/one_c_api_client.dart';
import '../../../../core/network/sap/sap_api_client.dart';

class SyncRepositoryImpl {
  final OneCAPIClient oneCClient;
  final SAPAPIClient sapClient;

  SyncRepositoryImpl({required this.oneCClient, required this.sapClient});

  Future<void> syncEverything() async {
    // 2.0 Logic: Parallel 1C and SAP fetch
    await Future.wait([
      oneCClient.getAgentCustomers(agentCode: 'AG001'),
      sapClient.getStockBalance(plant: '1000'),
    ]);
  }
}
