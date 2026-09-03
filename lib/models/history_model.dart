class HistoryModel {
  final DateTime timestamp;
  final String currentState;
  final String predictedState;
  final int confidence;
  final int risk;

  const HistoryModel({
    required this.timestamp,
    required this.currentState,
    required this.predictedState,
    required this.confidence,
    required this.risk,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      currentState: json['current_state'] ?? '',
      predictedState: json['predicted_state'] ?? '',
      confidence: json['confidence'] ?? 0,
      risk: json['risk'] ?? 0,
    );
  }
}
