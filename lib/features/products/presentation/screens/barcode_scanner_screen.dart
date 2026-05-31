import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/product_entities.dart';
import '../../domain/repositories/product_repository.dart';

/// Barcode/QR kod skanerlash
class BarcodeScannerScreen extends StatefulWidget {
  final String purpose; // 'search', 'order', 'stock', 'inventory'

  const BarcodeScannerScreen({super.key, this.purpose = 'search'});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  String? _scannedCode;
  Map<String, dynamic>? _scannedProduct;

  final Map<String, dynamic> _sampleProduct = {
    'code': 'CC150001',
    'name': 'Coca-Cola 1.5L',
    'barcode': '4790000000017',
    'category': 'Ichimliklar',
    'price': 8500,
    'stock': 100,
    'unit': 'quti',
  };

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),

          // Scan overlay
          _buildScanOverlay(),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),

          // Scanned product result
          if (_scannedProduct != null)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: _buildScannedProduct(),
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.purpose) {
      case 'order':
        return 'Mahsulot qo\'shish';
      case 'stock':
        return 'Ombor tekshirish';
      case 'inventory':
        return 'Inventarizatsiya';
      default:
        return 'Mahsulot qidirish';
    }
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Corners
            Positioned(
              top: -2,
              left: -2,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFF1565C0), width: 4),
                        left: BorderSide(color: Color(0xFF1565C0), width: 4)),
                  )),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFF1565C0), width: 4),
                        right: BorderSide(color: Color(0xFF1565C0), width: 4)),
                  )),
            ),
            Positioned(
              bottom: -2,
              left: -2,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF1565C0), width: 4),
                        left: BorderSide(color: Color(0xFF1565C0), width: 4)),
                  )),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF1565C0), width: 4),
                        right: BorderSide(color: Color(0xFF1565C0), width: 4)),
                  )),
            ),

            // Scan line animation
            Center(
              child: Container(
                width: 260,
                height: 2,
                color: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Barcode yoki QR kodni kameraga qarating',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kod avtomatik aniqlanadi',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Manual input
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showManualInput,
              icon: const Icon(Icons.keyboard, color: Colors.white),
              label: const Text('Qo\'lda kiritish',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Recent scans
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showRecentScans,
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text('Oxirgi skanerlashlar',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedProduct() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF2E7D32), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_scannedProduct!['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                        'Kod: ${_scannedProduct!['code']} • ${_scannedProduct!['barcode']}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _productInfo('Narx', '${_scannedProduct!['price']} so\'m'),
              _productInfo('Ombor', '${_scannedProduct!['stock']} dona'),
              _productInfo('Kategoriya', _scannedProduct!['category']),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _isScanning = true;
                    _scannedProduct = null;
                    _scannedCode = null;
                  }),
                  child: const Text('Bekor qilish'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _handleScannedProduct,
                  icon: Icon(_getActionIcon()),
                  label: Text(_getActionText()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productInfo(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  IconData _getActionIcon() {
    switch (widget.purpose) {
      case 'order':
        return Icons.add_shopping_cart;
      case 'stock':
        return Icons.search;
      case 'inventory':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  String _getActionText() {
    switch (widget.purpose) {
      case 'order':
        return 'Savatga qo\'shish';
      case 'stock':
        return 'Batafsil';
      case 'inventory':
        return 'Kiritish';
      default:
        return 'Ko\'rish';
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning || _scannedProduct != null) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _simulateScan(code);
  }

  void _handleScannedProduct() {
    switch (widget.purpose) {
      case 'order':
        Navigator.pop(context, _scannedProduct);
        break;
      case 'stock':
      case 'inventory':
        Navigator.pop(context, _scannedProduct);
        break;
      default:
        Navigator.pop(context, _scannedProduct);
    }
  }

  void _showManualInput() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Barcode kiriting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Barcode raqami',
                prefixIcon: const Icon(Icons.barcode_reader),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  _simulateScan(controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Qidirish'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRecentScans() {
    if (!EnvConfig.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Oxirgi skanerlashlar real tarix servisi orqali ko‘rsatiladi')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Oxirgi skanerlashlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _recentScanItem(
                'Coca-Cola 1.5L', '4790000000017', '2 daqiqa oldin'),
            _recentScanItem('Fanta 1.5L', '4790000000024', '15 daqiqa oldin'),
            _recentScanItem('Sprite 0.5L', '4790000000031', '1 soat oldin'),
          ],
        ),
      ),
    );
  }

  Widget _recentScanItem(String name, String barcode, String time) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.barcode_reader, color: Colors.grey),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('$barcode • $time',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        _simulateScan(barcode);
      },
    );
  }

  Future<void> _simulateScan(String code) async {
    setState(() {
      _isScanning = false;
      _scannedCode = code;
      _scannedProduct = null;
    });

    final result = await getIt<ProductRepository>().getProductByBarcode(code);
    if (!mounted) return;

    result.fold(
      (failure) {
        _setScannedProduct(_fallbackProduct(code, error: failure.message));
      },
      (product) {
        _setScannedProduct(
            product == null ? _fallbackProduct(code) : _productToMap(product));
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode: $code aniqlandi'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _setScannedProduct(Map<String, dynamic> product) {
    if (!mounted) return;
    setState(() => _scannedProduct = product);
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'code': product.code,
      'name': product.name,
      'barcode': product.barcode ?? _scannedCode ?? '',
      'category': product.categoryName,
      'price': product.effectivePrice,
      'stock': product.availableQuantity,
      'unit': product.unitOfMeasure,
      'productId': product.id,
    };
  }

  Map<String, dynamic> _fallbackProduct(String code, {String? error}) {
    if (EnvConfig.isDemoMode) {
      return {
        ..._sampleProduct,
        'barcode': code,
      };
    }
    return {
      'code': code,
      'name': 'Barcode: $code',
      'barcode': code,
      'category': error ?? 'Aniqlanmagan',
      'price': 0,
      'stock': 0,
      'unit': 'dona',
    };
  }
}
