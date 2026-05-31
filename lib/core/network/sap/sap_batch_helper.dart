class SAPBatchHelper {
  static String wrapBatch(List<String> requests) {
    // 2026 Standard: OData Multi-part batch wrapping
    return requests.join('\n--batch_nizom_global\n');
  }
}
