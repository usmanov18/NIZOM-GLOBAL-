import 'territory_assignment_models.dart';

/// Agent + mijoz region/sklad qoidalarini bitta joyda hal qiladi.
class TerritoryAssignmentPolicy {
  const TerritoryAssignmentPolicy._();

  static OrderWarehouseResolution resolveOrderWarehouse({
    required AgentTerritoryAssignment agent,
    required CustomerTerritoryProfile customer,
  }) {
    final allowed = agent.allowedWarehouseIds.toSet();
    final customerWarehouses = customer.serviceWarehouseIds.toSet();
    final intersection = allowed.intersection(customerWarehouses).toList();

    final available =
        intersection.isNotEmpty ? intersection : agent.allowedWarehouseIds;

    String selected;
    if (customer.preferredWarehouseId != null &&
        available.contains(customer.preferredWarehouseId)) {
      selected = customer.preferredWarehouseId!;
    } else if (available.contains(agent.defaultWarehouseId)) {
      selected = agent.defaultWarehouseId;
    } else {
      selected =
          available.isNotEmpty ? available.first : agent.defaultWarehouseId;
    }

    final hasMatch = intersection.isNotEmpty;
    return OrderWarehouseResolution(
      agentId: agent.agentId,
      customerId: customer.customerId,
      availableWarehouseIds: available,
      selectedWarehouseId: selected,
      hasDirectRegionMatch: hasMatch,
      warningMessage: hasMatch
          ? null
          : 'Mijoz hududiga mos sklad agentga biriktirilmagan. Agent ruxsatli skladidan foydalaniladi.',
      source: agent.source == customer.source
          ? agent.source
          : AssignmentSource.mixed,
      resolvedAt: DateTime.now(),
    );
  }
}
