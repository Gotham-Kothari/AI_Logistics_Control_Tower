// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/alert_item.dart';
// import '../models/app_event.dart';
// import '../models/operator_note.dart';
// import '../models/shipment.dart';

// class ApiService {
//   ApiService({String? baseUrl})
//     : _baseUrl = baseUrl ?? 'http://10.0.2.2:8000/api';

//   final String _baseUrl;

//   Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
//     return Uri.parse('$_baseUrl$path').replace(
//       queryParameters: queryParameters?.map(
//         (key, value) => MapEntry(key, value.toString()),
//       ),
//     );
//   }

//   Future<List<Shipment>> fetchShipments() async {
//     final response = await http.get(_uri('/shipments'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch shipments');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is List) {
//       return decoded
//           .map((item) => Shipment.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     if (decoded is Map<String, dynamic> && decoded['shipments'] is List) {
//       return (decoded['shipments'] as List)
//           .map((item) => Shipment.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     throw Exception('Unexpected shipments response format');
//   }

//   Future<Shipment> fetchShipmentDetail(String shipmentId) async {
//     final response = await http.get(_uri('/shipments/$shipmentId'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch shipment detail');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is Map<String, dynamic>) {
//       return Shipment.fromMap(decoded);
//     }

//     throw Exception('Unexpected shipment detail response format');
//   }

//   Future<List<AlertItem>> fetchAlerts() async {
//     final response = await http.get(_uri('/alerts'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch alerts');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is List) {
//       return decoded
//           .map((item) => AlertItem.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     if (decoded is Map<String, dynamic> && decoded['alerts'] is List) {
//       return (decoded['alerts'] as List)
//           .map((item) => AlertItem.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     throw Exception('Unexpected alerts response format');
//   }

//   Future<List<AppEvent>> fetchEvents() async {
//     final response = await http.get(_uri('/events'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch events');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is List) {
//       return decoded
//           .map((item) => AppEvent.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     if (decoded is Map<String, dynamic> && decoded['events'] is List) {
//       return (decoded['events'] as List)
//           .map((item) => AppEvent.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     throw Exception('Unexpected events response format');
//   }

//   Future<List<OperatorNote>> fetchDecisionLogs() async {
//     final response = await http.get(_uri('/decisions'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch decision logs');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is List) {
//       return decoded
//           .map((item) => OperatorNote.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     if (decoded is Map<String, dynamic> && decoded['decisions'] is List) {
//       return (decoded['decisions'] as List)
//           .map((item) => OperatorNote.fromMap(Map<String, dynamic>.from(item)))
//           .toList();
//     }

//     throw Exception('Unexpected decision log response format');
//   }

//   Future<void> createShipment({
//     required String shipmentId,
//     required String origin,
//     required String destination,
//     required String eta,
//     required String risk,
//     required String status,
//   }) async {
//     final response = await http.post(
//       _uri('/shipments'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'shipmentId': shipmentId,
//         'origin': origin,
//         'destination': destination,
//         'eta': eta,
//         'risk': risk,
//         'status': status,
//       }),
//     );

//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception('Failed to create shipment');
//     }
//   }

//   Future<void> createEvent({
//     required String shipmentId,
//     required String title,
//     required String description,
//   }) async {
//     final response = await http.post(
//       _uri('/events'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'shipmentId': shipmentId,
//         'title': title,
//         'description': description,
//       }),
//     );

//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception('Failed to create event');
//     }
//   }

//   Future<void> createDecisionLog({
//     required String shipmentId,
//     required String author,
//     required String note,
//   }) async {
//     final response = await http.post(
//       _uri('/decisions'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'shipmentId': shipmentId,
//         'author': author,
//         'note': note,
//       }),
//     );

//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception('Failed to create decision log');
//     }
//   }

//   Future<void> updateShipmentStatus({
//     required String shipmentId,
//     required String status,
//   }) async {
//     final response = await http.patch(
//       _uri('/shipments/$shipmentId'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'status': status}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to update shipment status');
//     }
//   }

//   Future<void> acknowledgeAlert(String alertId) async {
//     final response = await http.patch(
//       _uri('/alerts/$alertId/acknowledge'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to acknowledge alert');
//     }
//   }

//   Future<String> fetchRecommendation(String shipmentId) async {
//     final response = await http.get(_uri('/recommendations/$shipmentId'));

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch recommendation');
//     }

