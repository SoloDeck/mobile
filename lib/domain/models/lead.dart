import 'package:mobile/core/constants/app_constants.dart';

/// Model đại diện cho một Lead (khách hàng tiềm năng).
///
/// Các fields AI qualification (leadScore, scoreRationale, v.v.) phản ánh
/// output của be-py AIFacade.qualify_lead() qua Lead Qualifier chain.
class Lead {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? company;
  final LeadSource source;
  final String? rawTranscript;
  final String? notes;
  final DateTime createdAt;

  // ── AI Qualification fields (be-py: ai/lead_qualifier/chain.py) ──

  /// Điểm đánh giá tiềm năng: Hot / Warm / Cold.
  final LeadScore? leadScore;

  /// Đoạn giải thích lý do AI chấm điểm (1 đoạn văn).
  final String? scoreRationale;

  /// Loại dự án trích xuất từ yêu cầu (vd: "Thiết kế website", "App mobile").
  final String? projectType;

  /// Mô tả phạm vi công việc ước tính.
  final String? estimatedScope;

  /// Tín hiệu ngân sách (vd: "Có ngân sách cụ thể", "Chưa xác định").
  final String? budgetSignal;

  /// Mức độ khẩn cấp của yêu cầu.
  final LeadUrgency? urgency;

  /// Giá khởi điểm đề xuất tối thiểu (VNĐ).
  final int? suggestedPriceMin;

  /// Giá khởi điểm đề xuất tối đa (VNĐ).
  final int? suggestedPriceMax;

  /// Các dấu hiệu cảnh báo: mô tả mơ hồ, trả giá, v.v.
  final List<String>? redFlags;

  /// True nếu AI đã chạy qualify trên lead này.
  final bool isQualified;

  const Lead({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.company,
    required this.source,
    this.rawTranscript,
    this.notes,
    required this.createdAt,
    this.leadScore,
    this.scoreRationale,
    this.projectType,
    this.estimatedScope,
    this.budgetSignal,
    this.urgency,
    this.suggestedPriceMin,
    this.suggestedPriceMax,
    this.redFlags,
    this.isQualified = false,
  });

  Lead copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? company,
    LeadSource? source,
    String? rawTranscript,
    String? notes,
    DateTime? createdAt,
    LeadScore? leadScore,
    String? scoreRationale,
    String? projectType,
    String? estimatedScope,
    String? budgetSignal,
    LeadUrgency? urgency,
    int? suggestedPriceMin,
    int? suggestedPriceMax,
    List<String>? redFlags,
    bool? isQualified,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      source: source ?? this.source,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      leadScore: leadScore ?? this.leadScore,
      scoreRationale: scoreRationale ?? this.scoreRationale,
      projectType: projectType ?? this.projectType,
      estimatedScope: estimatedScope ?? this.estimatedScope,
      budgetSignal: budgetSignal ?? this.budgetSignal,
      urgency: urgency ?? this.urgency,
      suggestedPriceMin: suggestedPriceMin ?? this.suggestedPriceMin,
      suggestedPriceMax: suggestedPriceMax ?? this.suggestedPriceMax,
      redFlags: redFlags ?? this.redFlags,
      isQualified: isQualified ?? this.isQualified,
    );
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      company: json['company'] as String?,
      source: LeadSource.values.byName(json['source'] as String),
      rawTranscript: json['rawTranscript'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      leadScore: json['leadScore'] != null
          ? LeadScore.values.byName(json['leadScore'] as String)
          : null,
      scoreRationale: json['scoreRationale'] as String?,
      projectType: json['projectType'] as String?,
      estimatedScope: json['estimatedScope'] as String?,
      budgetSignal: json['budgetSignal'] as String?,
      urgency: json['urgency'] != null
          ? LeadUrgency.values.byName(json['urgency'] as String)
          : null,
      suggestedPriceMin: json['suggestedPriceMin'] as int?,
      suggestedPriceMax: json['suggestedPriceMax'] as int?,
      redFlags: (json['redFlags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isQualified: json['isQualified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'source': source.name,
      'rawTranscript': rawTranscript,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'leadScore': leadScore?.name,
      'scoreRationale': scoreRationale,
      'projectType': projectType,
      'estimatedScope': estimatedScope,
      'budgetSignal': budgetSignal,
      'urgency': urgency?.name,
      'suggestedPriceMin': suggestedPriceMin,
      'suggestedPriceMax': suggestedPriceMax,
      'redFlags': redFlags,
      'isQualified': isQualified,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lead && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Lead(id: $id, name: $name, score: $leadScore)';
}
