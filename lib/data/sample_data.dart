import '../models/alert_item.dart';
import '../models/app_event.dart';
import '../models/shipment.dart';

class SampleData {
  static const List<Shipment> shipments = [
    Shipment(
      id: 'SHP001',
      origin: 'Mumbai',
      destination: 'Dubai',
      eta: '04 Sep 2026',
      risk: 'Medium',
      status: 'In Transit',
    ),
    Shipment(
      id: 'SHP002',
      origin: 'Delhi',
      destination: 'London',
      eta: '28 May 2026',
      risk: 'High',
      status: 'Delayed',
    ),
    Shipment(
      id: 'SHP004',
      origin: 'Pune',
      destination: 'Berlin',
      eta: '05 Feb 2026',
      risk: 'High',
      status: 'At Risk',
    ),
    Shipment(
      id: 'SHP005',
      origin: 'Jaipur',
      destination: 'Mumbai',
      eta: '29 Jul 2026',
      risk: 'Low',
      status: 'Delivered',
    ),
    Shipment(
      id: 'SHP008',
      origin: 'Hyderabad',
      destination: 'Frankfurt',
      eta: '30 Apr 2026',
      risk: 'High',
      status: 'Customs Delay',
    ),
  ];

  static const List<AlertItem> alerts = [
    AlertItem(
      id: 'ALT001',
      shipmentId: 'SHP002',
      title: 'Shipment delay due to weather disruption',
      severity: 'High',
      route: 'Delhi to London',
      impact: '+6 hours delay',
      updatedAt: '10:30 AM',
    ),
    AlertItem(
      id: 'ALT002',
      shipmentId: 'SHP004',
      title: 'Customs hold at destination port',
      severity: 'High',
      route: 'Pune to Berlin',
      impact: 'Clearance pending',
      updatedAt: '11:15 AM',
    ),
    AlertItem(
      id: 'ALT003',
      shipmentId: 'SHP008',
      title: 'Port congestion causing queue buildup',
      severity: 'Medium',
      route: 'Hyderabad to Frankfurt',
      impact: 'Possible rescheduling',
      updatedAt: '12:05 PM',
    ),
  ];

  static const List<AppEvent> events = [
    AppEvent(
      id: 'EVT001',
      shipmentId: 'SHP002',
      title: 'Weather advisory triggered',
      description: 'Expected airport congestion and late departure.',
      timestamp: '09:45 AM',
    ),
    AppEvent(
      id: 'EVT002',
      shipmentId: 'SHP004',
      title: 'Customs document review',
      description: 'Destination customs requested additional verification.',
      timestamp: '10:55 AM',
    ),
    AppEvent(
      id: 'EVT003',
      shipmentId: 'SHP008',
      title: 'Port congestion notice',
      description: 'Terminal traffic has crossed threshold levels.',
      timestamp: '11:50 AM',
    ),
  ];
}
