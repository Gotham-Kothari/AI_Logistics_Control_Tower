import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/alert_item.dart';
import '../models/app_event.dart';
import '../models/operator_note.dart';
import '../models/shipment.dart';
import '../models/shipment_recommendation.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  static const String _shipmentsKey = 'controlhub_shipments';
  static const String _alertsKey = 'controlhub_alerts';
  static const String _eventsKey = 'controlhub_events';
  static const String _notesKey = 'controlhub_notes';

  final ApiService _apiService = ApiService();

  final List<Shipment> _shipments = [];
  final List<AlertItem> _alerts = [];
  final List<AppEvent> _events = [];
  final List<OperatorNote> _notes = [];

  final Map<String, ShipmentRecommendation> _backendRecommendations = {};

  String _shipmentSearchQuery = '';
  String _shipmentStatusFilter = 'All';
  String _homeSearchQuery = '';

  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _isFetchingRecommendation = false;
  String? _syncMessage;

  AppState() {
    _initialize();
  }

  List<Shipment> get shipments => List.unmodifiable(_shipments);
  List<AlertItem> get alerts => List.unmodifiable(_alerts);
  List<AppEvent> get events => List.unmodifiable(_events);
  List<OperatorNote> get notes => List.unmodifiable(_notes);

  String get shipmentSearchQuery => _shipmentSearchQuery;
  String get shipmentStatusFilter => _shipmentStatusFilter;
  String get homeSearchQuery => _homeSearchQuery;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  bool get isFetchingRecommendation => _isFetchingRecommendation;
  String? get syncMessage => _syncMessage;

  Future<void> _initialize() async {
    await _loadPersistedData();
    _isInitialized = true;
    notifyListeners();

    await syncWithBackend();
  }

  Future<void> syncWithBackend() async {
    _isSyncing = true;
    _syncMessage = null;
    notifyListeners();

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _apiService.fetchShipments(),
        _apiService.fetchAlerts(),
        _apiService.fetchEvents(),
        _apiService.fetchDecisionLogs(),
      ]);

      final fetchedShipments = results[0] as List<Shipment>;
      final fetchedAlerts = results[1] as List<AlertItem>;
      final fetchedEvents = results[2] as List<AppEvent>;
      final fetchedNotes = results[3] as List<OperatorNote>;

      _shipments
        ..clear()
        ..addAll(fetchedShipments);

      _alerts
        ..clear()
        ..addAll(fetchedAlerts);

      _events
        ..clear()
        ..addAll(fetchedEvents);

      _notes
        ..clear()
        ..addAll(fetchedNotes);

      await _saveAllData();
      _syncMessage = 'Synced with backend successfully';
    } catch (_) {
      _syncMessage = 'Backend unavailable. Using local saved data.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> refreshShipmentDetail(String shipmentId) async {
    try {
      final shipment = await _apiService.fetchShipmentDetail(shipmentId);
      final index = _shipments.indexWhere((item) => item.id == shipmentId);

      if (index != -1) {
        _shipments[index] = shipment;
      } else {
        _shipments.insert(0, shipment);
      }

      await _saveAllData();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchRecommendationForShipment(String shipmentId) async {
    _isFetchingRecommendation = true;
    notifyListeners();

    try {
      final recommendation = await _apiService.fetchRecommendation(shipmentId);
      _backendRecommendations[shipmentId] = recommendation;
    } catch (_) {
      final shipment = getShipmentById(shipmentId);
      if (shipment != null) {
        _backendRecommendations[shipmentId] = _buildFallbackRecommendation(
          shipment,
        );
      }
    } finally {
      _isFetchingRecommendation = false;
      notifyListeners();
    }
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    final shipmentsJson = prefs.getString(_shipmentsKey);
    final alertsJson = prefs.getString(_alertsKey);
    final eventsJson = prefs.getString(_eventsKey);
    final notesJson = prefs.getString(_notesKey);

    if (shipmentsJson == null ||
        alertsJson == null ||
        eventsJson == null ||
        notesJson == null) {
      _loadSampleData();
      await _saveAllData();
      return;
    }

    try {
      final decodedShipments = jsonDecode(shipmentsJson) as List;
      final decodedAlerts = jsonDecode(alertsJson) as List;
      final decodedEvents = jsonDecode(eventsJson) as List;
      final decodedNotes = jsonDecode(notesJson) as List;

      _shipments
        ..clear()
        ..addAll(
          decodedShipments.map(
            (item) => Shipment.fromMap(Map<String, dynamic>.from(item)),
          ),
        );

      _alerts
        ..clear()
        ..addAll(
          decodedAlerts.map(
            (item) => AlertItem.fromMap(Map<String, dynamic>.from(item)),
          ),
        );

      _events
        ..clear()
        ..addAll(
          decodedEvents.map(
            (item) => AppEvent.fromMap(Map<String, dynamic>.from(item)),
          ),
        );

      _notes
        ..clear()
        ..addAll(
          decodedNotes.map(
            (item) => OperatorNote.fromMap(Map<String, dynamic>.from(item)),
          ),
        );
    } catch (_) {
      _loadSampleData();
      await _saveAllData();
    }
  }

  void _loadSampleData() {
    _shipments
      ..clear()
      ..addAll(SampleData.shipments);

    _alerts
      ..clear()
      ..addAll(SampleData.alerts);

    _events
      ..clear()
      ..addAll(SampleData.events);

    _notes.clear();
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _shipmentsKey,
      jsonEncode(_shipments.map((item) => item.toMap()).toList()),
    );

    await prefs.setString(
      _alertsKey,
      jsonEncode(_alerts.map((item) => item.toMap()).toList()),
    );

    await prefs.setString(
      _eventsKey,
      jsonEncode(_events.map((item) => item.toMap()).toList()),
    );

    await prefs.setString(
      _notesKey,
      jsonEncode(_notes.map((item) => item.toMap()).toList()),
    );
  }

  List<Shipment> get filteredShipments {
    return _shipments.where((shipment) {
      final query = _shipmentSearchQuery.toLowerCase();

      final matchesSearch =
          shipment.id.toLowerCase().contains(query) ||
          shipment.origin.toLowerCase().contains(query) ||
          shipment.destination.toLowerCase().contains(query) ||
          shipment.status.toLowerCase().contains(query);

      final matchesFilter = _shipmentStatusFilter == 'All'
          ? true
          : shipment.status.toLowerCase() ==
                _shipmentStatusFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<Shipment> get riskyShipments {
    return _shipments.where((shipment) {
      final highAttentionStatuses = ['delayed', 'at risk', 'customs delay'];

      final matchesAttention =
          shipment.risk.toLowerCase() == 'high' ||
          highAttentionStatuses.contains(shipment.status.toLowerCase());

      if (_homeSearchQuery.trim().isEmpty) {
        return matchesAttention;
      }

      final query = _homeSearchQuery.toLowerCase();

      final matchesSearch =
          shipment.id.toLowerCase().contains(query) ||
          shipment.origin.toLowerCase().contains(query) ||
          shipment.destination.toLowerCase().contains(query) ||
          shipment.status.toLowerCase().contains(query);

      return matchesAttention && matchesSearch;
    }).toList();
  }

  List<AlertItem> get openAlerts {
    return _alerts.where((alert) => !alert.isAcknowledged).toList();
  }

  Shipment? getShipmentById(String id) {
    try {
      return _shipments.firstWhere((shipment) => shipment.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AlertItem> alertsForShipment(String shipmentId) {
    return _alerts.where((alert) => alert.shipmentId == shipmentId).toList();
  }

  List<AppEvent> eventsForShipment(String shipmentId) {
    final shipmentEvents = _events
        .where((event) => event.shipmentId == shipmentId)
        .toList();
    shipmentEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return shipmentEvents;
  }

  List<OperatorNote> notesForShipment(String shipmentId) {
    final shipmentNotes = _notes
        .where((note) => note.shipmentId == shipmentId)
        .toList();
    shipmentNotes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return shipmentNotes;
  }

  void updateShipmentSearchQuery(String value) {
    _shipmentSearchQuery = value;
    notifyListeners();
  }

  void updateShipmentStatusFilter(String value) {
    _shipmentStatusFilter = value;
    notifyListeners();
  }

  void updateHomeSearchQuery(String value) {
    _homeSearchQuery = value;
    notifyListeners();
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) return;

    final existing = _alerts[index];
    _alerts[index] = existing.copyWith(isAcknowledged: true);

    await _saveAllData();
    notifyListeners();

    try {
      await _apiService.acknowledgeAlert(alertId);
      await syncWithBackend();
    } catch (_) {
      _alerts[index] = existing;
      await _saveAllData();
      notifyListeners();
    }
  }

  Future<void> acknowledgeAlertsForShipment(String shipmentId) async {
    final alertsToAcknowledge = _alerts
        .where(
          (alert) => alert.shipmentId == shipmentId && !alert.isAcknowledged,
        )
        .toList();

    if (alertsToAcknowledge.isEmpty) return;

    final originalAlerts = List<AlertItem>.from(_alerts);

    for (int i = 0; i < _alerts.length; i++) {
      final alert = _alerts[i];
      if (alert.shipmentId == shipmentId && !alert.isAcknowledged) {
        _alerts[i] = alert.copyWith(isAcknowledged: true);
      }
    }

    await _saveAllData();
    notifyListeners();

    try {
      for (final alert in alertsToAcknowledge) {
        await _apiService.acknowledgeAlert(alert.id);
      }
      await syncWithBackend();
    } catch (_) {
      _alerts
        ..clear()
        ..addAll(originalAlerts);
      await _saveAllData();
      notifyListeners();
    }
  }

  Future<void> addShipment({
    required String id,
    required String origin,
    required String destination,
    required String eta,
    required String risk,
    required String status,
  }) async {
    final newShipment = Shipment(
      id: id,
      origin: origin,
      destination: destination,
      eta: eta,
      risk: risk,
      status: status,
    );

    _shipments.insert(0, newShipment);
    await _saveAllData();
    notifyListeners();

    try {
      await _apiService.createShipment(
        shipmentId: id,
        origin: origin,
        destination: destination,
        eta: eta,
        risk: risk,
        status: status,
      );

      await syncWithBackend();
    } catch (_) {}
  }

  Future<void> addEvent({
    required String shipmentId,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    final newEvent = AppEvent(
      id: 'EVT${(_events.length + 1).toString().padLeft(3, '0')}',
      shipmentId: shipmentId,
      title: title,
      description: description,
      timestamp: '$hour:$minute $period',
    );

    _events.insert(0, newEvent);
    await _saveAllData();
    notifyListeners();

    try {
      await _apiService.createEvent(
        shipmentId: shipmentId,
        title: title,
        description: description,
      );
      await syncWithBackend();
      await fetchRecommendationForShipment(shipmentId);
    } catch (_) {}
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
    await _saveAllData();
    notifyListeners();
  }

  Future<void> addOperatorNote({
    required String shipmentId,
    required String author,
    required String note,
  }) async {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    _notes.insert(
      0,
      OperatorNote(
        id: 'NOTE${(_notes.length + 1).toString().padLeft(3, '0')}',
        shipmentId: shipmentId,
        author: author,
        note: note,
        timestamp: '$hour:$minute $period',
      ),
    );

    await _saveAllData();
    notifyListeners();

    try {
      await _apiService.createDecisionLog(
        shipmentId: shipmentId,
        author: author,
        note: note,
      );
      await syncWithBackend();
      await fetchRecommendationForShipment(shipmentId);
    } catch (_) {}
  }

  Future<void> updateShipmentStatus(String shipmentId, String newStatus) async {
    final index = _shipments.indexWhere(
      (shipment) => shipment.id == shipmentId,
    );
    if (index == -1) return;

    final originalShipment = _shipments[index];
    String updatedRisk = originalShipment.risk;
    final normalized = newStatus.toLowerCase();

    if (normalized == 'delayed' ||
        normalized == 'at risk' ||
        normalized == 'customs delay') {
      updatedRisk = 'High';
    } else if (normalized == 'delivered') {
      updatedRisk = 'Low';
    }

    _shipments[index] = originalShipment.copyWith(
      status: newStatus,
      risk: updatedRisk,
    );

    await _saveAllData();
    notifyListeners();

    try {
      await _apiService.updateShipmentStatus(
        shipmentId: shipmentId,
        status: newStatus,
      );
      await syncWithBackend();
      await fetchRecommendationForShipment(shipmentId);
    } catch (_) {
      _shipments[index] = originalShipment;
      await _saveAllData();
      notifyListeners();
    }
  }

  Future<void> resetToSampleData() async {
    _loadSampleData();
    await _saveAllData();
    notifyListeners();
  }

  ShipmentRecommendation recommendationForShipment(Shipment shipment) {
    final backendRecommendation = _backendRecommendations[shipment.id];
    if (backendRecommendation != null) {
      return backendRecommendation;
    }

    return _buildFallbackRecommendation(shipment);
  }

  ShipmentRecommendation _buildFallbackRecommendation(Shipment shipment) {
    final status = shipment.status.toLowerCase();
    final risk = shipment.risk.toLowerCase();

    if (status == 'delayed' && risk == 'high') {
      return ShipmentRecommendation.fallback(
        shipmentId: shipment.id,
        summary:
            '${shipment.id} is delayed and currently tagged high risk. Immediate operations review is recommended.',
        recommendation:
            'Escalate to operations team and evaluate rerouting options.',
        riskLevel: 'high',
        riskScore: 0.82,
        keyIssues: const [
          'Shipment status is Delayed',
          'Shipment is marked High Risk',
        ],
        recommendedActions: const [
          RecommendationAction(
            action:
                'Escalate to operations team and evaluate rerouting options.',
            priority: 'high',
            reason:
                'Delay combined with high risk needs immediate intervention.',
          ),
          RecommendationAction(
            action: 'Validate carrier milestone slippage and recovery window.',
            priority: 'high',
            reason: 'Current timeline may no longer be reliable.',
          ),
        ],
      );
    }

    if (status == 'customs delay') {
      return ShipmentRecommendation.fallback(
        shipmentId: shipment.id,
        summary:
            '${shipment.id} is facing a customs-related delay and needs compliance follow-up.',
        recommendation:
            'Review compliance documents and contact customs broker immediately.',
        riskLevel: 'high',
        riskScore: 0.78,
        keyIssues: const [
          'Shipment status is Customs Delay',
          'Clearance process may be blocked',
        ],
        recommendedActions: const [
          RecommendationAction(
            action:
                'Review compliance documents and contact customs broker immediately.',
            priority: 'high',
            reason: 'Customs hold or delay requires documentation validation.',
          ),
          RecommendationAction(
            action:
                'Confirm missing paperwork, duty status, and release dependencies.',
            priority: 'medium',
            reason: 'This helps shorten resolution time.',
          ),
        ],
      );
    }

    if (status == 'at risk') {
      return ShipmentRecommendation.fallback(
        shipmentId: shipment.id,
        summary:
            '${shipment.id} is currently at risk and should be closely monitored for milestone slippage.',
        recommendation:
            'Monitor milestone slippage and prepare contingency handling plan.',
        riskLevel: 'high',
        riskScore: 0.72,
        keyIssues: const ['Shipment status is At Risk'],
        recommendedActions: const [
          RecommendationAction(
            action:
                'Monitor milestone slippage and prepare contingency handling plan.',
            priority: 'high',
            reason:
                'At-risk shipments may deteriorate quickly without intervention.',
          ),
        ],
      );
    }

    if (status == 'delivered') {
      return ShipmentRecommendation.fallback(
        shipmentId: shipment.id,
        summary:
            '${shipment.id} has been delivered and can be moved toward operational closure.',
        recommendation: 'Close active alerts and archive shipment activity.',
        riskLevel: 'low',
        riskScore: 0.08,
        keyIssues: const [],
        recommendedActions: const [
          RecommendationAction(
            action: 'Close active alerts and archive shipment activity.',
            priority: 'low',
            reason: 'Shipment is already delivered.',
          ),
        ],
      );
    }

    return ShipmentRecommendation.fallback(
      shipmentId: shipment.id,
      summary:
          '${shipment.id} is currently ${shipment.status}. No severe disruption is visible at the moment.',
      recommendation:
          'Continue monitoring shipment and validate upcoming milestones.',
      riskLevel: risk == 'high'
          ? 'high'
          : risk == 'low'
          ? 'low'
          : 'medium',
      riskScore: risk == 'high'
          ? 0.70
          : risk == 'low'
          ? 0.18
          : 0.35,
      keyIssues: const [],
      recommendedActions: const [
        RecommendationAction(
          action:
              'Continue monitoring shipment and validate upcoming milestones.',
          priority: 'medium',
          reason: 'Current shipment context does not show a severe exception.',
        ),
      ],
    );
  }

  int get totalShipmentsCount => _shipments.length;

  int get activeShipmentsCount {
    return _shipments.where((shipment) {
      return shipment.status.toLowerCase() != 'delivered';
    }).length;
  }

  int get highRiskShipmentsCount {
    return _shipments.where((shipment) {
      return shipment.risk.toLowerCase() == 'high';
    }).length;
  }

  int get onTimeDeliveryPercentage {
    if (_shipments.isEmpty) return 0;

    final onTimeStatuses = ['in transit', 'delivered'];

    final count = _shipments.where((shipment) {
      return onTimeStatuses.contains(shipment.status.toLowerCase());
    }).length;

    return ((count / _shipments.length) * 100).round();
  }

  int get activeAlertsCount => openAlerts.length;

  int get highSeverityAlertsCount {
    return openAlerts
        .where((alert) => alert.severity.toLowerCase() == 'high')
        .length;
  }

  int get mediumSeverityAlertsCount {
    return openAlerts
        .where((alert) => alert.severity.toLowerCase() == 'medium')
        .length;
  }

  int get lowSeverityAlertsCount {
    return openAlerts
        .where((alert) => alert.severity.toLowerCase() == 'low')
        .length;
  }
}
