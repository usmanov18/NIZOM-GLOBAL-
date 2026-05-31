import 'package:flutter_test/flutter_test.dart';
import 'package:nizom_global/features/order_flow/domain/entities/order_flow_entities.dart';
import 'package:nizom_global/features/order_flow/domain/policies/credit_limit_policy.dart';

void main() {
  group('Order flow smoke tests', () {
    test('customer credit helpers work', () {
      const customer = OrderCustomer(
        id: 'c1',
        code: 'C001',
        name: 'Test Customer',
        creditLimit: 100000,
        currentDebt: 25000,
      );

      expect(customer.availableCredit, 75000);
      expect(customer.canAfford(50000), isTrue);
      expect(customer.canAfford(80000), isFalse);
      expect(CreditLimitPolicy.isAllowed(customer, 10000), isTrue);
    });

    test('order totals and sync flags work', () {
      final order = Order(
        id: 'o1',
        orderNumber: 'ORD-1',
        customerId: 'c1',
        customerCode: 'C001',
        customerName: 'Test Customer',
        agentId: 'a1',
        agentCode: 'A001',
        items: const [
          OrderItem(
            id: 'i1',
            productId: 'p1',
            productCode: 'P001',
            productName: 'Product',
            quantity: 3,
            unitPrice: 1000,
          ),
        ],
        totalAmount: 3000,
        status: OrderStatus.syncedTo1C,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(order.totalItems, 3);
      expect(order.isSyncedTo1C, isTrue);
      expect(order.isSyncedToSAP, isFalse);
    });
  });
}
