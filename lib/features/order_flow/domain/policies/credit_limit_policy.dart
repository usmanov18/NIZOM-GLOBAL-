import '../entities/order_flow_entities.dart';
import '../../../../core/utils/decimal_helper.dart';

class CreditLimitDecision {
  final bool allowed;
  final String? message;
  final double availableCredit;

  const CreditLimitDecision({
    required this.allowed,
    this.message,
    required this.availableCredit,
  });
}

class CreditLimitPolicy {
  static bool isAllowed(OrderCustomer customer, double newOrderAmount) {
    if (customer.isBlocked) return false;

    final totalPotentialDebt = DecimalHelper.round(
      customer.currentDebt + newOrderAmount,
    );
    final limit = DecimalHelper.round(customer.creditLimit);

    return totalPotentialDebt <= limit;
  }

  static CreditLimitDecision evaluate({
    required OrderCustomer customer,
    required double orderAmount,
    String? paymentMethod,
  }) {
    if (paymentMethod != 'credit') {
      return CreditLimitDecision(
        allowed: true,
        availableCredit: customer.availableCredit,
      );
    }
    if (customer.isBlocked) {
      return CreditLimitDecision(
        allowed: false,
        message: customer.blockReason ?? 'Mijoz bloklangan',
        availableCredit: customer.availableCredit,
      );
    }
    final allowed = isAllowed(customer, orderAmount);
    return CreditLimitDecision(
      allowed: allowed,
      message: allowed ? null : 'Kredit limiti yetarli emas',
      availableCredit: customer.availableCredit,
    );
  }
}
