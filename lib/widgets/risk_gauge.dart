import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RiskGauge extends StatelessWidget {
  final int value;

  const RiskGauge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    Color riskColor;

    if (value >= 70) {
      riskColor = AppTheme.danger;
    } else if (value >= 40) {
      riskColor = AppTheme.warning;
    } else {
      riskColor = AppTheme.success;
    }

    return SizedBox(
      width: 145,
      height: 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 135,
            height: 135,
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 10,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(riskColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'RISK SCORE',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 9,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
