import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/network_snapshot.dart';
import '../models/traffic_model.dart';
import '../models/forecast_model.dart';
import '../models/alert_model.dart';
import '../models/history_model.dart';

import '../services/api_service.dart';

class NetworkController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  NetworkSnapshot? dashboard;

  List<TrafficData> traffic = [];

  ForecastModel? forecast;

  List<AlertModel> alerts = [];

  List<HistoryModel> history = [];

  final List<double> riskHistory = [];

  bool isLoading = false;

  String? error;

  Timer? _refreshTimer;

  Future<void> loadAll({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      notifyListeners();
    }

    try {
      dashboard = await _apiService.getDashboard();

      traffic = await _apiService.getTraffic();

      forecast = await _apiService.getForecast();

      alerts = await _apiService.getAlerts();

      history = await _apiService.getHistory();

      error = null;
    } catch (e) {
      error = e.toString();

      debugPrint('NETRA API Error: $e');
    }

    if (showLoading) {
      isLoading = false;
    }

    notifyListeners();
  }

  void startMonitoring() {
    loadAll();

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      loadAll(showLoading: false);
    });
  }

  void stopMonitoring() {
    _refreshTimer?.cancel();

    _refreshTimer = null;
  }

  Future<void> refresh() async {
    await loadAll(showLoading: false);
  }
}
