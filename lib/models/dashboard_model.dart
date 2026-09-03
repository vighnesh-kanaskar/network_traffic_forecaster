class DashboardModel {
  final double dataMb;
  final int packets;
  final double packetsPerSecond;
  final int flows;
  final int uniqueIps;
  final int risk;
  final int confidence;
  final String currentState;
  final String predictedState;

  DashboardModel({
    required this.dataMb,
    required this.packets,
    required this.packetsPerSecond,
    required this.flows,
    required this.uniqueIps,
    required this.risk,
    required this.confidence,
    required this.currentState,
    required this.predictedState,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      dataMb: (json['data_mb'] ?? 0).toDouble(),

      packets: (json['packets'] ?? 0).toInt(),

      packetsPerSecond: (json['packets_per_second'] ?? 0).toDouble(),

      flows: (json['flows'] ?? 0).toInt(),

      uniqueIps: (json['unique_ips'] ?? 0).toInt(),

      risk: (json['risk'] ?? 0).toInt(),

      confidence: (json['confidence'] ?? 0).toInt(),

      currentState: json['current_state'] ?? 'Unknown',

      predictedState: json['predicted_state'] ?? 'Unknown',
    );
  }
}
