import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/section_title.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final alerts = appState.openAlerts;

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Alert Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  title: 'Active',
                  value: '${appState.activeAlertsCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryBox(
                  title: 'High Severity',
                  value: '${appState.highSeverityAlertsCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  title: 'Medium',
                  value: '${appState.mediumSeverityAlertsCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryBox(
                  title: 'Low',
                  value: '${appState.lowSeverityAlertsCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Open Alerts'),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No open alerts.'),
              ),
            )
          else
            ...alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(alert: alert),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
