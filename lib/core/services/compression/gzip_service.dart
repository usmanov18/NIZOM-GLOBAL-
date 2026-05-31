import 'dart:convert';
import 'dart:io';

class GzipService {
  static List<int> compress(String data) {
    final enData = utf8.encode(data);
    return gzip.encode(enData);
  }

  static String decompress(List<int> compressedData) {
    final deData = gzip.decode(compressedData);
    return utf8.decode(deData);
  }
}
