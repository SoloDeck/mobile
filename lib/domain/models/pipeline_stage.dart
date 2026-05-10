/// Model đại diện cho một giai đoạn pipeline kèm thống kê.
class PipelineStage {
  final String id;
  final String name;
  final int order;
  final int dealCount;
  final double totalValue;

  const PipelineStage({
    required this.id,
    required this.name,
    required this.order,
    required this.dealCount,
    required this.totalValue,
  });

  PipelineStage copyWith({
    String? id,
    String? name,
    int? order,
    int? dealCount,
    double? totalValue,
  }) {
    return PipelineStage(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      dealCount: dealCount ?? this.dealCount,
      totalValue: totalValue ?? this.totalValue,
    );
  }

  factory PipelineStage.fromJson(Map<String, dynamic> json) {
    return PipelineStage(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
      dealCount: json['dealCount'] as int,
      totalValue: (json['totalValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'dealCount': dealCount,
      'totalValue': totalValue,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineStage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
