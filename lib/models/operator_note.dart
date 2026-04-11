class OperatorNote {
  final String id;
  final String shipmentId;
  final String note;
  final String author;
  final String timestamp;

  const OperatorNote({
    required this.id,
    required this.shipmentId,
    required this.note,
    required this.author,
    required this.timestamp,
  });

  OperatorNote copyWith({
    String? id,
    String? shipmentId,
    String? note,
    String? author,
    String? timestamp,
  }) {
    return OperatorNote(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      note: note ?? this.note,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shipmentId': shipmentId,
      'note': note,
      'author': author,
      'timestamp': timestamp,
    };
  }

  factory OperatorNote.fromMap(Map<String, dynamic> map) {
    return OperatorNote(
      id: map['id'] ?? '',
      shipmentId: map['shipmentId'] ?? '',
      note: map['note'] ?? '',
      author: map['author'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
