class AlertModel {
  final int id;
  final String severity;
  final String title;
  final String description;
  final DateTime timestamp;

  const AlertModel({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      severity: json['severity'] ?? 'low',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
