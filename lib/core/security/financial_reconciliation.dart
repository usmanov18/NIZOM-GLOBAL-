import 'financial_ledger.dart';
import '../utils/decimal_helper.dart';

class FinancialReconciliation {
  static bool verify(
      List<LedgerTransaction> local, List<LedgerTransaction> server) {
    // 2026 High-Precision: Using DecimalHelper for all summations
    double localTotal = 0;
    for (var tx in local) {
      localTotal = DecimalHelper.round(localTotal + tx.amount);
    }

    double serverTotal = 0;
    for (var tx in server) {
      serverTotal = DecimalHelper.round(serverTotal + tx.amount);
    }

    return localTotal == serverTotal;
  }
}
