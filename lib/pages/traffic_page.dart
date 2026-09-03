import 'package:flutter/material.dart';

import '../controllers/network_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_view.dart';

class TrafficPage extends StatefulWidget {
  final NetworkController controller;

  const TrafficPage({super.key, required this.controller});

  @override
  State<TrafficPage> createState() => _TrafficPageState();
}

class _TrafficPageState extends State<TrafficPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoading && widget.controller.traffic.isEmpty) {
          return const LoadingView();
        }

        final traffic = widget.controller.traffic.where((item) {
          final query = search.toLowerCase();

          return item.sourceIp.toLowerCase().contains(query) ||
              item.destinationIp.toLowerCase().contains(query) ||
              item.protocol.toLowerCase().contains(query);
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
                        'Traffic Analysis',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Monitor and inspect network traffic',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 230,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search traffic...',
                      prefixIcon: Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            AppCard(
              child: Row(
                children: [
                  _stat(
                    'PACKETS',
                    '${widget.controller.dashboard?.packets ?? 0}',
                    AppTheme.cyan,
                  ),
                  _divider(),
                  _stat(
                    'FLOWS',
                    '${widget.controller.dashboard?.flows ?? 0}',
                    AppTheme.purple,
                  ),
                  _divider(),
                  _stat(
                    'UNIQUE IPS',
                    '${widget.controller.dashboard?.uniqueIps ?? 0}',
                    AppTheme.success,
                  ),
                  _divider(),
                  _stat('STATUS', 'LIVE', AppTheme.success),
                ],
              ),
            ),

            const SizedBox(height: 18),

            AppCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('TIME')),
                    DataColumn(label: Text('SOURCE IP')),
                    DataColumn(label: Text('DESTINATION')),
                    DataColumn(label: Text('PROTOCOL')),
                    DataColumn(label: Text('PORT')),
                    DataColumn(label: Text('PACKETS')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: traffic.map((item) {
                    final suspicious =
                        item.status.toLowerCase() == 'suspicious';

                    return DataRow(
                      cells: [
                        DataCell(Text(item.timestamp)),
                        DataCell(Text(item.sourceIp)),
                        DataCell(Text(item.destinationIp)),
                        DataCell(Text(item.protocol)),
                        DataCell(Text('${item.port}')),
                        DataCell(Text('${item.packets}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (suspicious
                                          ? AppTheme.warning
                                          : AppTheme.success)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: TextStyle(
                                color: suspicious
                                    ? AppTheme.warning
                                    : AppTheme.success,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String title, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppTheme.border,
    );
  }
}
