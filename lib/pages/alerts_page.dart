import 'package:flutter/material.dart';
import 'package:network_traffic_forecaster/widgets/app_card.dart';

import '../controllers/network_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_tile.dart';
import '../widgets/loading_view.dart';

class AlertsPage extends StatefulWidget {
  final NetworkController controller;

  const AlertsPage({super.key, required this.controller});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoading && widget.controller.alerts.isEmpty) {
          return const LoadingView();
        }

        final alerts = widget.controller.alerts.where((alert) {
          if (filter == 'All') {
            return true;
          }

          return alert.severity.toLowerCase() == filter.toLowerCase();
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Alerts',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Detected and forecasted security events',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${widget.controller.alerts.length} alerts',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                _filterButton('All'),
                const SizedBox(width: 8),
                _filterButton('High'),
                const SizedBox(width: 8),
                _filterButton('Medium'),
                const SizedBox(width: 8),
                _filterButton('Low'),
              ],
            ),

            const SizedBox(height: 18),

            if (alerts.isEmpty)
              const AppCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No alerts found',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),

            ...alerts.map((alert) => AlertTile(alert: alert)),
          ],
        );
      },
    );
  }

  Widget _filterButton(String value) {
    final selected = filter == value;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        setState(() {
          filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.purple.withOpacity(0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppTheme.purple : AppTheme.border,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
