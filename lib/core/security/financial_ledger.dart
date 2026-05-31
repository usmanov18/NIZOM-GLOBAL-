import 'package:equatable/equatable.dart';

class LedgerTransaction extends Equatable {
  final String id;
  final String creditAccount; // e.g., 'inventory_stock'
  final String debitAccount; // e.g., 'customer_debt'
  final double amount;
  final DateTime timestamp;

  const LedgerTransaction({
    required this.id,
    required this.creditAccount,
    required this.debitAccount,
    required this.amount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, amount, timestamp];
}
