// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../controllers/app_state.dart';
// import '../widgets/add_event_dialog.dart';
// import '../widgets/add_note_dialog.dart';

// class ShipmentDetailScreen extends StatefulWidget {
//   final String shipmentId;

//   const ShipmentDetailScreen({super.key, required this.shipmentId});

//   @override
//   State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
// }

// class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final appState = context.read<AppState>();
//       appState.refreshShipmentDetail(widget.shipmentId);
//       appState.fetchRecommendationForShipment(widget.shipmentId);
//     });
//   }

//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'delayed':
//         return Colors.red;
//       case 'at risk':
//         return Colors.orange;
//       case 'delivered':
//         return Colors.green;
//       case 'customs delay':
//         return Colors.purple;
//       default:
//         return Colors.cyan;
//     }
//   }

//   Color _severityColor(String severity) {
//     switch (severity.toLowerCase()) {
//       case 'high':
//         return Colors.red;
//       case 'medium':
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   Color _riskColor(String risk) {
//     switch (risk.toLowerCase()) {
//       case 'high':
//         return Colors.red;
//       case 'medium':
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   Future<void> _openAddNoteDialog(
//     BuildContext context,
//     String shipmentId,
//   ) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (_) => AddNoteDialog(shipmentId: shipmentId),
//     );

//     if (result == true && context.mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Note added')));
//     }
//   }

//   Future<void> _openAddEventDialog(
//     BuildContext context,
//     String shipmentId,
//   ) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (_) => AddEventDialog(initialShipmentId: shipmentId),
//     );

//     if (result == true && context.mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Event added')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appState = context.watch<AppState>();
//     final shipment = appState.getShipmentById(widget.shipmentId);

//     if (shipment == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Shipment Details')),
//         body: const Center(child: Text('Shipment not found')),
//       );
//     }

//     final alerts = appState.alertsForShipment(widget.shipmentId);
//     final events = appState.eventsForShipment(widget.shipmentId);
//     final notes = appState.notesForShipment(widget.shipmentId);
//     final suggestion = appState.suggestionForShipment(shipment);
//     final statusColor = _statusColor(shipment.status);
//     final riskColor = _riskColor(shipment.risk);
//     final openAlertCount = alerts
//         .where((alert) => !alert.isAcknowledged)
//         .length;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shipment ${shipment.id}'),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await appState.refreshShipmentDetail(widget.shipmentId);
//               await appState.fetchRecommendationForShipment(widget.shipmentId);

//               if (!mounted) return;
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Shipment synced from backend')),
//               );
//             },
//             icon: const Icon(Icons.sync),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           if (appState.syncMessage != null) ...[
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Text(appState.syncMessage!),
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Wrap(
//                     runSpacing: 10,
//                     spacing: 10,
//                     crossAxisAlignment: WrapCrossAlignment.center,
//                     children: [
//                       Text(
//                         shipment.id,
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: statusColor.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(
//                           shipment.status,
//                           style: TextStyle(
//                             color: statusColor,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: riskColor.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(
//                           '${shipment.risk} Risk',
//                           style: TextStyle(
//                             color: riskColor,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     '${shipment.origin} → ${shipment.destination}',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 6),
//                   Text('Estimated arrival: ${shipment.eta}'),
//                   const SizedBox(height: 18),
//                   DropdownButtonFormField<String>(
//                     value: shipment.status,
//                     decoration: const InputDecoration(
//                       labelText: 'Update Status',
//                     ),
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'In Transit',
//                         child: Text('In Transit'),
//                       ),
//                       DropdownMenuItem(
//                         value: 'Delayed',
//                         child: Text('Delayed'),
//                       ),
//                       DropdownMenuItem(
//                         value: 'At Risk',
//                         child: Text('At Risk'),
//                       ),
//                       DropdownMenuItem(
//                         value: 'Customs Delay',
//                         child: Text('Customs Delay'),
//                       ),
//                       DropdownMenuItem(
//                         value: 'Delivered',
//                         child: Text('Delivered'),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       if (value == null) return;
//                       appState.updateShipmentStatus(shipment.id, value);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Shipment status updated'),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               _OverviewStatCard(
//                 title: 'Route',
//                 value: '${shipment.origin} → ${shipment.destination}',
//                 icon: Icons.route_outlined,
//               ),
//               _OverviewStatCard(
//                 title: 'ETA',
//                 value: shipment.eta,
//                 icon: Icons.schedule_outlined,
//               ),
//               _OverviewStatCard(
//                 title: 'Open Alerts',
//                 value: '$openAlertCount',
//                 icon: Icons.notification_important_outlined,
//               ),
//               _OverviewStatCard(
//                 title: 'Events Logged',
//                 value: '${events.length}',
//                 icon: Icons.timeline_outlined,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Operator Actions',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               FilledButton.icon(
//                 onPressed: () =>
//                     _openAddEventDialog(context, widget.shipmentId),
//                 icon: const Icon(Icons.add_task_outlined),
//                 label: const Text('Add Event'),
//               ),
//               OutlinedButton.icon(
//                 onPressed: () => _openAddNoteDialog(context, widget.shipmentId),
//                 icon: const Icon(Icons.note_add_outlined),
//                 label: const Text('Add Note'),
//               ),
//               OutlinedButton.icon(
//                 onPressed: openAlertCount == 0
//                     ? null
//                     : () {
//                         appState.acknowledgeAlertsForShipment(
//                           widget.shipmentId,
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('All related alerts acknowledged'),
//                           ),
//                         );
//                       },
//                 icon: const Icon(Icons.done_all_outlined),
//                 label: const Text('Acknowledge Alerts'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Recommendation Panel',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 8),
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.auto_awesome_outlined),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       suggestion,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Operator Notes',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//               Text(
//                 '${notes.length} items',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (notes.isEmpty)
//             const Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('No operator notes yet.'),
//               ),
//             )
//           else
//             ...notes.map(
//               (note) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Card(
//                   child: ListTile(
//                     leading: const CircleAvatar(
//                       child: Icon(Icons.person_outline),
//                     ),
//                     title: Text(note.author),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(note.note),
//                         const SizedBox(height: 4),
//                         Text('Logged at: ${note.timestamp}'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Related Alerts',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//               Text(
//                 '${alerts.length} items',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (alerts.isEmpty)
//             const Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('No related alerts.'),
//               ),
//             )
//           else
//             ...alerts.map((alert) {
//               final severityColor = _severityColor(alert.severity);

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           alert.title,
//                           style: const TextStyle(fontWeight: FontWeight.w700),
//                         ),
//                         const SizedBox(height: 8),
//                         Text('Route: ${alert.route}'),
//                         const SizedBox(height: 4),
//                         Text('Impact: ${alert.impact}'),
//                         const SizedBox(height: 4),
//                         Text('Updated at: ${alert.updatedAt}'),
//                         const SizedBox(height: 10),
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: severityColor.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(999),
//                               ),
//                               child: Text(
//                                 alert.severity,
//                                 style: TextStyle(
//                                   color: severityColor,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: alert.isAcknowledged
//                                     ? Colors.green.withOpacity(0.12)
//                                     : Colors.red.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(999),
//                               ),
//                               child: Text(
//                                 alert.isAcknowledged ? 'Acknowledged' : 'Open',
//                                 style: TextStyle(
//                                   color: alert.isAcknowledged
//                                       ? Colors.green
//                                       : Colors.red,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (!alert.isAcknowledged) ...[
//                           const SizedBox(height: 12),
//                           OutlinedButton(
//                             onPressed: () {
//                               appState.acknowledgeAlert(alert.id);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Alert acknowledged'),
//                                 ),
//                               );
//                             },
//                             child: const Text('Acknowledge This Alert'),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Event Timeline',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//               Text(
//                 '${events.length} items',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (events.isEmpty)
//             const Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('No events recorded yet.'),
//               ),
//             )
//           else
//             ...events.map(
//               (event) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Card(
//                   child: ListTile(
//                     leading: const CircleAvatar(child: Icon(Icons.timeline)),
//                     title: Text(event.title),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Text(event.description),
//                         const SizedBox(height: 4),
//                         Text('Logged at: ${event.timestamp}'),
//                       ],
//                     ),
//                     trailing: IconButton(
//                       onPressed: () {
//                         appState.deleteEvent(event.id);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Event deleted')),
//                         );
//                       },
//                       icon: const Icon(Icons.delete_outline),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _OverviewStatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;

//   const _OverviewStatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 165,
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(radius: 18, child: Icon(icon, size: 18)),
//               const SizedBox(height: 10),
//               Text(title, style: Theme.of(context).textTheme.bodyMedium),
//               const SizedBox(height: 4),
//               Text(value, style: Theme.of(context).textTheme.titleMedium),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_state.dart';
import '../models/shipment_recommendation.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/add_note_dialog.dart';

class ShipmentDetailScreen extends StatefulWidget {
  final String shipmentId;

  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.refreshShipmentDetail(widget.shipmentId);
      appState.fetchRecommendationForShipment(widget.shipmentId);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delayed':
        return Colors.red;
      case 'at risk':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'customs delay':
        return Colors.purple;
      default:
        return Colors.cyan;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Future<void> _openAddNoteDialog(
    BuildContext context,
    String shipmentId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddNoteDialog(shipmentId: shipmentId),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note added')));
    }
  }

  Future<void> _openAddEventDialog(
    BuildContext context,
    String shipmentId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddEventDialog(initialShipmentId: shipmentId),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final shipment = appState.getShipmentById(widget.shipmentId);

    if (shipment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shipment Details')),
        body: const Center(child: Text('Shipment not found')),
      );
    }

    final alerts = appState.alertsForShipment(widget.shipmentId);
    final events = appState.eventsForShipment(widget.shipmentId);
    final notes = appState.notesForShipment(widget.shipmentId);
    final recommendation = appState.recommendationForShipment(shipment);
    final statusColor = _statusColor(shipment.status);
    final riskColor = _riskColor(shipment.risk);
    final openAlertCount = alerts
        .where((alert) => !alert.isAcknowledged)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment ${shipment.id}'),
        actions: [
          IconButton(
            onPressed: () async {
              await appState.refreshShipmentDetail(widget.shipmentId);
              await appState.fetchRecommendationForShipment(widget.shipmentId);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shipment synced from backend')),
              );
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (appState.syncMessage != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(appState.syncMessage!),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        shipment.id,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          shipment.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${shipment.risk} Risk',
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${shipment.origin} → ${shipment.destination}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('Estimated arrival: ${shipment.eta}'),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: shipment.status,
                    decoration: const InputDecoration(
                      labelText: 'Update Status',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'In Transit',
                        child: Text('In Transit'),
                      ),
                      DropdownMenuItem(
                        value: 'Delayed',
                        child: Text('Delayed'),
                      ),
                      DropdownMenuItem(
                        value: 'At Risk',
                        child: Text('At Risk'),
                      ),
                      DropdownMenuItem(
                        value: 'Customs Delay',
                        child: Text('Customs Delay'),
                      ),
                      DropdownMenuItem(
                        value: 'Delivered',
                        child: Text('Delivered'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      appState.updateShipmentStatus(shipment.id, value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shipment status updated'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _OverviewStatCard(
                title: 'Route',
                value: '${shipment.origin} → ${shipment.destination}',
                icon: Icons.route_outlined,
              ),
              _OverviewStatCard(
                title: 'ETA',
                value: shipment.eta,
                icon: Icons.schedule_outlined,
              ),
              _OverviewStatCard(
                title: 'Open Alerts',
                value: '$openAlertCount',
                icon: Icons.notification_important_outlined,
              ),
              _OverviewStatCard(
                title: 'Events Logged',
                value: '${events.length}',
                icon: Icons.timeline_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Operator Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () =>
                    _openAddEventDialog(context, widget.shipmentId),
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Add Event'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openAddNoteDialog(context, widget.shipmentId),
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Add Note'),
              ),
              OutlinedButton.icon(
                onPressed: openAlertCount == 0
                    ? null
                    : () {
                        appState.acknowledgeAlertsForShipment(
                          widget.shipmentId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All related alerts acknowledged'),
                          ),
                        );
                      },
                icon: const Icon(Icons.done_all_outlined),
                label: const Text('Acknowledge Alerts'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recommendation Panel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (appState.isFetchingRecommendation)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _RecommendationPanel(
            recommendation: recommendation,
            riskColor: _priorityColor(recommendation.riskLevel),
            priorityColorBuilder: _priorityColor,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Operator Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${notes.length} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (notes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No operator notes yet.'),
              ),
            )
          else
            ...notes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(note.author),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(note.note),
                        const SizedBox(height: 4),
                        Text('Logged at: ${note.timestamp}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Related Alerts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${alerts.length} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No related alerts.'),
              ),
            )
          else
            ...alerts.map((alert) {
              final severityColor = _severityColor(alert.severity);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('Route: ${alert.route}'),
                        const SizedBox(height: 4),
                        Text('Impact: ${alert.impact}'),
                        const SizedBox(height: 4),
                        Text('Updated at: ${alert.updatedAt}'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                alert.severity,
                                style: TextStyle(
                                  color: severityColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: alert.isAcknowledged
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                alert.isAcknowledged ? 'Acknowledged' : 'Open',
                                style: TextStyle(
                                  color: alert.isAcknowledged
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!alert.isAcknowledged) ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              appState.acknowledgeAlert(alert.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alert acknowledged'),
                                ),
                              );
                            },
                            child: const Text('Acknowledge This Alert'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Event Timeline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${events.length} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No events recorded yet.'),
              ),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.timeline)),
                    title: Text(event.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(event.description),
                        const SizedBox(height: 4),
                        Text('Logged at: ${event.timestamp}'),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        appState.deleteEvent(event.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event deleted')),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  final ShipmentRecommendation recommendation;
  final Color riskColor;
  final Color Function(String priority) priorityColorBuilder;

  const _RecommendationPanel({
    required this.recommendation,
    required this.riskColor,
    required this.priorityColorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_outlined),
                Text(
                  recommendation.usedLlm
                      ? 'AI Recommendation'
                      : 'Rule-Based Recommendation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${recommendation.riskLevel.toUpperCase()}  ${(recommendation.riskScore * 100).round()}%',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              recommendation.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            Text(
              'Primary Recommendation',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(recommendation.recommendation),
            const SizedBox(height: 14),
            Text('Key Issues', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            if (recommendation.keyIssues.isEmpty)
              const Text('No major issues detected.')
            else
              ...recommendation.keyIssues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(issue)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Text(
              'Suggested Next Actions',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (recommendation.recommendedActions.isEmpty)
              const Text('No suggested actions available.')
            else
              ...recommendation.recommendedActions.map((action) {
                final priorityColor = priorityColorBuilder(action.priority);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wrap(
                        //   spacing: 8,
                        //   runSpacing: 8,
                        //   crossAxisAlignment: WrapCrossAlignment.center,
                        //   children: [
                        //     Expanded(
                        //       child: Text(
                        //         action.action,
                        //         style: const TextStyle(
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //     ),
                        //     Container(
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 10,
                        //         vertical: 5,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         color: priorityColor.withOpacity(0.12),
                        //         borderRadius: BorderRadius.circular(999),
                        //       ),
                        //       child: Text(
                        //         action.priority.toUpperCase(),
                        //         style: TextStyle(
                        //           color: priorityColor,
                        //           fontWeight: FontWeight.w700,
                        //           fontSize: 12,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                action.action,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                action.priority.toUpperCase(),
                                style: TextStyle(
                                  color: priorityColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(action.reason),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 4),
            Text(
              'Source: ${recommendation.source}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 18, child: Icon(icon, size: 18)),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
