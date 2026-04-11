class AlertItem {
  final String id;
  final String shipmentId;
  final String title;
  final String severity;
  final String route;
  final String impact;
  final String updatedAt;
  final bool isAcknowledged;

  const AlertItem({
    required this.id,
    required this.shipmentId,
    required this.title,
    required this.severity,
    required this.route,
    required this.impact,
    required this.updatedAt,
    this.isAcknowledged = false,
  });

  AlertItem copyWith({
    String? id,
    String? shipmentId,
    String? title,
    String? severity,
    String? route,
    String? impact,
    String? updatedAt,
    bool? isAcknowledged,
  }) {
    return AlertItem(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      route: route ?? this.route,
      impact: impact ?? this.impact,
      updatedAt: updatedAt ?? this.updatedAt,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipmentId': shipmentId,
      'title': title,
      'severity': severity,
      'route': route,
      'impact': impact,
      'updatedAt': updatedAt,
      'isAcknowledged': isAcknowledged,
    };
  }

  factory AlertItem.fromMap(Map<String, dynamic> map) {
    return AlertItem(
      id: map['id'] ?? '',
      shipmentId: map['shipmentId'] ?? '',
      title: map['title'] ?? '',
      severity: map['severity'] ?? '',
      route: map['route'] ?? '',
      impact: map['impact'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      isAcknowledged: map['isAcknowledged'] ?? false,
    );
  }
}
