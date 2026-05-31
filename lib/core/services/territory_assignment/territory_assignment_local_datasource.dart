import 'dart:convert';
import 'package:hive/hive.dart';

import 'territory_assignment_models.dart';

class TerritoryAssignmentLocalDataSource {
  static const _boxName = 'territory_assignment_cache';

  Future<void> saveAgentAssignment(AgentTerritoryAssignment assignment) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'agent_${assignment.agentCode}', jsonEncode(assignment.toJson()));
    await box.put(
        'agent_id_${assignment.agentId}', jsonEncode(assignment.toJson()));
  }

  Future<AgentTerritoryAssignment?> getAgentAssignment(String codeOrId) async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('agent_$codeOrId') ?? box.get('agent_id_$codeOrId');
    if (raw == null) return null;
    return AgentTerritoryAssignment.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> saveCustomerProfile(CustomerTerritoryProfile profile) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'customer_${profile.customerCode}', jsonEncode(profile.toJson()));
    await box.put(
        'customer_id_${profile.customerId}', jsonEncode(profile.toJson()));
  }

  Future<CustomerTerritoryProfile?> getCustomerProfile(String codeOrId) async {
    final box = await Hive.openBox(_boxName);
    final raw =
        box.get('customer_$codeOrId') ?? box.get('customer_id_$codeOrId');
    if (raw == null) return null;
    return CustomerTerritoryProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw)));
  }

  Future<void> saveWarehouses(List<SalesWarehouse> warehouses) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
        'warehouses', jsonEncode(warehouses.map((e) => e.toJson()).toList()));
  }

  Future<List<SalesWarehouse>> getWarehouses() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get('warehouses');
    if (raw == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map((e) => SalesWarehouse.fromJson(e)).toList();
  }
}
