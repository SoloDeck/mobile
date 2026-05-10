import 'package:mobile/core/constants/app_constants.dart';

/// Model đại diện cho một Lead (khách hàng tiềm năng).
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
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lead && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Lead(id: $id, name: $name, source: $source)';
}
