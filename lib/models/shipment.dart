class Shipment {
  final String id;
  final String origin;
  final String destination;
  final String eta;
  final String risk;
  final String status;

  const Shipment({
    required this.id,
    required this.origin,
    required this.destination,
    required this.eta,
    required this.risk,
    required this.status,
  });

  Shipment copyWith({
    String? id,
    String? origin,
    String? destination,
    String? eta,
    String? risk,
    String? status,
  }) {
    return Shipment(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      eta: eta ?? this.eta,
      risk: risk ?? this.risk,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'eta': eta,
      'risk': risk,
      'status': status,
    };
  }

  factory Shipment.fromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map['id'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      eta: map['eta'] ?? '',
      risk: map['risk'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
