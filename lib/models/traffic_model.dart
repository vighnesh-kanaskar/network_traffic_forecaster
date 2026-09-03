class TrafficData {
  final String timestamp;
  final String sourceIp;
  final String destinationIp;
  final String protocol;
  final int port;
  final int packets;
  final String status;

  const TrafficData({
    required this.timestamp,
    required this.sourceIp,
    required this.destinationIp,
    required this.protocol,
    required this.port,
    required this.packets,
    required this.status,
  });

  factory TrafficData.fromJson(Map<String, dynamic> json) {
    return TrafficData(
      timestamp: json['timestamp'] ?? '',
      sourceIp: json['source_ip'] ?? '',
      destinationIp: json['destination_ip'] ?? '',
      protocol: json['protocol'] ?? '',
      port: json['port'] ?? 0,
      packets: json['packets'] ?? 0,
      status: json['status'] ?? 'unknown',
    );
  }
}
