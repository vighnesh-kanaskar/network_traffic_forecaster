import 'package:flutter/material.dart';

import '../controllers/network_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_view.dart';

class ForecastPage extends StatelessWidget {
  final NetworkController controller;

  const ForecastPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading && controller.forecast == null) {
          return const LoadingView();
        }

        final forecast = controller.forecast;

        if (forecast == null) {
          return const Center(child: Text('Forecast unavailable'));
        }

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const Text(
              'Threat Forecast',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              'Predict the next probable network threat stage',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),

            const SizedBox(height: 22),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      _predictionCard(forecast),
                      const SizedBox(height: 14),
                      _confidenceCard(forecast),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _predictionCard(forecast)),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: _confidenceCard(forecast)),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            _evidenceCard(forecast),
          ],
        );
      },
    );
  }

  Widget _predictionCard(dynamic forecast) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attack Progression Prediction',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 5),

          const Text(
            'Predicted transition based on network behaviour',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),

          const SizedBox(height: 35),

          Row(
            children: [
              Expanded(
                child: _stage(
                  'CURRENT STAGE',
                  forecast.currentState,
                  AppTheme.cyan,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.purple,
                ),
              ),

              Expanded(
                child: _stage(
                  'PREDICTED STAGE',
                  forecast.predictedState,
                  AppTheme.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warning.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.warning,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Expected window: ${forecast.forecastWindow}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stage(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _confidenceCard(dynamic forecast) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Confidence',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 28),

          Center(
            child: SizedBox(
              width: 125,
              height: 125,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: forecast.confidence / 100,
                    strokeWidth: 9,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.purple),
                  ),
                  Text(
                    '${forecast.confidence}%',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          _infoRow('Risk Score', '${forecast.risk}/100'),

          const SizedBox(height: 12),

          _infoRow('Forecast Window', forecast.forecastWindow),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _evidenceCard(dynamic forecast) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction Evidence',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 5),

          const Text(
            'Network features contributing to the prediction',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),

          const SizedBox(height: 20),

          ...forecast.evidence.map<Widget>((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.cyan,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.feature,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    item.change,
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
