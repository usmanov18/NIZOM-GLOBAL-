enum NetworkProtocol { rest, grpc, mqtt, websocket }

class ProtocolResolver {
  static NetworkProtocol getBestProtocol(int latencyMs, int payloadSizeKb) {
    if (latencyMs > 500) return NetworkProtocol.mqtt;
    if (payloadSizeKb > 1024) return NetworkProtocol.grpc;
    return NetworkProtocol.rest;
  }
}
