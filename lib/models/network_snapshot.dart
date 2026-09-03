class NetworkSnapshot {
  final int risk;
  final int confidence;
  final String currentState;
  final String predictedState;
  final int packets;
  final int flows;
  final int uniqueIps;
  final double packetsPerSecond;
  final double dataMb;

  const NetworkSnapshot({
    required this.risk,
    required this.confidence,
    required this.currentState,
    required this.predictedState,
    required this.packets,
    required this.flows,
    required this.uniqueIps,
    required this.packetsPerSecond,
    required this.dataMb,
  });

  factory NetworkSnapshot.fromJson(Map<String, dynamic> json) {
    return NetworkSnapshot(
      risk: json['risk'] ?? 0,
      confidence: json['confidence'] ?? 0,
      currentState: json['current_state'] ?? 'Unknown',
      predictedState: json['predicted_state'] ?? 'Unknown',
      packets: json['packets'] ?? 0,
      flows: json['flows'] ?? 0,
      uniqueIps: json['unique_ips'] ?? 0,
      packetsPerSecond: (json['packets_per_second'] ?? 0).toDouble(),
      dataMb: (json['data_mb'] ?? 0).toDouble(),
    );
  }
}
