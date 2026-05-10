/// Model đại diện cho một Deal trong pipeline.
class Deal {
  final String id;
  final String title;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final double value;
  final String stageId;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Deal({
    required this.id,
    required this.title,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.value,
    required this.stageId,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  Deal copyWith({
    String? id,
    String? title,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    double? value,
    String? stageId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      value: value ?? this.value,
      stageId: stageId ?? this.stageId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] as String,
      title: json['title'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      value: (json['value'] as num).toDouble(),
      stageId: json['stageId'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'value': value,
      'stageId': stageId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Deal(id: $id, title: $title, customer: $customerName, value: $value)';
}
