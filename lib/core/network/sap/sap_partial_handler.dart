class SAPPartialResult {
  final List<String> successIds;
  final List<String> failedIds;
  final Map<String, String> errors;

  SAPPartialResult(
      {required this.successIds,
      required this.failedIds,
      required this.errors});
}

class SAPPartialHandler {
  static SAPPartialResult parseBatchResponse(String responseBody) {
    // 2026 OData batch parser logic
    return SAPPartialResult(successIds: [], failedIds: [], errors: {});
  }
}
