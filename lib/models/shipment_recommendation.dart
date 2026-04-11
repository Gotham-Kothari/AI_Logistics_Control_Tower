class RecommendationAction {
  final String action;
  final String priority;
  final String reason;

  const RecommendationAction({
    required this.action,
    required this.priority,
    required this.reason,
  });

  factory RecommendationAction.fromMap(Map<String, dynamic> map) {
    return RecommendationAction(
      action: (map['action'] ?? '').toString(),
      priority: (map['priority'] ?? 'medium').toString(),
      reason: (map['reason'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'priority': priority,
      'reason': reason,
    };
  }
}

class ShipmentRecommendation {
  final String shipmentId;
  final String summary;
  final String riskLevel;
  final double riskScore;
  final List<String> keyIssues;
  final List<RecommendationAction> recommendedActions;
  final bool usedLlm;
  final String source;
  final String recommendation;

  const ShipmentRecommendation({
    required this.shipmentId,
    required this.summary,
    required this.riskLevel,
    required this.riskScore,
    required this.keyIssues,
    required this.recommendedActions,
    required this.usedLlm,
    required this.source,
    required this.recommendation,
  });

  factory ShipmentRecommendation.fromMap(
    String shipmentId,
    Map<String, dynamic> map,
  ) {
    final rawIssues = map['key_issues'];
    final rawActions = map['recommended_actions'];

    final issues = rawIssues is List
        ? rawIssues.map((item) => item.toString()).toList()
        : <String>[];

    final actions = rawActions is List
        ? rawActions
            .whereType<Map>()
            .map(
              (item) => RecommendationAction.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <RecommendationAction>[];

    final summary = (map['summary'] ?? '').toString().trim();
    final topRecommendation = (map['recommendation'] ?? '').toString().trim();

    return ShipmentRecommendation(
      shipmentId: shipmentId,
      summary: summary.isNotEmpty
          ? summary
          : (topRecommendation.isNotEmpty
                ? topRecommendation
                : 'No recommendation available.'),
      riskLevel: (map['risk_level'] ?? 'medium').toString(),
      riskScore: ((map['risk_score'] ?? 0.35) as num).toDouble(),
      keyIssues: issues,
      recommendedActions: actions,
      usedLlm: map['used_llm'] == true,
      source: (map['source'] ?? 'unknown').toString(),
      recommendation: topRecommendation.isNotEmpty
          ? topRecommendation
          : (actions.isNotEmpty
                ? actions.first.action
                : (summary.isNotEmpty
                      ? summary
                      : 'Continue monitoring shipment and validate upcoming milestones.')),
    );
  }

  factory ShipmentRecommendation.fromPlainText(
    String shipmentId,
    String text,
  ) {
    final value = text.trim().isEmpty
        ? 'Continue monitoring shipment and validate upcoming milestones.'
        : text.trim();

    return ShipmentRecommendation(
      shipmentId: shipmentId,
      summary: value,
      riskLevel: 'medium',
      riskScore: 0.35,
      keyIssues: const [],
      recommendedActions: [
        RecommendationAction(
          action: value,
          priority: 'medium',
          reason: 'Returned as a plain recommendation response.',
        ),
      ],
      usedLlm: false,
      source: 'plain_text_fallback',
      recommendation: value,
    );
  }

  factory ShipmentRecommendation.fallback({
    required String shipmentId,
    required String summary,
    required String recommendation,
    required String riskLevel,
    required double riskScore,
    required List<String> keyIssues,
    required List<RecommendationAction> recommendedActions,
    String source = 'local_rule_fallback',
  }) {
    return ShipmentRecommendation(
      shipmentId: shipmentId,
      summary: summary,
      riskLevel: riskLevel,
      riskScore: riskScore,
      keyIssues: keyIssues,
      recommendedActions: recommendedActions,
      usedLlm: false,
      source: source,
      recommendation: recommendation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shipmentId': shipmentId,
      'summary': summary,
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'keyIssues': keyIssues,
      'recommendedActions': recommendedActions.map((item) => item.toMap()).toList(),
      'usedLlm': usedLlm,
      'source': source,
      'recommendation': recommendation,
    };
  }
}