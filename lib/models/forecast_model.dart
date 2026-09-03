class ForecastModel {
  final String currentState;
  final String predictedState;
  final int confidence;
  final int risk;
  final String forecastWindow;
  final List<ForecastEvidence> evidence;

  const ForecastModel({
    required this.currentState,
    required this.predictedState,
    required this.confidence,
    required this.risk,
    required this.forecastWindow,
    required this.evidence,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      currentState: json['current_state'] ?? '',
      predictedState: json['predicted_state'] ?? '',
      confidence: json['confidence'] ?? 0,
      risk: json['risk'] ?? 0,
      forecastWindow: json['forecast_window'] ?? '',
      evidence: (json['evidence'] as List? ?? [])
          .map((item) => ForecastEvidence.fromJson(item))
          .toList(),
    );
  }
}

class ForecastEvidence {
  final String feature;
  final String change;

  const ForecastEvidence({required this.feature, required this.change});

  factory ForecastEvidence.fromJson(Map<String, dynamic> json) {
    return ForecastEvidence(
      feature: json['feature'] ?? '',
      change: json['change'] ?? '',
    );
  }
}