//     final decoded = jsonDecode(response.body);

//     if (decoded is String) {
//       return decoded;
//     }

//     if (decoded is Map<String, dynamic>) {
//       if (decoded['recommendation'] is String) {
//         return decoded['recommendation'] as String;
//       }
//       if (decoded['message'] is String) {
//         return decoded['message'] as String;
//       }
//     }

//     throw Exception('Unexpected recommendation response format');
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/alert_item.dart';
import '../models/app_event.dart';
import '../models/operator_note.dart';
import '../models/shipment.dart';
import '../models/shipment_recommendation.dart';

class ApiService {
  ApiService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'http://10.0.2.2:8000/api';

  final String _baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<List<Shipment>> fetchShipments() async {
    final response = await http.get(_uri('/shipments'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch shipments');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => Shipment.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['shipments'] is List) {
      return (decoded['shipments'] as List)
          .map((item) => Shipment.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Unexpected shipments response format');
  }

  Future<Shipment> fetchShipmentDetail(String shipmentId) async {
    final response = await http.get(_uri('/shipments/$shipmentId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch shipment detail');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return Shipment.fromMap(decoded);
    }

    throw Exception('Unexpected shipment detail response format');
  }

  Future<List<AlertItem>> fetchAlerts() async {
    final response = await http.get(_uri('/alerts'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch alerts');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => AlertItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['alerts'] is List) {
      return (decoded['alerts'] as List)
          .map((item) => AlertItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Unexpected alerts response format');
  }

  Future<List<AppEvent>> fetchEvents() async {
    final response = await http.get(_uri('/events'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch events');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => AppEvent.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['events'] is List) {
      return (decoded['events'] as List)
          .map((item) => AppEvent.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Unexpected events response format');
  }

  Future<List<OperatorNote>> fetchDecisionLogs() async {
    final response = await http.get(_uri('/decisions'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch decision logs');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((item) => OperatorNote.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['decisions'] is List) {
      return (decoded['decisions'] as List)
          .map((item) => OperatorNote.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Unexpected decision log response format');
  }

  Future<void> createShipment({
    required String shipmentId,
    required String origin,
    required String destination,
    required String eta,
    required String risk,
    required String status,
  }) async {
    final response = await http.post(
      _uri('/shipments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shipmentId': shipmentId,
        'origin': origin,
        'destination': destination,
        'eta': eta,
        'risk': risk,
        'status': status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create shipment');
    }
  }

  Future<void> createEvent({
    required String shipmentId,
    required String title,
    required String description,
  }) async {
    final response = await http.post(
      _uri('/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shipmentId': shipmentId,
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create event');
    }
  }

  Future<void> createDecisionLog({
    required String shipmentId,
    required String author,
    required String note,
  }) async {
    final response = await http.post(
      _uri('/decisions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shipmentId': shipmentId,
        'author': author,
        'note': note,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create decision log');
    }
  }

  Future<void> updateShipmentStatus({
    required String shipmentId,
    required String status,
  }) async {
    final response = await http.patch(
      _uri('/shipments/$shipmentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update shipment status');
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final response = await http.patch(
      _uri('/alerts/$alertId/acknowledge'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to acknowledge alert');
    }
  }

  Future<ShipmentRecommendation> fetchRecommendation(String shipmentId) async {
    final response = await http.get(_uri('/recommendations/$shipmentId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch recommendation');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is String) {
      return ShipmentRecommendation.fromPlainText(shipmentId, decoded);
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('summary') ||
          decoded.containsKey('risk_level') ||
          decoded.containsKey('risk_score') ||
          decoded.containsKey('key_issues') ||
          decoded.containsKey('recommended_actions') ||
          decoded.containsKey('used_llm') ||
          decoded.containsKey('source')) {
        return ShipmentRecommendation.fromMap(shipmentId, decoded);
      }

      if (decoded['recommendation'] is String) {
        return ShipmentRecommendation.fromPlainText(
          shipmentId,
          decoded['recommendation'] as String,
        );
      }

      if (decoded['message'] is String) {
        return ShipmentRecommendation.fromPlainText(
          shipmentId,
          decoded['message'] as String,
        );
      }
    }

    throw Exception('Unexpected recommendation response format');
  }
}
