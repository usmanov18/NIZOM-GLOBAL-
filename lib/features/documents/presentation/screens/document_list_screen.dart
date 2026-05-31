import 'package:flutter/material.dart';

/// Hujjatlar boshqaruvi
class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  String _filterType = 'all';

  final List<Map<String, dynamic>> _documents = [
    {
      'id': '1',
      'name': 'Shartnoma - Barka',
      'type': 'contract',
      'size': '2.4 MB',
      'date': '2026-05-20',
      'status': 'active'
    },
    {
      'id': '2',
      'name': 'Litsenziya №123',
      'type': 'license',
      'size': '1.8 MB',
      'date': '2026-04-15',
      'status': 'active'
    },
    {
      'id': '3',
      'name': 'Guvohnoma',
      'type': 'certificate',
      'size': '3.1 MB',
      'date': '2026-03-10',
      'status': 'active'
    },
    {
      'id': '4',
      'name': 'Sug\'urta polisi',
      'type': 'insurance',
      'size': '1.2 MB',
      'date': '2026-01-01',
      'status': 'expiring'
    },
    {
      'id': '5',
      'name': 'Xodimlar ro\'yxati',
      'type': 'other',
      'size': '0.8 MB',
      'date': '2026-05-25',
      'status': 'active'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hujjatlar'),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file), onPressed: _uploadDocument),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildDocumentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload),
        label: const Text('Yuklash'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _chip('Barchasi', 'all'),
          _chip('Shartnomalar', 'contract'),
          _chip('Litsenziyalar', 'license'),
          _chip('Guvohnomalar', 'certificate'),
          _chip('Sug\'urta', 'insurance'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (v) => setState(() => _filterType = value),
        selectedColor: const Color(0xFF1565C0).withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildDocumentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _documents.length,
      itemBuilder: (context, index) => _buildDocumentCard(_documents[index]),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    IconData typeIcon;
    Color typeColor;
    switch (doc['type']) {
      case 'contract':
        typeIcon = Icons.description;
        typeColor = const Color(0xFF1565C0);
        break;
      case 'license':
        typeIcon = Icons.card_membership;
        typeColor = const Color(0xFF2E7D32);
        break;
      case 'certificate':
        typeIcon = Icons.verified;
        typeColor = const Color(0xFFFF6F00);
        break;
      case 'insurance':
        typeIcon = Icons.security;
        typeColor = const Color(0xFF9C27B0);
        break;
      default:
        typeIcon = Icons.insert_drive_file;
        typeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 5)
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(doc['name'],
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('${doc['size']} • ${doc['date']}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Ko\'rish')),
            const PopupMenuItem(value: 'download', child: Text('Yuklab olish')),
            const PopupMenuItem(value: 'share', child: Text('Ulashish')),
            const PopupMenuItem(
                value: 'delete',
                child: Text('O\'chirish', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _uploadDocument() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Hujjat yuklash',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
            title: const Text('Kamera'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFFFF6F00)),
            title: const Text('Fayl tanlash'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828)),
            title: const Text('PDF yuklash'),
            onTap: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}
