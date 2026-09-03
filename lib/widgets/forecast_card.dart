import 'package:flutter/material.dart';
import 'package:network_traffic_forecaster/widgets/app_card.dart';

import '../models/forecast_model.dart';
import '../theme/app_theme.dart';

class ForecastCard extends StatelessWidget {
  final ForecastModel forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attack Progression Forecast',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _state('CURRENT', forecast.currentState)),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.cyan),
              Expanded(child: _state('PREDICTED', forecast.predictedState)),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _info('CONFIDENCE', '${forecast.confidence}%')),
              Expanded(child: _info('RISK', '${forecast.risk}')),
              Expanded(child: _info('WINDOW', forecast.forecastWindow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _state(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
