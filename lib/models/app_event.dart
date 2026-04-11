class AppEvent {
  final String id;
  final String shipmentId;
  final String title;
  final String description;
  final String timestamp;

  const AppEvent({
    required this.id,
    required this.shipmentId,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  AppEvent copyWith({
    String? id,
    String? shipmentId,
    String? title,
    String? description,
    String? timestamp,
  }) {
    return AppEvent(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipmentId': shipmentId,
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      id: map['id'] ?? '',
      shipmentId: map['shipmentId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
