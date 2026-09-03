import 'package:flutter/material.dart';

import '../controllers/network_controller.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  final NetworkController controller;

  const DashboardPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.dashboard;

    if (data == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.mistBlue),
      );
    }

    return AnimatedBuilder(
      animation: controller,

      builder: (context, _) {
        final dashboard = controller.dashboard;

        if (dashboard == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.mistBlue),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(26),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Network overview',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Live traffic and security intelligence',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _headerButton(Icons.refresh_rounded, () {
                    controller.refresh();
                  }),
                ],
              ),

              const SizedBox(height: 22),

              // ==================================================
              // METRIC CARDS
              // ==================================================
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final cardWidth = (width - 36) / 4;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,

                    children: [
                      _metricCard(
                        width: cardWidth,
                        title: 'Packets',
                        value: _formatNumber(dashboard.packets),
                        subtitle:
                            '${dashboard.packetsPerSecond.toStringAsFixed(0)} / sec',
                        icon: Icons.data_usage_outlined,
                      ),

                      _metricCard(
                        width: cardWidth,
                        title: 'Flows',
                        value: _formatNumber(dashboard.flows),
                        subtitle: 'Active connections',
                        icon: Icons.route_outlined,
                      ),

                      _metricCard(
                        width: cardWidth,
                        title: 'Unique IPs',
                        value: _formatNumber(dashboard.uniqueIps),
                        subtitle: 'Observed endpoints',
                        icon: Icons.devices_outlined,
                      ),

                      _metricCard(
                        width: cardWidth,
                        title: 'Data Transferred',
                        value: '${dashboard.dataMb.toStringAsFixed(1)} MB',
                        subtitle: 'Captured traffic',
                        icon: Icons.storage_outlined,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // RISK + FORECAST
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(flex: 2, child: _trafficCard(dashboard)),

                  const SizedBox(width: 14),

                  Expanded(child: _riskCard(dashboard)),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // RECENT TRAFFIC + ALERTS
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(flex: 2, child: _recentTraffic()),

                  const SizedBox(width: 14),

                  Expanded(child: _alertsCard()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // METRIC CARD
  // ============================================================

  Widget _metricCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: width,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: AppTheme.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppTheme.mistBlue),

              const Spacer(),

              Container(
                width: 6,
                height: 6,

                decoration: const BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            title,

            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),

          const SizedBox(height: 5),

          Text(
            value,

            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,

            style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRAFFIC CARD
  // ============================================================

  Widget _trafficCard(dynamic dashboard) {
    return Container(
      height: 285,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: AppTheme.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Traffic activity',

            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Current packet activity',

            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: CustomPaint(
              painter: TrafficChartPainter(
                dashboard.packetsPerSecond.toDouble(),
              ),

              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RISK CARD
  // ============================================================

  Widget _riskCard(dynamic dashboard) {
    final risk = dashboard.risk.toDouble();

    return Container(
      height: 285,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: AppTheme.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Security risk',

            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Current network assessment',

            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),

          const Spacer(),

          Center(
            child: SizedBox(
              width: 145,
              height: 145,

              child: Stack(
                alignment: Alignment.center,

                children: [
                  CircularProgressIndicator(
                    value: risk / 100,

                    strokeWidth: 9,

                    backgroundColor: AppTheme.lightGrey.withOpacity(0.35),

                    color: _riskColor(risk),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        '${risk.toInt()}',

                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 31,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Text(
                        'RISK',

                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Container(
                width: 7,
                height: 7,

                decoration: BoxDecoration(
                  color: _riskColor(risk),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              Text(
                _riskLabel(risk),

                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TRAFFIC
  // ============================================================

  Widget _recentTraffic() {
    final traffic = controller.traffic.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: AppTheme.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Recent traffic',

            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Latest captured network packets',

            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),

          const SizedBox(height: 15),

          if (traffic.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Waiting for network traffic...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...traffic.map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(vertical: 11),

                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),

                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.sourceIp,

                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text(
                        item.destinationIp,

                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 55,

                      child: Text(
                        item.protocol,

                        style: const TextStyle(
                          color: AppTheme.mistBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 45,

                      child: Text(
                        '${item.port}',

                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ALERT CARD
  // ============================================================

  Widget _alertsCard() {
    final alerts = controller.alerts.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: AppTheme.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Security alerts',

            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Recent security events',

            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),

          const SizedBox(height: 14),

          if (alerts.isEmpty)
            const Text(
              'No alerts detected.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            )
          else
            ...alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 13),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 7,
                      height: 7,

                      margin: const EdgeInsets.only(top: 5),

                      decoration: BoxDecoration(
                        color: _severityColor(alert.severity),

                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            alert.title,

                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            alert.description,

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(8),

      child: Container(
        width: 36,
        height: 36,

        decoration: BoxDecoration(
          color: AppTheme.surface,

          borderRadius: BorderRadius.circular(8),

          border: Border.all(color: AppTheme.border),
        ),

        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Color _riskColor(double risk) {
    if (risk >= 75) {
      return AppTheme.danger;
    }

    if (risk >= 50) {
      return AppTheme.warning;
    }

    return AppTheme.success;
  }

  String _riskLabel(double risk) {
    if (risk >= 75) {
      return 'High risk';
    }

    if (risk >= 50) {
      return 'Moderate risk';
    }

    return 'Low risk';
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppTheme.danger;

      case 'medium':
        return AppTheme.warning;

      default:
        return AppTheme.mistBlue;
    }
  }
}

// ============================================================
// TRAFFIC CHART
// ============================================================

class TrafficChartPainter extends CustomPainter {
  final double currentValue;

  TrafficChartPainter(this.currentValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.mistBlue
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.mistBlue.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final path = Path();

    final points = [
      0.35,
      0.48,
      0.40,
      0.55,
      0.50,
      0.66,
      0.58,
      0.75,
      0.62,
      0.84,
      0.72,
      0.91,
      0.65,
    ];

    final step = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1 - points.first));

    for (int i = 1; i < points.length; i++) {
      path.lineTo(i * step, size.height * (1 - points[i]));
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = AppTheme.mistBlue;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        Offset(i * step, size.height * (1 - points[i])),
        2.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrafficChartPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}
