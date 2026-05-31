import 'package:flutter/material.dart';

import '../../domain/entities/user_portfolio_profile.dart';
import '../../../products/domain/entities/product_portfolio.dart';
import 'portfolio_assignment_editor.dart';
import 'warehouse_assignment_editor.dart';

class AdminAgentFormResult {
  final SalesUserProfile profile;
  final PortfolioAssignment assignment;

  const AdminAgentFormResult({required this.profile, required this.assignment});
}

/// Admin profil yaratish formasi.
/// UX: uzun formani 4 bosqichga bo‘ldik:
/// 1) Profil  2) Hudud/Sklad  3) Portfolio  4) Tasdiq
class AdminAgentFormSheet extends StatefulWidget {
  final List<ProductPortfolio> portfolios;
  final Future<void> Function(AdminAgentFormResult result) onSubmit;

  const AdminAgentFormSheet(
      {super.key, required this.portfolios, required this.onSubmit});

  @override
  State<AdminAgentFormSheet> createState() => _AdminAgentFormSheetState();
}

class _AdminAgentFormSheetState extends State<AdminAgentFormSheet> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int step = 0;
  String selectedRole = 'agent';
  String selectedRegion = 'tashkent';
  String selectedSupervisor = 'sup1';
  String selectedWarehouse = 'warehouse_1';
  Set<String> selectedWarehouseIds = {'warehouse_1'};
  String selectedChannel = 'retail';
  bool canSellOutsidePortfolio = false;
  Set<String> selectedPortfolioIds = {};
  bool saving = false;

  @override
  void initState() {
    super.initState();
    selectedPortfolioIds = widget.portfolios.take(2).map((e) => e.id).toSet();
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 16),
              _stepIndicator(),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _stepBody(),
              ),
              const SizedBox(height: 20),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Yangi profil yaratish',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Profil, hudud/sklad va portfolio ruxsatlarini bosqichma-bosqich belgilang.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _stepIndicator() {
    final labels = ['Profil', 'Sklad', 'Portfolio', 'Tasdiq'];
    return Row(
      children: List.generate(labels.length, (i) {
        final active = i <= step;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor:
                    active ? const Color(0xFF1565C0) : Colors.grey.shade300,
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: active ? Colors.white : Colors.grey.shade700,
                        fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Text(labels[i],
                  style: TextStyle(
                      fontSize: 10,
                      color: active ? const Color(0xFF1565C0) : Colors.grey)),
            ],
          ),
        );
      }),
    );
  }

  Widget _stepBody() {
    switch (step) {
      case 0:
        return _profileStep();
      case 1:
        return _warehouseStep();
      case 2:
        return _portfolioStep();
      default:
        return _confirmStep();
    }
  }

  Widget _profileStep() {
    return Column(
      key: const ValueKey('profile'),
      children: [
        TextFormField(
          controller: nameController,
          decoration: _input('To‘liq ism'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ism kiriting' : null,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: codeController,
              decoration: _input('Kod (AG001)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Kod kiriting' : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _roleDropdown()),
        ]),
        const SizedBox(height: 12),
        TextFormField(
            controller: phoneController,
            decoration: _input('Telefon'),
            keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        TextFormField(controller: emailController, decoration: _input('Email')),
      ],
    );
  }

  Widget _warehouseStep() {
    return Column(
      key: const ValueKey('warehouse'),
      children: [
        Row(children: [
          Expanded(child: _regionDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _supervisorDropdown()),
        ]),
        const SizedBox(height: 12),
        _channelDropdown(),
        const SizedBox(height: 16),
        WarehouseAssignmentEditor(
          selectedWarehouse: selectedWarehouse,
          onDefaultWarehouseChanged: (value) =>
              setState(() => selectedWarehouse = value),
          selectedWarehouseIds: selectedWarehouseIds,
          onAllowedWarehousesChanged: (ids) =>
              setState(() => selectedWarehouseIds = ids),
        ),
      ],
    );
  }

  Widget _portfolioStep() {
    return PortfolioAssignmentEditor(
      key: const ValueKey('portfolio'),
      portfolios: widget.portfolios,
      selectedPortfolioIds: selectedPortfolioIds,
      onChanged: (ids) => setState(() => selectedPortfolioIds = ids),
      canSellOutsidePortfolio: canSellOutsidePortfolio,
      onOutsideChanged: (value) =>
          setState(() => canSellOutsidePortfolio = value),
    );
  }

  Widget _confirmStep() {
    return Container(
      key: const ValueKey('confirm'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tasdiqlash',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          _row('Ism', nameController.text),
          _row('Kod', codeController.text),
          _row('Rol', selectedRole),
          _row('Hudud', _regionName(selectedRegion)),
          _row(
              'Default sklad',
              WarehouseAssignmentEditor.warehouses[selectedWarehouse] ??
                  selectedWarehouse),
          _row(
              'Ruxsatli skladlar',
              selectedWarehouseIds
                  .map((e) => WarehouseAssignmentEditor.warehouses[e] ?? e)
                  .join(', ')),
          _row('Portfolio', selectedPortfolioIds.join(', ')),
          _row('Outside portfolio', canSellOutsidePortfolio ? 'Ha' : 'Yo‘q'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 125,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
              child: Text(value.isEmpty ? '—' : value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      children: [
        if (step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: saving ? null : () => setState(() => step--),
              child: const Text('Orqaga'),
            ),
          ),
        if (step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: saving ? null : _nextOrSubmit,
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(step == 3 ? 'Saqlash' : 'Keyingisi'),
          ),
        ),
      ],
    );
  }

  void _nextOrSubmit() {
    if (step == 0 && !(_formKey.currentState?.validate() ?? false)) return;
    if (step == 2 && selectedPortfolioIds.isEmpty && !canSellOutsidePortfolio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Kamida bitta portfolio tanlang yoki outside permission yoqing'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (step < 3) {
      setState(() => step++);
      return;
    }
    _submit();
  }

  InputDecoration _input(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

  Widget _roleDropdown() => DropdownButtonFormField<String>(
        initialValue: selectedRole,
        decoration: _input('Rol'),
        items: const [
          DropdownMenuItem(value: 'agent', child: Text('Agent')),
          DropdownMenuItem(value: 'manager', child: Text('Menejer')),
          DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
        ],
        onChanged: (v) => setState(() => selectedRole = v ?? 'agent'),
      );

  Widget _regionDropdown() => DropdownButtonFormField<String>(
        initialValue: selectedRegion,
        decoration: _input('Hudud'),
        items: const [
          DropdownMenuItem(value: 'tashkent', child: Text('Toshkent')),
          DropdownMenuItem(value: 'samarkand', child: Text('Samarqand')),
          DropdownMenuItem(value: 'bukhara', child: Text('Buxoro')),
        ],
        onChanged: (v) => setState(() => selectedRegion = v ?? 'tashkent'),
      );

  Widget _supervisorDropdown() => DropdownButtonFormField<String>(
        initialValue: selectedSupervisor,
        decoration: _input('Rahbar/Supervisor'),
        items: const [
          DropdownMenuItem(value: 'sup1', child: Text('Menejerov Menejer')),
          DropdownMenuItem(
              value: 'sup2', child: Text('Supervisorov Supervisor')),
        ],
        onChanged: (v) => setState(() => selectedSupervisor = v ?? 'sup1'),
      );

  Widget _channelDropdown() => DropdownButtonFormField<String>(
        initialValue: selectedChannel,
        decoration: _input('Kanal'),
        items: const [
          DropdownMenuItem(value: 'retail', child: Text('Retail')),
          DropdownMenuItem(value: 'horeca', child: Text('HoReCa')),
          DropdownMenuItem(value: 'wholesale', child: Text('Wholesale')),
        ],
        onChanged: (v) => setState(() => selectedChannel = v ?? 'retail'),
      );

  Future<void> _submit() async {
    setState(() => saving = true);
    final id = codeController.text.trim().toLowerCase();
    final assignment = PortfolioAssignment(
      id: 'assignment_$id',
      userId: id,
      userRole: selectedRole,
      portfolioIds: selectedPortfolioIds.toList(),
      canSellOutsidePortfolio: canSellOutsidePortfolio,
      assignedAt: DateTime.now(),
      assignedBy: 'admin',
    );
    final profile = SalesUserProfile(
      id: id,
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      role: selectedRole,
      code: codeController.text.trim(),
      regionId: selectedRegion,
      regionName: _regionName(selectedRegion),
      supervisorId: selectedSupervisor,
      warehouseId: selectedWarehouse,
      allowedWarehouseIds: selectedWarehouseIds.toList(),
      channel: selectedChannel,
      portfolioAssignment: assignment,
    );
    await widget.onSubmit(
        AdminAgentFormResult(profile: profile, assignment: assignment));
    if (mounted) setState(() => saving = false);
  }

  String _regionName(String regionId) {
    switch (regionId) {
      case 'tashkent':
        return 'Toshkent';
      case 'samarkand':
        return 'Samarqand';
      case 'bukhara':
        return 'Buxoro';
      default:
        return regionId;
    }
  }
}
