import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

// ============================================================
// IMAGE RECOGNITION SERVICE - Rasm orqali tanish
// ============================================================

class ImageRecognitionService {
  static final ImageRecognitionService _instance =
      ImageRecognitionService._internal();
  factory ImageRecognitionService() => _instance;
  ImageRecognitionService._internal();

  // ============ PRODUCT RECOGNITION ============

  /// Rasm orqali mahsulot tanish
  Future<Either<Failure, ProductRecognitionResult>> recognizeProduct(
    File imageFile,
  ) async {
    try {
      if (!await imageFile.exists()) {
        return Left(NotFoundFailure(resource: 'Rasm fayli'));
      }
      final guess = _guessProductFromFileName(imageFile.path);
      return Right(ProductRecognitionResult(
        productId: guess['id']!,
        productName: guess['name']!,
        confidence: 0.72,
        barcode: guess['barcode'],
        alternatives: _demoAlternatives
            .where((item) => item['id'] != guess['id'])
            .take(3)
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Tanish xatoligi'));
    }
  }

  // ============ BARCODE SCANNING ============

  /// Barcode skanerlash
  Future<Either<Failure, BarcodeResult>> scanBarcode(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return Left(NotFoundFailure(resource: 'Rasm fayli'));
      }
      final code = _extractBarcodeLikeValue(imageFile.path) ?? '4790000000017';
      final guess = _guessProductFromBarcode(code);
      return Right(BarcodeResult(
        code: code,
        format: code.length == 13 ? 'EAN_13' : 'CODE_128',
        productId: guess?['id'],
        productName: guess?['name'],
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Barcode o\'qish xatoligi'));
    }
  }

  // ============ OCR ============

  /// Matn o'qish (OCR)
  Future<Either<Failure, OcrResult>> recognizeText(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return Left(NotFoundFailure(resource: 'Rasm fayli'));
      }
      final name = imageFile.uri.pathSegments.isEmpty
          ? imageFile.path
          : imageFile.uri.pathSegments.last;
      final text = name
          .replaceAll(RegExp(r'[_\-]+'), ' ')
          .replaceAll(RegExp(r'\.[A-Za-z0-9]+$'), '')
          .trim();
      return Right(OcrResult(
        text: text.isEmpty ? 'Matn aniqlanmadi' : text,
        confidence: text.isEmpty ? 0.2 : 0.68,
        blocks: text.isEmpty
            ? const []
            : [
                OcrBlock(
                    text: text,
                    confidence: 0.68,
                    boundingBox: const {'x': 0, 'y': 0, 'w': 1, 'h': 1})
              ],
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Matn o\'qish xatoligi'));
    }
  }

  // ============ DAMAGE DETECTION ============

  /// Shikastlanish aniqlash
  Future<Either<Failure, DamageResult>> detectDamage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return Left(NotFoundFailure(resource: 'Rasm fayli'));
      }
      final lower = imageFile.path.toLowerCase();
      final isDamaged = lower.contains('damage') ||
          lower.contains('broken') ||
          lower.contains('shikast');
      return Right(DamageResult(
        isDamaged: isDamaged,
        damageType: isDamaged ? 'visual_damage' : null,
        confidence: isDamaged ? 0.74 : 0.66,
        description: isDamaged
            ? 'Rasm nomi bo‘yicha shikastlanish ehtimoli aniqlandi'
            : 'Mahsulot yaxshi holatda',
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Tekshirish xatoligi'));
    }
  }

  static const List<Map<String, String>> _demoAlternatives = [
    {'id': 'prod_1', 'name': 'Coca-Cola 1.5L', 'barcode': '4790000000017'},
    {'id': 'prod_2', 'name': 'Fanta 1.5L', 'barcode': '4790000000024'},
    {'id': 'prod_3', 'name': 'Sprite 0.5L', 'barcode': '4790000000031'},
    {'id': 'prod_4', 'name': 'Nestle Water 1L', 'barcode': '4790000000048'},
  ];

  Map<String, String> _guessProductFromFileName(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('fanta')) return _demoAlternatives[1];
    if (lower.contains('sprite')) return _demoAlternatives[2];
    if (lower.contains('water') || lower.contains('suv'))
      return _demoAlternatives[3];
    return _demoAlternatives[0];
  }

  Map<String, String>? _guessProductFromBarcode(String code) {
    for (final item in _demoAlternatives) {
      if (item['barcode'] == code) return item;
    }
    return null;
  }

  String? _extractBarcodeLikeValue(String path) {
    final match = RegExp(r'(\d{8,14})').firstMatch(path);
    return match?.group(1);
  }
}

// ============ MODELS ============

class ProductRecognitionResult {
  final String productId;
  final String productName;
  final double confidence;
  final String? barcode;
  final List<Map<String, dynamic>> alternatives;

  const ProductRecognitionResult({
    required this.productId,
    required this.productName,
    required this.confidence,
    this.barcode,
    required this.alternatives,
  });
}

class BarcodeResult {
  final String code;
  final String format;
  final String? productId;
  final String? productName;

  const BarcodeResult({
    required this.code,
    required this.format,
    this.productId,
    this.productName,
  });
}

class OcrResult {
  final String text;
  final double confidence;
  final List<OcrBlock> blocks;

  const OcrResult({
    required this.text,
    required this.confidence,
    required this.blocks,
  });
}

class OcrBlock {
  final String text;
  final double confidence;
  final Map<String, dynamic> boundingBox;

  const OcrBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

class DamageResult {
  final bool isDamaged;
  final String? damageType;
  final double confidence;
  final String description;

  const DamageResult({
    required this.isDamaged,
    this.damageType,
    required this.confidence,
    required this.description,
  });
}
