import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/network_snapshot.dart';
import '../models/traffic_model.dart';
import '../models/forecast_model.dart';
import '../models/alert_model.dart';
import '../models/history_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<dynamic> _get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode != 200) {
      throw Exception(
        'API error ${response.statusCode}: '
        '${response.body}',
      );
    }

    return jsonDecode(response.body);
  }

  Future<NetworkSnapshot> getDashboard() async {
    final data = await _get('/api/dashboard');

    return NetworkSnapshot(
      risk: data['risk'] ?? 0,
      confidence: data['confidence'] ?? 0,
      currentState: data['current_state'] ?? 'Unknown',
      predictedState: data['predicted_state'] ?? 'Unknown',
      packets: data['packets'] ?? 0,
      flows: data['flows'] ?? 0,
      uniqueIps: data['unique_ips'] ?? 0,
      packetsPerSecond: (data['packets_per_second'] ?? 0).toDouble(),
      dataMb: (data['data_mb'] ?? 0).toDouble(),
    );
  }

  Future<List<TrafficData>> getTraffic() async {
    final data = await _get('/api/traffic');

    return (data as List)
        .map(
          (item) => TrafficData(
            timestamp: item['timestamp'] ?? '',
            sourceIp: item['source_ip'] ?? '',
            destinationIp: item['destination_ip'] ?? '',
            protocol: item['protocol'] ?? '',
            port: item['port'] ?? 0,
            packets: item['packets'] ?? 1,
            status: item['status'] ?? 'normal',
          ),
        )
        .toList();
  }

  Future<ForecastModel> getForecast() async {
    final data = await _get('/api/forecast');

    final evidence = (data['evidence'] as List? ?? [])
        .map(
          (item) => ForecastEvidence(
            feature: item['feature'] ?? '',
            change: item['change'] ?? '',
          ),
        )
        .toList();

    return ForecastModel(
      currentState: data['current_state'] ?? 'Unknown',
      predictedState: data['predicted_state'] ?? 'Unknown',
      confidence: data['confidence'] ?? 0,
      risk: data['risk'] ?? 0,
      forecastWindow: data['forecast_window'] ?? '5-10 minutes',
      evidence: evidence,
    );
  }

  Future<List<AlertModel>> getAlerts() async {
    final data = await _get('/api/alerts');

    return (data as List)
        .map(
          (item) => AlertModel(
            id: item['id'] ?? 0,
            severity: item['severity'] ?? 'low',
            title: item['title'] ?? '',
            description: item['description'] ?? '',
            timestamp:
                DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
          ),
        )
        .toList();
  }

  Future<List<HistoryModel>> getHistory() async {
    final data = await _get('/api/history');

    return (data as List)
        .map(
          (item) => HistoryModel(
            timestamp:
                DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
            currentState: item['current_state'] ?? 'Unknown',
            predictedState: item['predicted_state'] ?? 'Unknown',
            confidence: item['confidence'] ?? 0,
            risk: item['risk'] ?? 0,
          ),
        )
        .toList();
  }
}
