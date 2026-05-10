import 'package:mobile/core/constants/app_constants.dart';

/// Model đại diện cho một đề xuất (proposal) do AI soạn thảo.
class Proposal {
  final String id;
  final String dealId;
  final String dealTitle;
  final String customerName;
  final String title;
  final String content;
  final ProposalStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;

  const Proposal({
    required this.id,
    required this.dealId,
    required this.dealTitle,
    required this.customerName,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.sentAt,
  });

  Proposal copyWith({
    String? id,
    String? dealId,
    String? dealTitle,
    String? customerName,
    String? title,
    String? content,
    ProposalStatus? status,
    DateTime? createdAt,
    DateTime? sentAt,
  }) {
    return Proposal(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      dealTitle: dealTitle ?? this.dealTitle,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      dealId: json['dealId'] as String,
      dealTitle: json['dealTitle'] as String,
      customerName: json['customerName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      status: ProposalStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealId': dealId,
      'dealTitle': dealTitle,
      'customerName': customerName,
      'title': title,
      'content': content,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Proposal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
